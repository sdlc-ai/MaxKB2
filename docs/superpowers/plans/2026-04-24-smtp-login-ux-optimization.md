# SMTP 登录体验优化实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 优化 SMTP 邮箱验证码登录流程，添加脱敏邮箱显示、倒计时、重发按钮和友好提示

**Architecture:** 后端增强 1009 错误响应并新增重发接口，前端添加邮箱验证 UI 组件和状态管理

**Tech Stack:** Django 5.2 (Python 3.11), Vue 3 + TypeScript, Element Plus

---

## 文件结构映射

### 新建文件
- `apps/common/utils/email.py` - 邮箱脱敏工具函数
- `apps/users/views/login_resend.py` - 重发验证码视图
- `apps/users/serializers/login_resend.py` - 重发验证码序列化器

### 修改文件
- `apps/common/exception/app_exception.py` - 添加 extra_data 支持
- `apps/common/exception/handle_exception.py` - 处理 extra_data 字段
- `apps/common/handle/handle_exception.py` - 处理 extra_data 字段
- `apps/users/serializers/login.py` - 1009 错误响应增加 masked_email
- `apps/users/urls.py` - 注册重发接口路由
- `ui/src/api/user/login.ts` - 新增 resendEmailCode API
- `ui/src/views/login/index.vue` - 添加邮箱验证 UI
- `ui/src/locales/zh-CN/views/login.ts` - 添加国际化文案

---

### Task 1: 邮箱脱敏工具函数

**Files:**
- Create: `apps/common/utils/email.py`
- Test: `apps/common/tests/test_email_utils.py`

- [ ] **Step 1: Write the failing test**

```python
# apps/common/tests/test_email_utils.py
from django.test import TestCase
from common.utils.email import mask_email


class MaskEmailTest(TestCase):
    def test_normal_email(self):
        """测试普通邮箱脱敏"""
        result = mask_email("admin@example.com")
        self.assertEqual(result, "a***n@example.com")
    
    def test_short_email(self):
        """测试短邮箱脱敏（<=2 字符）"""
        result = mask_email("yi@capgemini.com")
        self.assertEqual(result, "y*@capgemini.com")
    
    def test_invalid_email(self):
        """测试无效邮箱格式（无 @ 符号）"""
        result = mask_email("invalid-email")
        self.assertEqual(result, "invalid-email")
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /Users/lyl/all-MaxKB2/apps && python manage.py test common.tests.test_email_utils -v 2`
Expected: FAIL with "ModuleNotFoundError: No module named 'common.utils.email'"

- [ ] **Step 3: Write minimal implementation**

```python
# apps/common/utils/email.py
# coding=utf-8

def mask_email(email: str) -> str:
    """
    脱敏邮箱地址
    
    Args:
        email: 原始邮箱地址
        
    Returns:
        脱敏后的邮箱地址，例如: admin@example.com -> a***n@example.com
        
    Examples:
        >>> mask_email("admin@example.com")
        'a***n@example.com'
        >>> mask_email("yi@capgemini.com")
        'y*@capgemini.com'
    """
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

- [ ] **Step 4: Run test to verify it passes**

Run: `cd /Users/lyl/all-MaxKB2/apps && python manage.py test common.tests.test_email_utils -v 2`
Expected: PASS (3 tests)

- [ ] **Step 5: Commit**

```bash
cd /Users/lyl/all-MaxKB2
git add apps/common/utils/email.py apps/common/tests/test_email_utils.py
git commit -m "feat: 添加邮箱脱敏工具函数 mask_email"
```

---

### Task 2: 扩展 AppApiException 支持 extra_data

**Files:**
- Modify: `apps/common/exception/app_exception.py:6-15`
- Modify: `apps/common/exception/handle_exception.py:97-98`
- Modify: `apps/common/handle/handle_exception.py:82-83`

- [ ] **Step 1: 修改 AppApiException 类支持 extra_data 参数**

```python
# apps/common/exception/app_exception.py (修改第 6-15 行)
class AppApiException(Exception):
    """
    项目内异常
    """
    status_code = status.HTTP_200_OK

    def __init__(self, code, message, extra_data=None):
        self.code = code
        self.message = message
        self.extra_data = extra_data or {}
```

- [ ] **Step 2: 修改异常处理器传递 extra_data 到 Result**

```python
# apps/common/exception/handle_exception.py (修改第 97-98 行)
# 修改前:
# if issubclass(exception_class, AppApiException):
#     return result.Result(exc.code, exc.message, response_status=exc.status_code)

# 修改后:
if issubclass(exception_class, AppApiException):
    data = exc.extra_data if exc.extra_data else None
    return result.Result(exc.code, exc.message, data=data, response_status=exc.status_code)
```

```python
# apps/common/handle/handle_exception.py (修改第 82-83 行)
# 修改前:
# if issubclass(exception_class, AppApiException):
#     return result.Result(exc.code, exc.message, response_status=exc.status_code)

# 修改后:
if issubclass(exception_class, AppApiException):
    data = exc.extra_data if exc.extra_data else None
    return result.Result(exc.code, exc.message, data=data, response_status=exc.status_code)
```

- [ ] **Step 3: 测试 extra_data 传递**

Run: 后续 Task 3 会验证此功能
Expected: 1009 错误响应包含 `data.masked_email` 字段

- [ ] **Step 4: Commit**

```bash
cd /Users/lyl/all-MaxKB2
git add apps/common/exception/app_exception.py apps/common/exception/handle_exception.py apps/common/handle/handle_exception.py
git commit -m "feat: AppApiException 支持 extra_data 字段"
```

---

### Task 3: 登录接口 1009 错误响应增强

**Files:**
- Modify: `apps/users/serializers/login.py:146-161`

- [ ] **Step 1: 修改登录接口发送验证码时返回 masked_email**

```python
# apps/users/serializers/login.py (修改第 146-161 行)
# 修改前:
# if not email_code:
#     # 阶段一：未提供邮箱验证码
#     if not user.email:
#         raise AppApiException(500, _("The user has not bound an email address. Please contact the administrator."))
#     # 检查是否已有发送锁，避免重复发送
#     lock_exists = cache.get(get_key(f"{user.email}:login_email_lock"), version=version)
#     if lock_exists is not None:
#         raise AppApiException(1009, _("Verification code has been sent. Please check your email."))
#     try:
#         from users.serializers.user import send_email_code
#         send_email_code(user.email, 'login_email', _('Login verification'), timeout=60 * 5)
#     except AppApiException:
#         raise
#     except Exception as e:
#         raise AppApiException(500, str(e))
#     raise AppApiException(1009, _("Verification code has been sent to your email. Please enter the code to complete login."))

# 修改后:
if not email_code:
    # 阶段一：未提供邮箱验证码
    if not user.email:
        raise AppApiException(1011, _("The user has not bound an email address. Please contact the administrator."))
    
    # 检查是否已有发送锁，避免重复发送
    lock_exists = cache.get(get_key(f"{user.email}:login_email_lock"), version=version)
    if lock_exists is not None:
        raise AppApiException(1010, _("Verification code sending too frequent, please try again later."))
    
    try:
        from users.serializers.user import send_email_code
        from common.utils.email import mask_email
        send_email_code(user.email, 'login_email', _('Login verification'), timeout=60 * 5)
    except AppApiException:
        raise
    except Exception as e:
        raise AppApiException(500, str(e))
    
    # 返回脱敏邮箱地址
    masked_email = mask_email(user.email)
    raise AppApiException(
        1009, 
        _("Verification code has been sent to your email. Please enter the code to complete login."),
        extra_data={"masked_email": masked_email}
    )
```

**注意**：此步骤同时将原有 500 错误码改为 1011（用户无邮箱），1009 锁存在改为 1010（频繁发送），以便前端区分错误类型。

- [ ] **Step 2: Commit**

```bash
cd /Users/lyl/all-MaxKB2
git add apps/users/serializers/login.py
git commit -m "feat: 登录接口 1009 错误响应增加 masked_email 字段"
```

---

### Task 4: 新增重发验证码接口

**Files:**
- Create: `apps/users/serializers/login_resend.py`
- Create: `apps/users/views/login_resend.py`
- Modify: `apps/users/urls.py` (添加路由)

- [ ] **Step 1: 创建重发验证码序列化器**

```python
# apps/users/serializers/login_resend.py
# coding=utf-8

from django.utils.translation import gettext_lazy as _
from django.core.cache import cache

from common.exception.app_exception import AppApiException
from users.models.user import User
from users.serializers.user import send_email_code
from common.utils.email import mask_email
from porsche.const import CONFIG
from common.db.search import QuerySet


class ResendEmailCodeSerializer:
    """重发登录邮箱验证码序列化器"""
    
    @staticmethod
    def resend_email_code(instance):
        """
        重发登录邮箱验证码
        
        Args:
            instance: {"username": "superAdministrator"}
            
        Returns:
            {"masked_email": "y***n@capgemini.com", "cooldown_seconds": 60}
        """
        username = instance.get("username", "")
        if not username:
            raise AppApiException(1005, _("Username is required"))
        
        # 查询用户
        user = QuerySet(User).filter(username=username).first()
        if user is None:
            raise AppApiException(1005, _("User not found"))
        
        # 检查是否绑定邮箱
        if not user.email:
            raise AppApiException(1011, _("The user has not bound an email address. Please contact the administrator."))
        
        # 检查发送锁
        from common.cache.cache import Cache_Version
        version, get_key = Cache_Version.SYSTEM.value
        lock_exists = cache.get(get_key(f"{user.email}:login_email_lock"), version=version)
        if lock_exists is not None:
            raise AppApiException(1010, _("Verification code sending too frequent, please try again later."))
        
        # 发送验证码
        try:
            send_email_code(user.email, 'login_email', _('Login verification'), timeout=60 * 5)
        except AppApiException:
            raise
        except Exception as e:
            raise AppApiException(500, str(e))
        
        # 返回脱敏邮箱
        masked_email = mask_email(user.email)
        return {
            "masked_email": masked_email,
            "cooldown_seconds": 60
        }
```

- [ ] **Step 2: 创建重发验证码视图**

```python
# apps/users/views/login_resend.py
# coding=utf-8

from django.views.decorators.csrf import csrf_exempt
from django.utils.translation import gettext_lazy as _

from common.handle.handle_exception import handle_exception
from common.result import result
from users.serializers.login_resend import ResendEmailCodeSerializer
import json


@csrf_exempt
@handle_exception
def resend_email_code(request):
    """
    重发登录邮箱验证码接口
    
    POST /api/user/login/resend_email_code
    Body: {"username": "superAdministrator"}
    """
    if request.method != 'POST':
        return result.error(_("Method not allowed"))
    
    try:
        request_data = json.loads(request.body.decode('utf-8'))
    except json.JSONDecodeError:
        return result.error(_("Invalid JSON format"))
    
    resend_data = ResendEmailCodeSerializer.resend_email_code(request_data)
    return result.success(resend_data)
```

- [ ] **Step 3: 注册路由**

```python
# apps/users/urls.py (在现有路由中添加)
# 查找类似这样的路由: path('user/login', ...)
# 在其后添加:
path('user/login/resend_email_code', login_resend.resend_email_code, name='resend_email_code'),
```

需要在文件顶部添加导入:
```python
from users.views import login_resend
```

- [ ] **Step 4: Commit**

```bash
cd /Users/lyl/all-MaxKB2
git add apps/users/serializers/login_resend.py apps/users/views/login_resend.py apps/users/urls.py
git commit -m "feat: 新增重发登录邮箱验证码接口"
```

---

### Task 5: 前端 API 和国际化

**Files:**
- Modify: `ui/src/api/user/login.ts` (添加 resendEmailCode 函数)
- Modify: `ui/src/locales/zh-CN/views/login.ts` (添加邮箱验证文案)

- [ ] **Step 1: 添加重发验证码 API**

```typescript
// ui/src/api/user/login.ts (在 getCaptcha 函数后添加)

/**
 * 重发登录邮箱验证码
 * @param data { username: string }
 * @param loading 接口加载器
 * @returns { masked_email: string, cooldown_seconds: number }
 */
const resendEmailCode: (data: { username: string }, loading?: Ref<boolean>) => Promise<Result<any>> = (
  data,
  loading,
) => {
  return post('/user/login/resend_email_code', data, undefined, loading)
}
```

在 export default 中添加:
```typescript
export default {
  login,
  logout,
  getCaptcha,
  resendEmailCode,  // 添加这一行
  getAuthType,
  // ... 其他保持不变
}
```

- [ ] **Step 2: 添加国际化文案**

```typescript
// ui/src/locales/zh-CN/views/login.ts
// 在文件末尾添加:

export const emailVerification = {
  sentTo: '验证码已发送至',
  resendButton: '重新发送验证码',
  countdown: '{seconds}s 后可重发',
  resendSuccess: '验证码已重新发送',
  resendFailed: '重发失败，请稍后重试',
  codeError: '验证码错误或已过期',
  noEmailBound: '您未绑定邮箱，请联系管理员',
  tooFrequent: '验证码发送过于频繁',
  completeLogin: '完成登录',
}
```

需要在文件开头的 export 中添加 emailVerification。

- [ ] **Step 3: Commit**

```bash
cd /Users/lyl/all-MaxKB2
git add ui/src/api/user/login.ts ui/src/locales/zh-CN/views/login.ts
git commit -m "feat: 前端添加重发验证码 API 和国际化文案"
```

---

### Task 6: 前端登录页面 UI 改造

**Files:**
- Modify: `ui/src/views/login/index.vue`

这是最大的任务，需要修改 Vue 组件。我将分步骤进行。

- [ ] **Step 1: 添加状态变量**

在 `const needEmailCode = ref(false)` 附近（约第 170 行），添加:

```typescript
const emailVerificationState = ref({
  active: false,           // 是否激活邮箱验证模式
  maskedEmail: '',         // 脱敏邮箱地址
  countdown: 0,            // 倒计时秒数
  canResend: false,        // 是否可以重发
  loading: false,          // 重发按钮加载状态
})
let countdownTimer: NodeJS.Timeout | null = null
```

- [ ] **Step 2: 添加倒计时和重发方法**

在 `makeCode` 函数后（约第 257 行），添加:

```typescript
// 启动倒计时
const startCountdown = () => {
  if (countdownTimer) {
    clearInterval(countdownTimer)
  }
  countdownTimer = setInterval(() => {
    if (emailVerificationState.value.countdown > 0) {
      emailVerificationState.value.countdown--
    } else {
      emailVerificationState.value.canResend = true
      if (countdownTimer) {
        clearInterval(countdownTimer)
        countdownTimer = null
      }
    }
  }, 1000)
}

// 重发验证码
const resendEmailCodeHandle = async () => {
  emailVerificationState.value.loading = true
  try {
    await loginApi.resendEmailCode({ 
      username: loginForm.value.username 
    })
    ElMessage.success(t('views.login.emailVerification.resendSuccess'))
    emailVerificationState.value.countdown = 60
    emailVerificationState.value.canResend = false
    startCountdown()
  } catch (err: any) {
    ElMessage.error(err?.message || t('views.login.emailVerification.resendFailed'))
  } finally {
    emailVerificationState.value.loading = false
  }
}

// 完成登录（提交验证码）
const completeLoginHandle = () => {
  if (!loginFormRef.value) {
    return
  }
  loginFormRef.value.validate((valid) => {
    if (valid) {
      loading.value = true
      const publicKey = forge.pki.publicKeyFromPem(user.rasKey);
      const jsonData = JSON.stringify(loginForm.value);
      const utf8Bytes = forge.util.encodeUtf8(jsonData);
      const encrypted = publicKey.encrypt(utf8Bytes, 'RSAES-PKCS1-V1_5');
      const encryptedBase64 = forge.util.encode64(encrypted);
      
      login
        .asyncLogin({ encryptedData: encryptedBase64, username: loginForm.value.username })
        .then(() => {
          locale.value = localStorage.getItem('Porsche-locale') || getBrowserLang() || 'en-US'
          localStorage.setItem('workspace_id', 'default')
          router.push({ name: 'home' })
        })
        .catch((err: any) => {
          loading.value = false
          if (err?.code === 1005) {
            ElMessage.error(t('views.login.emailVerification.codeError'))
            loginForm.value.email_code = ''
          }
        })
    }
  })
}
```

- [ ] **Step 3: 修改 1009 错误处理**

修改 catch 块中的 1009 处理（约第 239-242 行）:

```typescript
// 修改前:
// if (err?.code === 1009) {
//   needEmailCode.value = true
// }

// 修改后:
if (err?.code === 1009) {
  emailVerificationState.value = {
    active: true,
    maskedEmail: err?.data?.masked_email || '',
    countdown: 60,
    canResend: false,
    loading: false,
  }
  startCountdown()
} else if (err?.code === 1011) {
  // 用户无邮箱
  ElMessage.error(t('views.login.emailVerification.noEmailBound'))
} else if (err?.code === 1010) {
  // 频繁发送
  ElMessage.warning(t('views.login.emailVerification.tooFrequent'))
}
```

- [ ] **Step 4: 添加组件卸载清理**

在组件的 `onUnmounted` 或 `beforeUnmount` 钩子中添加（文件末尾搜索）:

```typescript
// 如果已有 onUnmounted，在其中添加:
if (countdownTimer) {
  clearInterval(countdownTimer)
  countdownTimer = null
}
emailVerificationState.value.active = false
```

如果没有，在 `</script>` 前添加:

```typescript
import { onUnmounted } from 'vue'

onUnmounted(() => {
  if (countdownTimer) {
    clearInterval(countdownTimer)
    countdownTimer = null
  }
  emailVerificationState.value.active = false
})
```

- [ ] **Step 5: 修改模板 - 邮箱验证区域**

找到原有的邮箱验证码区域（约第 59-66 行），替换为:

```vue
<!-- 邮箱验证区域（替换原有的 needEmailCode 区域） -->
<div class="mb-24" v-if="emailVerificationState.active">
  <!-- 邮箱提示卡片 -->
  <div class="email-notice-card">
    <el-icon size="20" color="#409eff"><Message /></el-icon>
    <div class="notice-content">
      <p class="notice-text">
        {{ $t('views.login.emailVerification.sentTo') }} 
        <strong>{{ emailVerificationState.maskedEmail }}</strong>
      </p>
      <div class="resend-area">
        <span v-if="emailVerificationState.countdown > 0" class="countdown-text">
          {{ $t('views.login.emailVerification.countdown', { seconds: emailVerificationState.countdown }) }}
        </span>
        <el-button 
          v-else 
          size="small" 
          type="primary" 
          link
          @click="resendEmailCodeHandle"
          :loading="emailVerificationState.loading"
        >
          {{ $t('views.login.emailVerification.resendButton') }}
        </el-button>
      </div>
    </div>
  </div>

  <!-- 验证码输入框 -->
  <el-form-item prop="email_code">
    <el-input 
      v-model="loginForm.email_code"
      :placeholder="$t('views.login.emailVerification.placeholder')"
      maxlength="6"
      size="large"
    />
  </el-form-item>

  <!-- 完成登录按钮 -->
  <el-button 
    type="primary" 
    class="w-full" 
    size="large"
    @click="completeLoginHandle"
    :loading="loading"
  >
    {{ $t('views.login.emailVerification.completeLogin') }}
  </el-button>
</div>
```

需要在 `<script>` 中添加 Message 图标导入:
```typescript
import { Message } from '@element-plus/icons-vue'
```

- [ ] **Step 6: 添加样式**

在 `<style scoped>` 末尾添加:

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
  line-height: 1.5;
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

- [ ] **Step 7: 添加 placeholder 国际化**

在 `ui/src/locales/zh-CN/views/login.ts` 的 emailVerification 对象中添加:

```typescript
placeholder: '请输入 6 位验证码',
```

- [ ] **Step 8: Commit**

```bash
cd /Users/lyl/all-MaxKB2
git add ui/src/views/login/index.vue ui/src/locales/zh-CN/views/login.ts
git commit -m "feat: 登录页面添加邮箱验证 UI、倒计时和重发功能"
```

---

## 自审检查

### 1. 规范覆盖检查
- ✅ 邮箱脱敏工具函数 - Task 1
- ✅ 1009 错误响应增强 - Task 3
- ✅ 重发验证码接口 - Task 4
- ✅ 前端邮箱验证 UI - Task 6
- ✅ 倒计时和重发按钮 - Task 6
- ✅ 国际化支持 - Task 5, 6
- ✅ 错误处理策略 - Task 3, 6

### 2. 占位符扫描
- ✅ 无 "TBD", "TODO" 等
- ✅ 所有步骤都有完整代码
- ✅ 无 "Similar to Task N"

### 3. 类型一致性
- ✅ `extra_data` 在所有异常处理中一致使用
- ✅ `masked_email` 字段名前后端一致
- ✅ API 路径 `/user/login/resend_email_code` 前后端一致
- ✅ 错误码 1009, 1010, 1011 前后端一致

---

**Plan complete and saved to** `docs/superpowers/plans/2026-04-24-smtp-login-ux-optimization.md`

Two execution options:

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

Which approach?
