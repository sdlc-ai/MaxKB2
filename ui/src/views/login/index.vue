<template>
  <login-layout v-if="!loading" v-loading="loading">
    <LoginContainer :subTitle="newDefaultSlogan">
      <h2 class="mb-24" v-if="!showQrCodeTab">{{ loginMode || $t('views.login.title') }}</h2>
      <div v-if="!showQrCodeTab">
        <!-- 步骤指示器 -->
        <div v-if="emailVerificationState.active" class="step-indicator mb-24">
          <div class="step-item completed">
            <div class="step-number">✓</div>
            <span class="step-label">{{ $t('views.login.steps.password') }}</span>
          </div>
          <div class="step-line"></div>
          <div class="step-item active">
            <div class="step-number">2</div>
            <span class="step-label">{{ $t('views.login.steps.emailVerification') }}</span>
          </div>
        </div>

        <el-form
          class="login-form"
          :rules="rules"
          :model="loginForm"
          ref="loginFormRef"
          @keyup.enter="loginHandle"
        >
          <div class="mb-24">
            <el-form-item prop="username">
              <el-input
                size="large"
                class="input-item"
                v-model="loginForm.username"
                @blur="handleUsernameBlur(loginForm.username)"
                :placeholder="$t('views.login.loginForm.username.placeholder')"
              >
              </el-input>
            </el-form-item>
          </div>
          <div class="mb-24">
            <el-form-item prop="password">
              <el-input
                type="password"
                size="large"
                class="input-item"
                v-model="loginForm.password"
                :placeholder="$t('views.login.loginForm.password.placeholder')"
                show-password
              >
              </el-input>
            </el-form-item>
          </div>
          <div class="mb-24" v-if="loginMode !== 'LDAP' && identifyCode">
            <el-form-item prop="captcha">
              <div class="flex-between w-full">
                <el-input
                  size="large"
                  class="input-item"
                  v-model="loginForm.captcha"
                  :placeholder="$t('views.login.loginForm.captcha.placeholder')"
                >
                </el-input>

                <img
                  :src="identifyCode"
                  alt=""
                  height="38"
                  class="ml-8 cursor border border-r-6"
                  @click="makeCode(loginForm.username)"
                />
              </div>
            </el-form-item>
          </div>
          <div class="mb-24" v-if="needEmailCode">
            <el-form-item prop="email_code">
              <!-- 邮箱验证提示卡片 -->
              <div class="email-verification-card" role="alert" aria-live="polite">
                <div class="email-info">
                  <span class="label">{{ $t('views.login.emailVerification.tip') }}</span>
                  <span class="email" :title="emailVerificationState.maskedEmail">{{ emailVerificationState.maskedEmail }}</span>
                </div>
                <div class="input-row">
                  <el-input
                    ref="emailCodeInputRef"
                    size="large"
                    class="input-item"
                    v-model="loginForm.email_code"
                    :placeholder="$t('views.login.emailVerification.enterCode')"
                    maxlength="6"
                    @input="handleEmailCodeInput"
                  />
                  <el-button
                    size="large"
                    type="primary"
                    class="ml-8"
                    style="white-space: nowrap;"
                    :disabled="!emailVerificationState.canResend"
                    :loading="emailVerificationState.loading"
                    @click="resendEmailCodeHandle"
                    :aria-label="emailVerificationState.canResend ? $t('views.login.emailVerification.resend') : `${emailVerificationState.countdown}${$t('views.login.emailVerification.countdown')}`"
                  >
                    <template v-if="emailVerificationState.canResend">
                      {{ $t('views.login.emailVerification.resend') }}
                    </template>
                    <template v-else>
                      {{ emailVerificationState.countdown }}{{ $t('views.login.emailVerification.countdown') }}
                    </template>
                  </el-button>
                </div>
                <div v-if="emailVerificationState.attempts > 0" class="attempts-warning mt-8">
                  <el-icon class="warning-icon"><Warning /></el-icon>
                  <span>{{ $t('views.login.emailVerification.attemptsRemaining', { count: 5 - emailVerificationState.attempts }) }}</span>
                </div>
              </div>
            </el-form-item>
          </div>
        </el-form>

        <el-button
          size="large"
          type="primary"
          class="w-full"
          @click="loginHandle"
          :loading="loading"
        >
          {{ emailVerificationState.active ? $t('views.login.emailVerification.completeLogin') : $t('views.login.buttons.login') }}
        </el-button>
        <div class="operate-container flex-between mt-12">
          <el-button
            :loading="loading"
            class="forgot-password"
            @click="router.push('/forgot_password')"
            link
            type="primary"
          >
            {{ $t('views.login.forgotPassword') }}?
          </el-button>
        </div>
      </div>
      <div v-if="showQrCodeTab">
        <QrCodeTab :tabs="orgOptions" :default-tab="defaultQrTab"/>
      </div>
      <div class="login-gradient-divider lighter mt-24" v-if="modeList.length > 1">
        <span>{{ $t('views.login.moreMethod') }}</span>
      </div>
      <div class="text-center mt-16">
        <template v-for="item in modeList">
          <el-button
            v-if="item !== '' && loginMode !== item && item !== 'QR_CODE'"
            circle
            :key="item"
            class="login-button-circle color-secondary"
            @click="changeMode(item)"
          >
            <span
              :style="{
                'font-size': item === 'OAUTH2' ? '8px' : '10px',
                color: theme.themeInfo?.theme,
              }"
            >{{ item }}</span
            >
          </el-button>
          <el-button
            v-if="item === 'QR_CODE' && loginMode !== item"
            circle
            :key="item"
            class="login-button-circle color-secondary"
            @click="changeMode('QR_CODE')"
          >
            <img src="@/assets/icon_qr_outlined.svg" width="25px"/>
          </el-button>
          <el-button
            v-if="item === '' && loginMode !== ''"
            circle
            :key="item"
            class="login-button-circle color-secondary"
            style="font-size: 24px"
            icon="UserFilled"
            @click="changeMode('')"
          />
        </template>
      </div>
    </LoginContainer>
  </login-layout>
</template>
<script setup lang="ts">
import {computed, onBeforeMount, onMounted, ref} from 'vue'
import {useRoute, useRouter} from 'vue-router'
import type {FormInstance, FormRules} from 'element-plus'
import type {LoginRequest} from '@/api/type/login'
import LoginContainer from '@/layout/login-layout/LoginContainer.vue'
import LoginLayout from '@/layout/login-layout/LoginLayout.vue'
import loginApi from '@/api/user/login'
import authApi from '@/api/system-settings/auth-setting'
import {getBrowserLang, t} from '@/locales'
import useStore from '@/stores'
import {useI18n} from 'vue-i18n'
import {ElMessage} from 'element-plus'
import {Warning} from '@element-plus/icons-vue'
import QrCodeTab from '@/views/login/scanCompinents/QrCodeTab.vue'
import {MsgConfirm, MsgError} from '@/utils/message.ts'
import * as dd from 'dingtalk-jsapi'
import {loadScript} from '@/utils/common'
import forge from 'node-forge';

const router = useRouter()
const {login, user, theme} = useStore()
const {locale} = useI18n({useScope: 'global'})
const loading = ref<boolean>(false)
const route = useRoute()
const identifyCode = ref<string>('')
const loginFormRef = ref<FormInstance>()
const emailCodeInputRef = ref<any>()
const authSetting = ref<any>(null)
const defaultQrTab = ref<string>('')
const needEmailCode = ref(false)

// 邮箱验证状态管理
const emailVerificationState = ref({
  active: false,           // 是否激活邮箱验证模式
  maskedEmail: '',         // 脱敏邮箱地址
  countdown: 0,            // 倒计时秒数
  canResend: false,        // 是否可以重发
  loading: false,          // 重发按钮加载状态
  attempts: 0,             // 验证码尝试次数
  tempToken: '',           // 临时会话令牌
})
let countdownTimer: NodeJS.Timeout | null = null

const loginForm = ref<LoginRequest>({
  username: '',
  password: '',
  captcha: '',
  email_code: '',
  temp_token: '',
})

const rules = ref<FormRules<LoginRequest>>({
  username: [
    {
      required: true,
      message: t('views.login.loginForm.username.requiredMessage'),
      trigger: 'blur',
    },
  ],
  password: [
    {
      required: true,
      message: t('views.login.loginForm.password.requiredMessage'),
      trigger: 'blur',
    },
  ],
  captcha: [
    {
      required: false,
      message: t('views.login.loginForm.captcha.requiredMessage'),
      trigger: 'blur',
    },
  ],
})

const loginHandle = () => {
  if (!loginFormRef.value) {
    return
  }
  loginFormRef.value.validate((valid) => {
    if (valid) {
      loading.value = true
      if (loginMode.value === 'LDAP') {
        login
          .asyncLdapLogin(loginForm.value)
          .then(() => {
            locale.value = localStorage.getItem('Porsche-locale') || getBrowserLang() || 'en-US'
            router.push({name: 'home'})
          })
          .catch(() => {
            loading.value = false
          })
      } else {
        const publicKey = forge.pki.publicKeyFromPem(user.rasKey);
        // 转换为UTF-8编码后再加密
        // 注意：temp_token 不参与加密，避免 RSA 加密数据过长
        const dataToEncrypt = {...loginForm.value}
        delete dataToEncrypt.temp_token
        const jsonData = JSON.stringify(dataToEncrypt);
        const utf8Bytes = forge.util.encodeUtf8(jsonData);
        const encrypted = publicKey.encrypt(utf8Bytes, 'RSAES-PKCS1-V1_5');
        const encryptedBase64 = forge.util.encode64(encrypted);
        login
          .asyncLogin({encryptedData: encryptedBase64, username: loginForm.value.username, temp_token: loginForm.value.temp_token})
          .then(() => {
            locale.value = localStorage.getItem('Porsche-locale') || getBrowserLang() || 'en-US'
            localStorage.setItem('workspace_id', 'default')
            needEmailCode.value = false
            emailVerificationState.value.active = false
            emailVerificationState.value.tempToken = ''
            loginForm.value.temp_token = ''
            // 清理定时器
            if (countdownTimer) {
              clearInterval(countdownTimer)
              countdownTimer = null
            }
            router.push({name: 'home'})
          })
          .catch((err: any) => {
            const username = loginForm.value.username
            loading.value = false
            makeCode(username)
            // 处理 1009 需要邮箱验证码
            if (err?.code === 1009) {
              const maskedEmail = err?.data?.masked_email || ''
              const tempToken = err?.data?.temp_token || ''
              if (maskedEmail && tempToken) {
                emailVerificationState.value.tempToken = tempToken
                loginForm.value.temp_token = tempToken
                activateEmailVerification(maskedEmail)
                ElMessage.info(t('views.login.emailVerification.codeSent'))
              } else {
                needEmailCode.value = true
              }
            }
            // 处理 1010 频繁发送
            else if (err?.code === 1010) {
              ElMessage.warning(t('views.login.emailVerification.tooFrequent'))
            }
            // 处理 1011 用户无邮箱
            else if (err?.code === 1011) {
              ElMessage.error(t('views.login.emailVerification.noEmailBound'))
            }
            // 处理邮箱验证码错误
            else if (err?.code === 1005 && emailVerificationState.value.active) {
              emailVerificationState.value.attempts++
              if (emailVerificationState.value.attempts >= 5) {
                ElMessage.error(t('views.login.emailVerification.maxAttemptsReached'))
                // 超过最大尝试次数，重置状态
                resetEmailVerification()
              } else {
                ElMessage.error(t('views.login.emailVerification.codeError', { attempts: 5 - emailVerificationState.value.attempts }))
                // 清空验证码输入框并重新聚焦
                loginForm.value.email_code = ''
                setTimeout(() => {
                  emailCodeInputRef.value?.focus()
                }, 100)
              }
            }
          })
      }
    }
  })
}

function makeCode(username?: string) {
  loginApi.getCaptcha(username).then((res: any) => {
    if (res && res.data && res.data.captcha) {
      identifyCode.value = res.data.captcha
    }
  }).catch((error) => {
    console.error('Failed to get captcha:', error)
  })
}

function handleUsernameBlur(username: string) {
  makeCode(username)
}

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
    emailVerificationState.value.attempts = 0  // 重置尝试次数
    startCountdown()
    // 清空输入框并重新聚焦
    loginForm.value.email_code = ''
    setTimeout(() => {
      emailCodeInputRef.value?.focus()
    }, 100)
  } catch (err: any) {
    ElMessage.error(err?.message || t('views.login.emailVerification.resendFailed'))
  } finally {
    emailVerificationState.value.loading = false
  }
}

// 重置邮箱验证状态
const resetEmailVerification = () => {
  needEmailCode.value = false
  emailVerificationState.value.active = false
  emailVerificationState.value.maskedEmail = ''
  emailVerificationState.value.countdown = 0
  emailVerificationState.value.canResend = false
  emailVerificationState.value.attempts = 0
  emailVerificationState.value.tempToken = ''
  loginForm.value.email_code = ''
  loginForm.value.temp_token = ''
  if (countdownTimer) {
    clearInterval(countdownTimer)
    countdownTimer = null
  }
}

// 邮箱验证码输入处理（只允许数字）
const handleEmailCodeInput = (value: string) => {
  const sanitizedValue = value.replace(/[^0-9]/g, '')
  loginForm.value.email_code = sanitizedValue
}

// 激活邮箱验证模式
const activateEmailVerification = (maskedEmail: string) => {
  emailVerificationState.value.active = true
  emailVerificationState.value.maskedEmail = maskedEmail
  emailVerificationState.value.countdown = 60
  emailVerificationState.value.canResend = false
  emailVerificationState.value.attempts = 0
  needEmailCode.value = true
  startCountdown()
  
  // 下一帧聚焦到邮箱验证码输入框
  setTimeout(() => {
    emailCodeInputRef.value?.focus()
  }, 100)
}

onBeforeMount(() => {
  user.asyncGetProfile().then((res) => {
    // 企业版和专业版：第三方登录
    if (user.isPE() || user.isEE()) {
      authApi.getLoginAuthSetting().then((res) => {
        if (Object.keys(res.data).length > 0) {
          authSetting.value = res.data;
        } else {
          authSetting.value = {
            max_attempts: 1,
            default_value: 'LOCAL',
          }
        }
        const params = route.query
        if (params.login_mode !== 'manual') {
          const defaultMode = authSetting.value.default_value
          if (['lark', 'wecom', 'dingtalk'].includes(defaultMode)) {
            changeMode('QR_CODE', false)
            defaultQrTab.value = defaultMode
          } else {
            changeMode(defaultMode, false)
          }
        }
      })
    } else {
      authSetting.value = {
        max_attempts: 1,
        default_value: 'LOCAL',
      }
    }
  })
})

const modeList = ref<string[]>([''])
const QrList = ref<any[]>([''])
const loginMode = ref('')
const showQrCodeTab = ref(false)

interface qrOption {
  key: string
  value: string
}

const orgOptions = ref<qrOption[]>([])

function uuidv4() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
    const r = (Math.random() * 16) | 0
    const v = c === 'x' ? r : (r & 0x3) | 0x8
    return v.toString(16)
  })
}

const newDefaultSlogan = computed(() => {
  const default_login = '强大易用的企业级智能体平台'
  if (!theme.themeInfo?.slogan || default_login == theme.themeInfo?.slogan) {
    return t('theme.defaultSlogan')
  } else {
    return theme.themeInfo?.slogan
  }
})

function redirectAuth(authType: string, needMessage: boolean = true) {
  if (authType === 'LDAP' || authType === '' || authType === 'LOCAL') {
    return
  }
  authApi.getLoginViewAuthSetting(authType, loading).then((res: any) => {
    if (!res.data || !res.data.config) {
      return
    }

    const config = res.data.config
    // 构造带查询参数的redirectUrl
    const redirectUrl = `${config.redirectUrl}`
    let url
    if (authType === 'CAS') {
      url = config.ldpUri
      url +=
        url.indexOf('?') !== -1
          ? `&service=${encodeURIComponent(redirectUrl)}`
          : `?service=${encodeURIComponent(redirectUrl)}`
    } else if (authType === 'OIDC') {
      const scope = config.scope || 'openid+profile+email'
      url = `${config.authEndpoint}?client_id=${config.clientId}&redirect_uri=${redirectUrl}&response_type=code&scope=${scope}`
      if (config.state) {
        url += `&state=${config.state}`
      }
    } else if (authType === 'OAuth2') {
      url = `${config.authEndpoint}?client_id=${config.clientId}&response_type=code&redirect_uri=${redirectUrl}&state=${uuidv4()}`
      if (config.scope) {
        url += `&scope=${config.scope}`
      }
    } else if (authType === 'SAML2') {
      loginApi.samlLogin().then((res: any) => {
        window.location.href = res.data
      })
    }
    if (!url) {
      return
    }
    if (needMessage) {
      MsgConfirm(t('views.login.jump_tip'), '', {
        confirmButtonText: t('views.login.jump'),
        cancelButtonText: t('common.cancel'),
        confirmButtonClass: '',
      })
        .then(() => {
          window.location.href = url
        })
        .catch(() => {
        })
    } else {
      console.log('url', url)
      window.location.href = url
    }
  })
}

function changeMode(val: string, needMessage: boolean = true) {
  loginMode.value = val === 'LDAP' ? val : ''
  needEmailCode.value = false
  emailVerificationState.value.active = false
  emailVerificationState.value.maskedEmail = ''
  emailVerificationState.value.countdown = 0
  emailVerificationState.value.canResend = false
  // 清理定时器
  if (countdownTimer) {
    clearInterval(countdownTimer)
    countdownTimer = null
  }
  if (val === 'QR_CODE') {
    loginMode.value = val
    showQrCodeTab.value = true
    return
  }
  showQrCodeTab.value = false
  loginForm.value = {
    username: '',
    password: '',
    captcha: '',
    email_code: '',
  }
  redirectAuth(val, needMessage)
  loginFormRef.value?.clearValidate()
}

onBeforeMount(() => {
  loading.value = true
  user.asyncGetProfile().then((res) => {
    // 企业版和专业版：第三方登录
    if (user.isPE() || user.isEE()) {
      login
        .getAuthType()
        .then((res) => {
          //如果结果包含LDAP，把LDAP放在第一个
          const ldapIndex = res.indexOf('LDAP')
          if (ldapIndex !== -1) {
            const [ldap] = res.splice(ldapIndex, 1)
            res.unshift(ldap)
          }
          modeList.value = [...modeList.value, ...res]
        })
        .finally(() => (loading.value = false))
      login
        .getQrType()
        .then((res) => {
          if (res.length > 0) {
            modeList.value = ['QR_CODE', ...modeList.value]
            QrList.value = res
            QrList.value.forEach((item) => {
              orgOptions.value.push({
                key: item,
                value:
                  item === 'wecom'
                    ? t('views.system.authentication.scanTheQRCode.wecom')
                    : item === 'dingtalk'
                      ? t('views.system.authentication.scanTheQRCode.dingtalk')
                      : t('views.system.authentication.scanTheQRCode.lark'),
              })
            })
          }
        })
        .finally(() => (loading.value = false))
    } else {
      loading.value = false
    }
  })
})
declare const window: any

onMounted(() => {
  const route = useRoute()
  const currentUrl = ref(route.fullPath)
  const params = new URLSearchParams(currentUrl.value.split('?')[1])
  const client = params.get('client')

  const handleDingTalk = () => {
    const code = params.get('corpId')
    if (code) {
      dd.runtime.permission.requestAuthCode({corpId: code}).then((res) => {
        console.log('DingTalk client request success:', res)
        login.dingOauth2Callback(res.code).then(() => {
          router.push({name: 'home'})
        })
      })
    }
  }

  const handleLark = () => {
    const appId = params.get('appId')
    const callRequestAuthCode = () => {
      window.tt?.requestAuthCode({
        appId: appId,
        success: (res: any) => {
          login.larkCallback(res.code).then(() => {
            router.push({name: 'home'})
          })
        },
        fail: (error: any) => {
          MsgError(error)
        },
      })
    }

    loadScript('https://lf-scm-cn.feishucdn.com/lark/op/h5-js-sdk-1.5.35.js', {
      jsId: 'lark-sdk',
      forceReload: true,
    })
      .then(() => {
        if (window.tt) {
          window.tt.requestAccess({
            appID: appId,
            scopeList: [],
            success: (res: any) => {
              login.larkCallback(res.code).then(() => {
                router.push({name: 'home'})
              })
            },
            fail: (error: any) => {
              const {errno} = error
              if (errno === 103) {
                callRequestAuthCode()
              }
            },
          })
        } else {
          callRequestAuthCode()
        }
      })
      .catch((error) => {
        console.error('SDK 加载失败:', error)
      })
  }

  switch (client) {
    case 'dingtalk':
      handleDingTalk()
      break
    case 'lark':
      handleLark()
      break
    default:
      break
  }
})
</script>
<style lang="scss" scoped>
.login-gradient-divider {
  position: relative;
  text-align: center;
  color: var(--el-color-info);

  ::before {
    content: '';
    width: 25%;
    height: 1px;
    background: linear-gradient(90deg, rgba(222, 224, 227, 0) 0%, #dee0e3 100%);
    position: absolute;
    left: 16px;
    top: 50%;
  }

  ::after {
    content: '';
    width: 25%;
    height: 1px;
    background: linear-gradient(90deg, #dee0e3 0%, rgba(222, 224, 227, 0) 100%);
    position: absolute;
    right: 16px;
    top: 50%;
  }
}

.login-button-circle {
  padding: 20px !important;
  margin: 0 4px;
  width: 32px;
  height: 32px;
  text-align: center;
}

.email-verification-card {
  padding: 16px;
  background: var(--el-fill-color-light);
  border-radius: 8px;
  border: 1px solid var(--el-border-color-lighter);
  
  .email-info {
    margin-bottom: 12px;
    font-size: 14px;
    
    .label {
      color: var(--el-text-color-secondary);
      margin-right: 4px;
    }
    
    .email {
      color: var(--el-color-primary);
      font-weight: 500;
    }
  }
  
  .input-row {
    display: flex;
    align-items: center;
    gap: 8px;
    
    .input-item {
      flex: 1;
    }
  }
  
  .attempts-warning {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 13px;
    color: var(--el-color-warning);
    
    .warning-icon {
      font-size: 16px;
    }
  }
  
  .auto-submit-hint {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 13px;
    color: var(--el-text-color-secondary);
    
    .hint-icon {
      font-size: 16px;
      color: var(--el-color-info);
    }
  }
}

// 步骤指示器样式
.step-indicator {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  
  .step-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 6px;
    
    .step-number {
      width: 32px;
      height: 32px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 14px;
      font-weight: 600;
      background: var(--el-fill-color);
      color: var(--el-text-color-secondary);
      border: 2px solid var(--el-border-color);
    }
    
    .step-label {
      font-size: 13px;
      color: var(--el-text-color-secondary);
    }
    
    &.completed {
      .step-number {
        background: var(--el-color-success);
        color: white;
        border-color: var(--el-color-success);
      }
      
      .step-label {
        color: var(--el-color-success);
      }
    }
    
    &.active {
      .step-number {
        background: var(--el-color-primary);
        color: white;
        border-color: var(--el-color-primary);
      }
      
      .step-label {
        color: var(--el-color-primary);
        font-weight: 500;
      }
    }
  }
  
  .step-line {
    width: 60px;
    height: 2px;
    background: var(--el-border-color);
    margin-top: -16px;
  }
}
</style>
