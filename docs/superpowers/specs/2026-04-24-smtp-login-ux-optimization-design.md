# SMTP 登录体验优化设计文档

**日期**: 2026-04-24  
**状态**: 待审核  
**方案**: 方案 A - 轻量优化

---

## 1. 问题陈述

当前 SMTP 邮箱验证码登录流程存在三个核心痛点：

1. **突然性**: 用户输入账号密码后，突然弹出"验证码已发送"，没有预期
2. **不可控**: 验证码发送后无法重新发送，邮件丢失或延迟时用户无计可施
3. **流程断裂**: 需要两步操作才能完成登录，缺少状态引导

## 2. 设计目标

在保持现有两步登录流程不变的基础上，优化用户体验：

- ✅ 显示脱敏邮箱地址（如 `y***n@capgemini.com`）
- ✅ 60 秒倒计时 + 重发按钮
- ✅ 验证码输入框直接显示
- ✅ 友好的状态提示和错误处理

## 3. 架构概述

### 3.1 核心数据流

```
用户输入账号密码 → 后端验证成功 → 检查需要邮箱验证
  ↓
后端发送验证码 → 返回 1009 错误码 + 邮箱地址（脱敏）
  ↓
前端显示验证码输入框 + 邮箱提示 + 倒计时 + 重发按钮
  ↓
用户输入验证码 → 调用同一登录接口（带 email_code）
  ↓
后端验证成功 → 返回 Token → 登录完成
```

### 3.2 关键改动点

| 模块 | 改动内容 | 影响范围 |
|------|---------|---------|
| 后端登录接口 | 1009 错误响应中增加 `masked_email` 字段 | `apps/users/serializers/login.py` |
| 后端重发接口 | 新增 `/api/user/login/resend_email_code` 接口 | `apps/users/views/` |
| 前端登录页 | 添加邮箱提示、重发按钮、倒计时 | `ui/src/views/login/index.vue` |

## 4. 后端详细设计

### 4.1 登录接口改造 (1009 错误响应增强)

**文件**: `apps/users/serializers/login.py` (第 161 行附近)

**改动**: 当返回 1009 错误时，附加脱敏邮箱地址

```python
# 改造前
raise AppApiException(1009, _("Verification code has been sent..."))

# 改造后
masked_email = mask_email(user.email)  # 例如: y***n@capgemini.com
raise AppApiException(
    1009, 
    _("Verification code has been sent..."),
    extra_data={"masked_email": masked_email}
)
```

**异常响应格式**:
```json
{
  "code": 1009,
  "message": "验证码已发送到您的邮箱，请输入验证码完成登录",
  "data": {
    "masked_email": "y***n@capgemini.com"
  }
}
```

### 4.2 新增重发验证码接口

**路由**: `POST /api/user/login/resend_email_code`

**请求体**:
```json
{
  "username": "superAdministrator"
}
```

**成功响应** (200):
```json
{
  "code": 200,
  "message": "验证码已重新发送",
  "data": {
    "masked_email": "y***n@capgemini.com",
    "cooldown_seconds": 60
  }
}
```

**错误场景**:
- 用户无邮箱绑定 → 500 错误
- 60 秒内重发 → 429 Too Many Requests
- 登录验证未激活 → 400 错误

### 4.3 邮箱脱敏工具函数

**位置**: `apps/common/utils/email.py` (新建)

```python
def mask_email(email: str) -> str:
    """脱敏邮箱地址"""
    parts = email.split('@')
    if len(parts) != 2:
        return email
    local, domain = parts
    if len(local) <= 2:
        masked_local = local[0] + '*'
    else:
        masked_local = local[0] + '*' * (len(local) - 2) + local[-1]
    return f"{masked_local}@{domain}"
```

**示例**:
- `admin@example.com` → `a***n@example.com`
- `yi@capgemini.com` → `y*@capgemini.com`

### 4.4 异常码扩展

**文件**: `apps/common/exception/exception.py`

新增错误码：
- `1010` - `验证码发送过于频繁，请 60 秒后重试`
- `1011` - `用户未绑定邮箱，无法发送验证码`

## 5. 前端详细设计

### 5.1 登录页面改造

**文件**: `ui/src/views/login/index.vue`

#### 新增状态变量

```typescript
const emailVerificationState = ref({
  active: false,           // 是否激活邮箱验证模式
  maskedEmail: '',         // 脱敏邮箱地址
  countdown: 0,            // 倒计时秒数
  canResend: false,        // 是否可以重发
  loading: false,          // 重发按钮加载状态
})
```

#### 界面结构

```vue
<div class="mb-24" v-if="emailVerificationState.active">
  <!-- 邮箱提示区域 -->
  <div class="email-notice-card">
    <el-icon><Message /></el-icon>
    <div class="notice-content">
      <p class="notice-text">
        验证码已发送至 <strong>{{ emailVerificationState.maskedEmail }}</strong>
      </p>
      <div class="resend-area">
        <span v-if="emailVerificationState.countdown > 0" class="countdown-text">
          {{ emailVerificationState.countdown }}s 后可重发
        </span>
        <el-button 
          v-else 
          size="small" 
          type="primary" 
          link
          @click="resendEmailCode"
          :loading="emailVerificationState.loading"
        >
          重新发送验证码
        </el-button>
      </div>
    </div>
  </div>

  <!-- 验证码输入框 -->
  <el-form-item prop="email_code">
    <el-input 
      v-model="loginForm.email_code"
      placeholder="请输入 6 位验证码"
      maxlength="6"
    />
  </el-form-item>

  <!-- 完成登录按钮 -->
  <el-button 
    type="primary" 
    class="w-full" 
    @click="completeLoginHandle"
    :loading="loading"
  >
    完成登录
  </el-button>
</div>
```

#### 关键方法

```typescript
// 处理 1009 错误 - 激活邮箱验证模式
const handleEmailVerification = (err: any) => {
  if (err?.code === 1009) {
    emailVerificationState.value = {
      active: true,
      maskedEmail: err?.data?.masked_email || '',
      countdown: 60,
      canResend: false,
      loading: false,
    }
    startCountdown()
  }
}

// 倒计时逻辑
const startCountdown = () => {
  const timer = setInterval(() => {
    if (emailVerificationState.value.countdown > 0) {
      emailVerificationState.value.countdown--
    } else {
      emailVerificationState.value.canResend = true
      clearInterval(timer)
    }
  }, 1000)
}

// 重发验证码
const resendEmailCode = async () => {
  emailVerificationState.value.loading = true
  try {
    await loginApi.resendEmailCode({ 
      username: loginForm.value.username 
    })
    ElMessage.success('验证码已重新发送')
    emailVerificationState.value.countdown = 60
    emailVerificationState.value.canResend = false
    startCountdown()
  } catch (err: any) {
    ElMessage.error(err?.message || '重发失败，请稍后重试')
  } finally {
    emailVerificationState.value.loading = false
  }
}

// 完成登录（提交验证码）
const completeLoginHandle = () => {
  loading.value = true
  login
    .asyncLogin({ 
      encryptedData: encryptLoginForm(loginForm.value),
      username: loginForm.value.username 
    })
    .then(() => {
      router.push({ name: 'home' })
    })
    .catch((err: any) => {
      loading.value = false
      if (err?.code === 1005) {
        ElMessage.error('验证码错误或已过期')
      }
    })
}
```

#### 新增 API 调用

**文件**: `ui/src/api/login.ts`

```typescript
export const resendEmailCode = (data: { username: string }) => {
  return request.post('/api/user/login/resend_email_code', data)
}
```

### 5.2 样式设计

```css
.email-notice-card {
  display: flex;
  gap: 12px;
  padding: 16px;
  background: #f0f7ff;
  border-left: 4px solid #409eff;
  border-radius: 8px;
  margin-bottom: 20px;
}

.notice-content {
  flex: 1;
}

.notice-text {
  margin: 0 0 8px 0;
  font-size: 14px;
  color: #333;
}

.resend-area {
  display: flex;
  align-items: center;
  gap: 8px;
}

.countdown-text {
  font-size: 13px;
  color: #909399;
}
```

## 6. 状态管理和错误处理

### 6.1 状态流转图

```
初始状态: emailVerificationState.active = false

用户输入账号密码登录
  ↓
收到 1009 错误
  ↓
状态转换: active = true, maskedEmail = "y***n@capgemini.com"
         countdown = 60, canResend = false
  ↓
启动倒计时 (每秒递减)
  ↓
countdown = 0 → canResend = true (显示"重新发送"按钮)
  ↓
用户点击"重新发送"
  ↓
调用 POST /api/user/login/resend_email_code
  ↓
成功: countdown = 60, canResend = false (重新开始倒计时)
失败: 显示错误提示 (不改变状态)
  ↓
用户输入验证码 → 点击"完成登录"
  ↓
成功: 跳转首页
失败: 显示错误 (保持当前状态)
```

### 6.2 错误处理策略

| 场景 | 后端错误码 | 前端处理 | 用户提示 |
|------|-----------|---------|---------|
| 验证码错误 | 1005 | 保持表单，清空验证码输入 | "验证码错误或已过期，请重新输入" |
| 用户无邮箱 | 500 | 隐藏验证码区域，显示联系管理员提示 | "您未绑定邮箱，请联系管理员" |
| 60 秒内重发 | 429 | 保持倒计时，禁用重发按钮 | "验证码发送过于频繁，请 X 秒后重试" |
| 验证码已过期 | 1005 | 提示重新获取验证码 | "验证码已过期，请重新获取" |
| SMTP 发送失败 | 500 | 显示重试按钮 | "邮件发送失败，请稍后重试" |

### 6.3 国际化支持

**文件**: `ui/src/locales/zh-CN/login.json`

```json
{
  "emailVerification": {
    "sentTo": "验证码已发送至",
    "resendButton": "重新发送验证码",
    "countdown": "{seconds}s 后可重发",
    "resendSuccess": "验证码已重新发送",
    "resendFailed": "重发失败，请稍后重试",
    "codeError": "验证码错误或已过期",
    "noEmailBound": "您未绑定邮箱，请联系管理员",
    "tooFrequent": "验证码发送过于频繁",
    "completeLogin": "完成登录"
  }
}
```

### 6.4 边界条件处理

**组件卸载时清理**:
```typescript
onUnmounted(() => {
  // 清理倒计时定时器
  if (countdownTimer.value) {
    clearInterval(countdownTimer.value)
  }
  // 重置状态
  emailVerificationState.value.active = false
})
```

**页面刷新/重新加载**:
- 如果用户刷新页面，`emailVerificationState` 会重置为初始状态
- 用户需要重新登录（这是可接受的，因为验证码本身有 5 分钟有效期）

**并发登录请求**:
- 如果用户在倒计时期间多次点击"完成登录"，`loading` 状态会防止并发请求
- 后端有锁机制防止重复发送验证码

### 6.5 安全考量

| 风险 | 缓解措施 |
|------|---------|
| 暴力破解验证码 | 后端已有失败次数限制 (max_attempts) |
| 邮箱枚举攻击 | 脱敏邮箱地址，不暴露完整邮箱 |
| 重放攻击 | 验证码 5 分钟过期，使用后立即删除 |
| 频繁发送垃圾邮件 | 60 秒倒计时 + 后端锁机制 |

## 7. 实施清单

### 后端
- [ ] 创建 `apps/common/utils/email.py` - 邮箱脱敏工具函数
- [ ] 修改 `apps/users/serializers/login.py` - 1009 错误响应增加 `masked_email`
- [ ] 新增重发接口 `POST /api/user/login/resend_email_code`
- [ ] 扩展异常码 (1010, 1011)

### 前端
- [ ] 修改 `ui/src/views/login/index.vue` - 添加邮箱验证 UI
- [ ] 修改 `ui/src/api/login.ts` - 新增 `resendEmailCode` API
- [ ] 添加国际化文案 `ui/src/locales/zh-CN/login.json`
- [ ] 添加样式 (email-notice-card 等)

## 8. 测试策略

### 功能测试
1. 用户登录 → 收到 1009 错误 → 显示脱敏邮箱和验证码输入框
2. 60 秒倒计时正常工作
3. 倒计时结束后可点击重发按钮
4. 重发成功后重新计时
5. 输入正确验证码 → 登录成功
6. 输入错误验证码 → 显示错误提示

### 边界测试
1. 用户无邮箱绑定 → 显示联系管理员提示
2. 60 秒内尝试重发 → 显示频率限制提示
3. SMTP 服务异常 → 显示发送失败提示
4. 验证码过期 (5 分钟) → 提示重新获取

### 兼容性测试
- 已启用/未启用邮箱验证的场景
- 管理员/普通用户角色
- 不同浏览器和移动端

---

**审核状态**: 待用户审核  
**下一步**: 用户审核通过后，调用 writing-plans 技能创建实施计划
