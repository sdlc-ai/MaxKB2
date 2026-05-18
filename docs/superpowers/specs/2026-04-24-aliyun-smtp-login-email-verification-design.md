# 阿里云SMTP对接与登录邮箱验证码设计文档

## 1. 概述

本文档描述在 MaxKB 系统中对接阿里云 SMTP 服务（DirectMail），并实现基于邮箱验证码的登录增强功能的设计方案。

## 2. 背景与目标

### 2.1 现状
- 系统已具备通用 SMTP 邮件发送能力，用于注册和重置密码时的邮箱验证码
- 登录流程已有图片验证码机制（基于登录失败次数阈值触发）
- 登录认证配置通过 `auth_setting` 表管理

### 2.2 目标
1. 邮件配置支持**阿里云 DirectMail SMTP** 与**通用 SMTP** 两种服务商切换
2. 登录流程增加**邮箱验证码**作为可选的第二验证因子
3. 管理员可在后台配置邮箱验证码的启用范围
4. 内置系统管理员始终豁免邮箱验证码（逃生舱设计）

## 3. 方案决策

选择 **方案A：SMTP 统一通道 + 阿里云配置模板**。

理由：
- 阿里云 DirectMail 原生支持 SMTP 协议，无需引入额外 SDK
- 复用现有 Django `EmailBackend` 发送逻辑，后端改动最小
- 通过前端配置模板自动填充阿里云推荐参数，用户体验佳

## 4. 详细设计

### 4.1 邮件服务配置改造

#### 4.1.1 数据模型扩展

`SystemSetting`（`type=0` 即 EMAIL）的 `meta` 字段扩展 `provider`：

```json
{
  "provider": "aliyun",
  "email_host": "smtpdm.aliyun.com",
  "email_port": 465,
  "email_host_user": "noreply@xxx.com",
  "email_host_password": "...",
  "email_use_tls": false,
  "email_use_ssl": true,
  "from_email": "noreply@xxx.com"
}
```

- `provider`：`smtp` | `aliyun`，默认 `smtp`（兼容旧数据）
- 当 `provider=aliyun` 时，host/port/tls/ssl 由前端自动填充为阿里云推荐值

#### 4.1.2 阿里云 SMTP 预设参数

| 参数 | 推荐值 |
|------|--------|
| `email_host` | `smtpdm.aliyun.com` |
| `email_port` | `465` |
| `email_use_tls` | `false` |
| `email_use_ssl` | `true` |

#### 4.1.3 后端序列化器改造

`EmailSettingSerializer.Create`：
- 增加 `provider` 字段（CharField，choices=`['smtp', 'aliyun']`）
- `is_valid()` 连通性测试保持不变
- `to_email_meta()` 返回时包含 `provider`

#### 4.1.4 前端邮箱设置页面改造

- 增加"邮件服务商"下拉选择（通用 SMTP / 阿里云 SMTP）
- 选择阿里云时，自动填充 host/port/tls/ssl 并隐藏/只读这些字段，仅显示：
  - 发信地址
  - SMTP 密码
- 选择通用 SMTP 时，展示完整表单
- 向后兼容：读取无 `provider` 的旧配置时，默认展示通用 SMTP

### 4.2 登录认证设置扩展

`auth_setting` 表的 `param_value` JSON 扩展两个字段：

```json
{
  "max_attempts": 3,
  "login_email_verification_enabled": true,
  "login_email_verification_scope": "ALL"
}
```

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `login_email_verification_enabled` | bool | `false` | 是否启用登录邮箱验证码 |
| `login_email_verification_scope` | string | `"ALL"` | `ALL`（全部用户）/ `ADMIN`（仅管理员需要，普通用户跳过） |

### 4.3 登录流程改造

#### 4.3.1 两阶段登录流程

**阶段一：预登录校验**

请求：
```json
{
  "username": "admin",
  "password": "xxx",
  "captcha": "abc12"
}
```

后端处理：
1. 校验用户名、密码
2. 校验图片验证码（如系统配置需要）
3. 读取 `auth_setting`，判断该用户是否需要邮箱验证码：
   - 若 `enabled=false` → 不需要
   - 若用户是**内置系统管理员** → 不需要（硬编码逃生舱）
   - 若 `scope=ALL` → 需要
   - 若 `scope=ADMIN` 且用户角色为 ADMIN → 需要
   - 若 `scope=ADMIN` 且用户角色为普通用户 → 不需要
   - 不需要验证码 → 直接返回 token
   - 需要验证码：
     a. 查找 `User.email`
     b. 防刷检查（60 秒锁）
     c. 生成 6 位数字验证码
     d. 缓存验证码 5 分钟（key：`{email}:login_email`）
     e. 调用 `send_mail` 发送验证码邮件
     f. 返回错误码 `1001`：需要邮箱验证码

**阶段二：完整登录**

请求：
```json
{
  "username": "admin",
  "password": "xxx",
  "captcha": "abc12",
  "email_code": "123456"
}
```

后端处理：
1. 校验用户名、密码
2. 校验图片验证码（如需要）
3. 校验 `email_code`：
   - 查缓存 `{email}:login_email`
   - 正确 → 继续生成 token
   - 错误 → 返回错误码 `1005`（验证码错误或过期）

#### 4.3.2 错误码定义

| 错误码 | 场景 | 前端行为 |
|--------|------|----------|
| `1001` | 需要邮箱验证码 | 显示邮箱验证码输入框 |
| `1005` | 邮箱验证码错误或已过期 | 提示用户重新输入 |
| `500` | 用户未绑定邮箱 / 邮件服务未配置 | 显示错误提示 |

### 4.4 验证码发送逻辑

复用现有 `SendEmailSerializer` 的核心逻辑，抽取通用方法：

- 新增 `send_email_code(email, code_type)` 工具方法
- 支持 `code_type`：`login_email` | `register` | `reset_password`
- 防刷：60 秒发送间隔锁（`{email}:{type}_lock`）
- 有效期：5 分钟
- 邮件模板：复用现有 `email_template_{locale}.html`，标题适配为"登录验证码"

### 4.5 前端登录页面改造

**交互状态：**

```
┌─────────────────────────────┐
│  用户名: [___________]       │
│  密码:   [___________]       │
│  图片验证码: [___] [图]        │  ← 如系统配置需要
├─────────────────────────────┤
│  邮箱验证码: [______]         │  ← 初始隐藏，收到1001后显示
│              [已发送至邮箱]    │
├─────────────────────────────┤
│      [ 登 录 ]               │
└─────────────────────────────┘
```

**前端逻辑：**
- `needEmailCode`：收到 `1001` 时设为 `true`
- `emailCode`：用户输入的验证码
- 登录按钮始终可用，根据 `needEmailCode` 决定是否携带 `email_code`

## 5. 逃生舱机制（内置系统管理员豁免）

**内置系统管理员**（ID：`f0dd8f71-e4ee-11ee-8c84-a8a1595801ab`）**始终豁免邮箱验证码**，无论 `login_email_verification_enabled` 和 `login_email_verification_scope` 如何配置。

理由：
- 防止邮件服务配置错误或故障时，管理员被完全锁在系统外
- 该用户仍然受图片验证码规则约束（如有）
- 这是系统的最后保障机制

## 6. 边界情况与错误处理

| 场景 | 处理 |
|------|------|
| 用户未绑定邮箱 | 返回错误：请联系管理员绑定邮箱 |
| 邮件服务未配置 | 返回错误：邮件服务未配置，无法发送验证码 |
| 邮箱验证码输错 | 返回错误：验证码错误，不重置图片验证码 |
| 连续输错邮箱验证码 | 保留 `record_login_fail` 计数 |
| 发送后用户刷新页面 | 验证码缓存 5 分钟，可继续输入 |
| 60 秒内重复触发 | 受发送锁保护，返回剩余等待时间 |
| 内置管理员登录 | 直接跳过邮箱验证码校验 |

## 7. 涉及文件清单

### 后端
- `apps/system_manage/serializers/email_setting.py` — 邮件设置序列化器扩展
- `apps/system_manage/views/email_setting.py` — 无改动（已有接口兼容）
- `apps/users/serializers/login.py` — 登录序列化器改造
- `apps/users/serializers/user.py` — 验证码发送逻辑抽取
- `apps/common/template/email_template_*.html` — 邮件标题适配

### 前端
- 邮箱设置页面 — 增加服务商选择和动态表单
- 登录认证设置页面 — 增加邮箱验证码开关和范围选择
- 登录页面 — 增加邮箱验证码输入框和两阶段交互

## 8. 测试策略

| 测试项 | 方法 |
|--------|------|
| 邮件设置保存（阿里云/通用SMTP） | 单元测试：验证序列化器正确性 |
| 邮件发送连通性 | 集成测试：调用测试邮件接口 |
| 登录两阶段流程 | 集成测试：模拟带/不带 email_code 的请求 |
| 防刷机制 | 单元测试：验证 60 秒锁和 5 分钟过期 |
| 内置管理员豁免 | 单元测试：硬编码 ID 用户始终跳过 |
| 前端交互 | 手动测试：验证状态切换和错误提示 |
