# 阿里云SMTP对接与登录邮箱验证码 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 MaxKB 系统中对接阿里云 DirectMail SMTP，并增加登录邮箱验证码功能，支持管理员配置启用范围，内置系统管理员始终豁免。

**Architecture:** 后端复用 Django EmailBackend 走 SMTP 统一通道，前端通过 provider 切换自动填充阿里云参数。登录流程复用 `/user/login` 接口，通过 `email_code` 有无区分两阶段，错误码 `1001` 触发前端显示验证码输入框。

**Tech Stack:** Django 4.x, Django REST Framework, Vue 3 + TypeScript + Element Plus, Pinia, Redis Cache

---

## File Structure

| File | Responsibility |
|------|---------------|
| `apps/system_manage/serializers/email_setting.py` | 邮件设置序列化器：增加 `provider` 字段，阿里云/通用SMTP配置校验与存储 |
| `apps/users/serializers/user.py` | 抽取通用 `send_email_code()` 工具方法，支持 `login_email` 类型 |
| `apps/users/serializers/login.py` | 登录序列化器：扩展 `LoginRequest` 增加 `email_code`，改造 `login()` 实现两阶段流程 |
| `apps/users/api/login.py` | 登录API定义：扩展 `LoginRequest` 的 OpenAPI schema |
| `apps/common/constants/exception_code_constants.py` | 新增 `NEED_EMAIL_VERIFICATION(1001)` 错误码 |
| `ui/src/api/type/login.ts` | 前端类型：扩展 `LoginRequest` 增加 `email_code?: string` |
| `ui/src/views/system-setting/email/index.vue` | 邮箱设置页面：增加服务商下拉和动态表单 |
| `ui/src/views/system-setting/authentication/component/Setting.vue` | 登录认证设置：增加邮箱验证码开关和范围选择 |
| `ui/src/views/login/index.vue` | 登录页面：增加邮箱验证码输入框和两阶段交互 |
| `ui/src/locales/lang/*/views/system.ts` | 新增国际化文本（中英文） |

---

## Task 1: 后端 — 邮件设置序列化器扩展 provider 字段

**Files:**
- Modify: `apps/system_manage/serializers/email_setting.py`

- [ ] **Step 1: 修改 `EmailSettingSerializer.Create`，增加 `provider` 字段**

```python
class EmailSettingSerializer(serializers.Serializer):
    # ... existing one() method unchanged ...

    class Create(serializers.Serializer):
        provider = serializers.ChoiceField(
            required=False,
            choices=['smtp', 'aliyun'],
            default='smtp',
            label=_('Email Provider')
        )
        email_host = serializers.CharField(required=True, label=_('SMTP host'))
        email_port = serializers.IntegerField(required=True, label=_('SMTP port'))
        email_host_user = serializers.CharField(required=True, label=_('Sender\'s email'))
        email_host_password = serializers.CharField(required=True, label=_('Password'))
        email_use_tls = serializers.BooleanField(required=True, label=_('Whether to enable TLS'))
        email_use_ssl = serializers.BooleanField(required=True, label=_('Whether to enable SSL'))
        from_email = serializers.EmailField(required=True, label=_('Sender\'s email'))

        def is_valid(self, *, raise_exception=False):
            super().is_valid(raise_exception=True)
            try:
                EmailBackend(self.data.get("email_host"),
                             self.data.get("email_port"),
                             self.data.get("email_host_user"),
                             self.data.get("email_host_password"),
                             self.data.get("email_use_tls"),
                             False,
                             self.data.get("email_use_ssl")
                             ).open()
            except Exception as e:
                porsche_logger.error(f'Exception: {e}')
                raise AppApiException(1004, _('Email verification failed'))

        def update_or_save(self):
            self.is_valid(raise_exception=True)
            system_setting = QuerySet(SystemSetting).filter(type=SettingType.EMAIL.value).first()
            if system_setting is None:
                system_setting = SystemSetting(type=SettingType.EMAIL.value)
            system_setting.meta = self.to_email_meta()
            system_setting.save()
            return system_setting.meta

        def to_email_meta(self):
            return {
                'provider': self.data.get('provider', 'smtp'),
                'email_host': self.data.get('email_host'),
                'email_port': self.data.get('email_port'),
                'email_host_user': self.data.get('email_host_user'),
                'email_host_password': self.data.get('email_host_password'),
                'email_use_tls': self.data.get('email_use_tls'),
                'email_use_ssl': self.data.get('email_use_ssl'),
                'from_email': self.data.get('from_email')
            }
```

- [ ] **Step 2: Commit**

```bash
git add apps/system_manage/serializers/email_setting.py
git commit -m "feat(email): add provider field to email setting serializer"
```

---

## Task 2: 后端 — 抽取通用验证码发送工具

**Files:**
- Modify: `apps/users/serializers/user.py`

- [ ] **Step 1: 在 `SendEmailSerializer` 同级位置新增 `send_email_code()` 函数**

```python
# Add near the top of user.py, after existing imports and before SendEmailSerializer

from django.utils.translation import get_language, to_locale


def send_email_code(email: str, code_type: str, state_label: str = '') -> str:
    """
    通用邮箱验证码发送工具
    :param email: 接收邮箱
    :param code_type: 验证码类型，如 'login_email', 'register', 'reset_password'
    :param state_label: 邮件标题中的动作描述
    :return: 生成的验证码
    """
    version, get_key = Cache_Version.SYSTEM.value
    
    # 生成随机验证码
    code = "".join(list(map(lambda i: random.choice([
        '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'
    ]), range(6))))
    
    # 获取邮件模板
    language = get_language()
    template_path = os.path.join(
        PROJECT_DIR, "apps", "common", 'template',
        f'email_template_{to_locale(language)}.html'
    )
    with open(template_path, "r", encoding='utf-8') as file:
        content = file.read()
    
    code_cache_key = email + ":" + code_type
    code_cache_key_lock = code_cache_key + "_lock"
    
    # 设置发送锁（60秒）
    cache.set(get_key(code_cache_key_lock), code, timeout=60, version=version)
    
    system_setting = QuerySet(SystemSetting).filter(type=SettingType.EMAIL.value).first()
    if system_setting is None:
        cache.delete(get_key(code_cache_key_lock), version=version)
        raise AppApiException(1004,
            _("The email service has not been set up. Please contact the administrator to set up the email service in [Email Settings]."))
    
    try:
        connection = EmailBackend(
            system_setting.meta.get("email_host"),
            system_setting.meta.get('email_port'),
            system_setting.meta.get('email_host_user'),
            system_setting.meta.get('email_host_password'),
            system_setting.meta.get('email_use_tls'),
            False,
            system_setting.meta.get('email_use_ssl')
        )
        action_label = state_label or (_('User registration') if code_type == 'register' else _('Change password'))
        send_mail(
            _('【Intelligent knowledge base question and answer system-{action}】').format(action=action_label),
            '',
            html_message=f'{content.replace("${code}", code)}',
            from_email=system_setting.meta.get('from_email'),
            recipient_list=[email],
            fail_silently=False,
            connection=connection
        )
    except Exception as e:
        cache.delete(get_key(code_cache_key_lock), version=version)
        raise AppApiException(500, f"{str(e)}" + _("Email sending failed"))
    
    # 设置验证码缓存（5分钟）
    cache.set(get_key(code_cache_key), code, timeout=60 * 5, version=version)
    return code
```

- [ ] **Step 2: 将 `SendEmailSerializer.send()` 改为调用新工具**

```python
class SendEmailSerializer(serializers.Serializer):
    # ... existing fields and is_valid() unchanged ...

    def send(self):
        email = self.data.get("email")
        state = self.data.get("type")
        state_label = _('User registration') if state == 'register' else _('Change password')
        send_email_code(email, state, state_label)
        return True
```

- [ ] **Step 3: Commit**

```bash
git add apps/users/serializers/user.py
git commit -m "refactor(email): extract send_email_code utility for reuse"
```

---

## Task 3: 后端 — 登录序列化器两阶段流程改造

**Files:**
- Modify: `apps/users/serializers/login.py`
- Modify: `apps/common/constants/exception_code_constants.py`

- [ ] **Step 1: 在 `exception_code_constants.py` 新增 `NEED_EMAIL_VERIFICATION` 错误码**

```python
# In ExceptionCodeConstants enum, add after existing codes:
NEED_EMAIL_VERIFICATION = ExceptionCode(1001, _('Email verification code is required'))
```

- [ ] **Step 2: 扩展 `LoginRequest` 增加 `email_code` 字段**

```python
class LoginRequest(serializers.Serializer):
    username = serializers.CharField(required=True, max_length=64, help_text=_("Username"), label=_("Username"))
    password = serializers.CharField(required=True, max_length=128, label=_("Password"))
    captcha = serializers.CharField(required=False, max_length=64, label=_('captcha'), allow_null=True,
                                    allow_blank=True)
    encryptedData = serializers.CharField(required=False, label=_('encryptedData'), allow_null=True,
                                          allow_blank=True)
    email_code = serializers.CharField(required=False, max_length=6, label=_('Email verification code'),
                                       allow_null=True, allow_blank=True)
```

- [ ] **Step 3: 在 `LoginSerializer.login()` 中增加两阶段逻辑和邮箱验证码校验**

```python
class LoginSerializer(serializers.Serializer):
    # ... existing get_auth_setting() unchanged ...

    @staticmethod
    def _is_builtin_admin(user):
        """判断是否为内置系统管理员（逃生舱）"""
        return str(user.id) == 'f0dd8f71-e4ee-11ee-8c84-a8a1595801ab'

    @staticmethod
    def _need_email_verification(user, auth_setting):
        """判断该用户是否需要邮箱验证码"""
        if not auth_setting.get('login_email_verification_enabled', False):
            return False
        if LoginSerializer._is_builtin_admin(user):
            return False
        scope = auth_setting.get('login_email_verification_scope', 'ALL')
        if scope == 'ALL':
            return True
        if scope == 'ADMIN' and user.role == RoleConstants.ADMIN.name:
            return True
        return False

    @staticmethod
    def login(instance):
        username = instance.get("username", "")
        encryptedData = instance.get("encryptedData", "")
        if encryptedData:
            json_data = json.loads(decrypt(encryptedData))
            instance.update(json_data)
        try:
            LoginRequest(data=instance).is_valid(raise_exception=True)
        except Exception as e:
            record_login_fail(username)
            raise e
        auth_setting = LoginSerializer.get_auth_setting()

        max_attempts = auth_setting.get("max_attempts", 1)
        password = instance.get("password")
        captcha = instance.get("captcha", "")
        email_code = instance.get("email_code", "")

        # 判断是否需要图片验证码
        need_captcha = False
        if max_attempts == -1:
            need_captcha = False
        elif max_attempts > 0:
            fail_count = cache.get(system_get_key(f'system_{username}'), version=system_version) or 0
            need_captcha = fail_count >= max_attempts

        if need_captcha:
            if not captcha:
                raise AppApiException(1005, _("Captcha is required"))
            captcha_cache = cache.get(
                Cache_Version.CAPTCHA.get_key(captcha=f"system_{username}"),
                version=Cache_Version.CAPTCHA.get_version()
            )
            if captcha_cache is None or captcha.lower() != captcha_cache:
                raise AppApiException(1005, _("Captcha code error or expiration"))

        user = QuerySet(User).filter(username=username, password=password_encrypt(password)).first()
        if user is None:
            record_login_fail(username)
            raise AppApiException(500, _('The username or password is incorrect'))
        if not user.is_active:
            record_login_fail(username)
            raise AppApiException(1005, _("The user has been disabled, please contact the administrator!"))

        # 判断是否需要邮箱验证码
        if LoginSerializer._need_email_verification(user, auth_setting):
            if not email_code:
                # 阶段一：未提供邮箱验证码，发送验证码
                if not user.email:
                    raise AppApiException(500, _("The user has not bound an email address. Please contact the administrator."))
                try:
                    send_email_code(user.email, 'login_email', _('Login verification'))
                except AppApiException:
                    raise
                except Exception as e:
                    raise AppApiException(500, str(e))
                raise AppApiException(1001, _("Email verification code is required. Please check your email."))
            else:
                # 阶段二：校验邮箱验证码
                version, get_key = Cache_Version.SYSTEM.value
                cache_code = cache.get(get_key(f"{user.email}:login_email"), version=version)
                if cache_code is None or cache_code != email_code:
                    record_login_fail(username)
                    raise AppApiException(1005, _("Email verification code error or expiration"))
                # 校验通过，清除验证码缓存
                cache.delete(get_key(f"{user.email}:login_email"), version=version)

        cache.delete(system_get_key(f'system_{username}'), version=system_version)
        token = signing.dumps({'username': user.username,
                               'id': str(user.id),
                               'email': user.email,
                               'type': AuthenticationType.SYSTEM_USER.value})
        version, get_key = Cache_Version.TOKEN.value
        timeout = CONFIG.get_session_timeout()
        cache.set(get_key(token), user, timeout=timeout, version=version)
        return {'token': token}
```

- [ ] **Step 4: Commit**

```bash
git add apps/users/serializers/login.py apps/common/constants/exception_code_constants.py
git commit -m "feat(login): add two-phase login with email verification code"
```

---

## Task 4: 后端 — 登录API扩展 email_code

**Files:**
- Modify: `apps/users/api/login.py`

- [ ] **Step 1: 扩展 `LoginRequest` 的 API schema**

```python
class LoginRequest(serializers.Serializer):
    username = serializers.CharField(required=True, max_length=64, help_text=_("Username"), label=_("Username"))
    password = serializers.CharField(required=True, max_length=128, label=_("Password"))
    captcha = serializers.CharField(required=False, max_length=64, label=_('captcha'), allow_null=True,
                                    allow_blank=True)
    encryptedData = serializers.CharField(required=False, label=_('encryptedData'), allow_null=True,
                                          allow_blank=True)
    email_code = serializers.CharField(required=False, max_length=6, label=_('Email verification code'),
                                       allow_null=True, allow_blank=True)
```

- [ ] **Step 2: Commit**

```bash
git add apps/users/api/login.py
git commit -m "feat(api): extend LoginRequest with email_code field"
```

---

## Task 5: 前端 — 扩展 LoginRequest 类型

**Files:**
- Modify: `ui/src/api/type/login.ts`

- [ ] **Step 1: 在 `LoginRequest` 接口中增加 `email_code`**

```typescript
interface LoginRequest {
  username: string
  password: string
  captcha: string
  encryptedData?: string
  email_code?: string
}
export type { LoginRequest }
```

- [ ] **Step 2: Commit**

```bash
git add ui/src/api/type/login.ts
git commit -m "feat(types): add email_code to LoginRequest"
```

---

## Task 6: 前端 — 邮箱设置页面改造

**Files:**
- Modify: `ui/src/views/system-setting/email/index.vue`

- [ ] **Step 1: 在模板中增加服务商选择下拉框，并动态控制字段显示**

```vue
<!-- 在 <el-form> 内部，第一个表单项之前插入 -->
<el-form-item :label="$t('views.system.email.provider')" prop="provider">
  <el-select v-model="form.provider" style="width: 100%">
    <el-option label="通用 SMTP" value="smtp" />
    <el-option label="阿里云 SMTP" value="aliyun" />
  </el-select>
</el-form-item>

<!-- 修改 email_host / email_port 等字段，增加 v-show -->
<el-form-item
  v-show="form.provider === 'smtp'"
  :label="$t('views.system.email.smtpHost')"
  prop="email_host"
>
  <!-- ... 原有内容不变 ... -->
</el-form-item>

<el-form-item
  v-show="form.provider === 'smtp'"
  :label="$t('views.system.email.smtpPort')"
  prop="email_port"
>
  <!-- ... 原有内容不变 ... -->
</el-form-item>

<!-- SSL/TLS 也仅在 smtp 模式下显示 -->
<el-form-item v-show="form.provider === 'smtp'">
  <el-checkbox v-model="form.email_use_ssl">
    {{ $t('views.system.email.enableSSL') }}
  </el-checkbox>
</el-form-item>
<el-form-item v-show="form.provider === 'smtp'">
  <el-checkbox v-model="form.email_use_tls">
    {{ $t('views.system.email.enableTLS') }}
  </el-checkbox>
</el-form-item>
```

- [ ] **Step 2: 在 script setup 中增加 provider 字段和 watch 逻辑**

```typescript
const form = ref<any>({
  provider: 'smtp',
  email_host: '',
  email_port: '',
  email_host_user: '',
  email_host_password: '',
  email_use_tls: false,
  email_use_ssl: false,
  from_email: '',
})

// 监听 provider 变化，自动填充阿里云参数
watch(() => form.value.provider, (newProvider) => {
  if (newProvider === 'aliyun') {
    form.value.email_host = 'smtpdm.aliyun.com'
    form.value.email_port = '465'
    form.value.email_use_ssl = true
    form.value.email_use_tls = false
  }
})

// 向后兼容：加载无 provider 的旧配置时默认 smtp
function getDetail() {
  emailApi.getEmailSetting(loading).then((res: any) => {
    if (res.data && JSON.stringify(res.data) !== '{}') {
      form.value = {
        provider: 'smtp',
        ...res.data
      }
    }
  })
}
```

- [ ] **Step 3: Commit**

```bash
git add ui/src/views/system-setting/email/index.vue
git commit -m "feat(ui): add email provider selector with aliyun presets"
```

---

## Task 7: 前端 — 登录认证设置页面扩展

**Files:**
- Modify: `ui/src/views/system-setting/authentication/component/Setting.vue`

- [ ] **Step 1: 在模板中邮箱验证码配置项**

```vue
<!-- 在 max_attempts 表单项之后，</el-form> 之前插入 -->
<el-form-item
  :label="$t('views.system.loginEmailVerification')"
  prop="login_email_verification_enabled"
>
  <el-switch v-model="form.login_email_verification_enabled" />
</el-form-item>

<el-form-item
  v-if="form.login_email_verification_enabled"
  :label="$t('views.system.loginEmailVerificationScope')"
  prop="login_email_verification_scope"
>
  <el-radio-group v-model="form.login_email_verification_scope">
    <el-radio label="ALL">{{ $t('views.system.scopeAll') }}</el-radio>
    <el-radio label="ADMIN">{{ $t('views.system.scopeAdmin') }}</el-radio>
  </el-radio-group>
</el-form-item>
```

- [ ] **Step 2: 在 script setup 中扩展 form 和 submit**

```typescript
const form = ref<any>({
  default_value: 'LOCAL',
  max_attempts: 1,
  login_email_verification_enabled: false,
  login_email_verification_scope: 'ALL',
})

const submit = async (formEl: FormInstance | undefined) => {
  if (!formEl) return;
  await formEl.validate((valid, fields) => {
    if (valid) {
      const params = {
        default_value: form.value.default_value,
        max_attempts: form.value.max_attempts,
        login_email_verification_enabled: form.value.login_email_verification_enabled,
        login_email_verification_scope: form.value.login_email_verification_scope,
      };
      authApi.putLoginSetting(params, loading).then((res) => {
        MsgSuccess(t('common.saveSuccess'))
      })
    } else {
      console.log('error submit!', fields);
    }
  });
};
```

- [ ] **Step 3: Commit**

```bash
git add ui/src/views/system-setting/authentication/component/Setting.vue
git commit -m "feat(ui): add login email verification settings"
```

---

## Task 8: 前端 — 登录页面两阶段交互改造

**Files:**
- Modify: `ui/src/views/login/index.vue`

- [ ] **Step 1: 在模板中增加邮箱验证码输入框**

```vue
<!-- 在图片验证码 el-form-item 之后，</el-form> 之前插入 -->
<div class="mb-24" v-if="needEmailCode">
  <el-form-item prop="email_code">
    <div class="flex-between w-full">
      <el-input
        size="large"
        class="input-item"
        v-model="loginForm.email_code"
        :placeholder="$t('views.login.loginForm.emailCode.placeholder')"
      />
      <span class="ml-8 color-secondary" style="font-size: 12px; white-space: nowrap;">
        {{ $t('views.login.loginForm.emailCode.sentTip') }}
      </span>
    </div>
  </el-form-item>
</div>
```

- [ ] **Step 2: 在 script setup 中增加状态和逻辑**

```typescript
const loginForm = ref<LoginRequest>({
  username: '',
  password: '',
  captcha: '',
  email_code: '',
})

const needEmailCode = ref(false)

const loginHandle = () => {
  if (!loginFormRef.value) {
    return
  }
  loginFormRef.value.validate((valid) => {
    if (valid) {
      loading.value = true
      if (loginMode.value === 'LDAP') {
        // ... existing LDAP logic unchanged ...
      } else {
        const publicKey = forge.pki.publicKeyFromPem(user.rasKey);
        const jsonData = JSON.stringify(loginForm.value);
        const utf8Bytes = forge.util.encodeUtf8(jsonData);
        const encrypted = publicKey.encrypt(utf8Bytes, 'RSAES-PKCS1-V1_5');
        const encryptedBase64 = forge.util.encode64(encrypted);
        login
          .asyncLogin({encryptedData: encryptedBase64, username: loginForm.value.username})
          .then(() => {
            locale.value = localStorage.getItem('Porsche-locale') || getBrowserLang() || 'en-US'
            localStorage.setItem('workspace_id', 'default')
            needEmailCode.value = false
            router.push({name: 'home'})
          })
          .catch((err: any) => {
            const username = loginForm.value.username
            loading.value = false
            makeCode(username)
            // 处理 1001 需要邮箱验证码
            if (err?.code === 1001) {
              needEmailCode.value = true
            }
          })
      }
    }
  })
}

// 切换登录模式时重置 needEmailCode
function changeMode(val: string, needMessage: boolean = true) {
  loginMode.value = val === 'LDAP' ? val : ''
  needEmailCode.value = false
  // ... rest unchanged ...
}
```

- [ ] **Step 3: Commit**

```bash
git add ui/src/views/login/index.vue
git commit -m "feat(ui): two-phase login with email verification code"
```

---

## Task 9: 国际化文本补充

**Files:**
- Modify: `ui/src/locales/lang/zh-CN/views/system.ts`
- Modify: `ui/src/locales/lang/en-US/views/system.ts`

- [ ] **Step 1: 在 zh-CN 中新增文本**

```typescript
// 在 system.ts 的 system.email 下增加
provider: '邮件服务商',

// 在 system.ts 的根下增加
loginEmailVerification: '登录邮箱验证码',
loginEmailVerificationScope: '启用范围',
scopeAll: '全部用户',
scopeAdmin: '仅管理员',
```

- [ ] **Step 2: 在 en-US 中新增对应文本**

```typescript
// 在 system.ts 的 system.email 下增加
provider: 'Email Provider',

// 在 system.ts 的根下增加
loginEmailVerification: 'Login Email Verification',
loginEmailVerificationScope: 'Scope',
scopeAll: 'All Users',
scopeAdmin: 'Admin Only',
```

- [ ] **Step 3: 在登录相关的 locale 中新增邮箱验证码文本**

```typescript
// zh-CN views/login.ts
emailCode: {
  placeholder: '请输入邮箱验证码',
  sentTip: '验证码已发送至邮箱',
},

// en-US views/login.ts
emailCode: {
  placeholder: 'Enter email verification code',
  sentTip: 'Code sent to email',
},
```

- [ ] **Step 4: Commit**

```bash
git add ui/src/locales/lang/
git commit -m "feat(i18n): add email verification related translations"
```

---

## Task 10: 验证测试

- [ ] **Step 1: 启动后端服务，验证邮件设置读写**

```bash
cd /Users/lyl/all-MaxKB2
python apps/manage.py runserver
```

测试：
1. 打开邮箱设置页面，切换服务商为"阿里云 SMTP"
2. 确认 host/port/ssl/tls 自动填充
3. 保存后刷新，确认配置正确回显

- [ ] **Step 2: 验证登录认证设置读写**

1. 打开登录认证设置页面
2. 开启"登录邮箱验证码"开关
3. 选择范围（全部用户/仅管理员）
4. 保存后刷新，确认配置正确回显

- [ ] **Step 3: 验证两阶段登录流程**

1. 使用一个开启了邮箱验证码的账户登录
2. 输入用户名密码，点击登录
3. 确认收到 `1001` 错误，页面显示邮箱验证码输入框
4. 检查邮箱是否收到验证码邮件
5. 输入正确的验证码，确认登录成功
6. 输入错误的验证码，确认收到错误提示

- [ ] **Step 4: 验证内置管理员豁免**

1. 使用内置系统管理员（ID: f0dd8f71-e4ee-11ee-8c84-a8a1595801ab）登录
2. 确认即使开启了邮箱验证码，也能直接登录

- [ ] **Step 5: Commit 最终验证通过**

```bash
git log --oneline -10
```

---

## Self-Review Checklist

| Spec 需求 | 对应任务 |
|-----------|----------|
| 邮件配置支持 provider 切换 | Task 1, 6 |
| 阿里云 SMTP 自动填充参数 | Task 6 |
| 登录认证设置扩展两个字段 | Task 7 |
| 登录两阶段流程（1001 错误码） | Task 3, 8 |
| 邮箱验证码发送（60秒锁/5分钟过期） | Task 2, 3 |
| 内置管理员豁免 | Task 3 |
| 向后兼容（旧配置默认 smtp） | Task 1, 6 |
| 图片验证码与邮箱验证码并存 | Task 3 |

**Placeholder scan:** 无 TBD/TODO/模糊描述。
**Type consistency:** `email_code` 在后端 (CharField max_length=6)、前端 (string | undefined)、API 类型中一致。`provider` 在序列化器 (choices) 和前端 (select value) 中一致。
