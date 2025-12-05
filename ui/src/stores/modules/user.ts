import { defineStore } from 'pinia'
import { type Ref } from 'vue'
import type { User } from '@/api/type/user'
import { cloneDeep } from 'lodash'
import UserApi from '@/api/user'
import ThemeApi from '@/api/theme'
import { useElementPlusTheme } from 'use-element-plus-theme'
import { defaultPlatformSetting } from '@/utils/theme'
import { useLocalStorage } from '@vueuse/core'
import { localeConfigKey, getBrowserLang } from '@/locales/index'
import useThemeStore from './theme'
export interface userStateTypes {
  userType: number // 1 系统操作者 2 对话用户
  userInfo: User | null
  token: any
  version?: string
  userAccessToken?: string
  XPACK_LICENSE_IS_VALID: false
  isXPack: false
  themeInfo: any
  workspace_id: string
  edition: 'CE' | 'PE' | 'EE'
  license_is_valid: boolean
  workspace_list: Array<any>
}

const useUserStore = defineStore('user', {
  state: (): userStateTypes => ({
    userType: 1,
    userInfo: null,
    token: '',
    version: '',
    userAccessToken: '',
    XPACK_LICENSE_IS_VALID: false,
    isXPack: false,
    themeInfo: null,
    workspace_id: '',
    edition: 'CE',
    license_is_valid: false,
    workspace_list: [],
  }),
  actions: {
    getLanguage() {
      return this.userType === 1
        ? localStorage.getItem('Porsche-locale') || getBrowserLang()
        : sessionStorage.getItem('language') || getBrowserLang()
    },
    showXpack() {
      return this.isXPack
    },
    isDefaultTheme() {
      return !this.themeInfo?.theme || this.themeInfo?.theme === '#3370FF'
    },
    setTheme(data: any) {
      const { changeTheme } = useElementPlusTheme(this.themeInfo?.theme)
      changeTheme(data?.['theme'])
      this.themeInfo = cloneDeep(data)
    },
    isExpire() {
      return this.isXPack && !this.XPACK_LICENSE_IS_VALID
    },
    isEnterprise() {
      return this.isXPack && this.XPACK_LICENSE_IS_VALID
    },
    getToken(): String | null {
      if (this.token) {
        return this.token
      }
      return this.userType === 1 ? localStorage.getItem('token') : this.getAccessToken()
    },
    getAccessToken() {
      const token = sessionStorage.getItem(`${this.userAccessToken}-accessToken`)
      if (token) {
        return token
      }
      const local_token = localStorage.getItem(`${this.userAccessToken}-accessToken`)
      if (local_token) {
        return local_token
      }
      return localStorage.getItem(`accessToken`)
    },
    setWorkspaceId(workspace_id: string) {
      this.workspace_id = workspace_id
      localStorage.setItem('workspace_id', workspace_id)
    },
    getWorkspaceId(): string | null {
      this.workspace_id = this.workspace_id || localStorage.getItem('workspace_id') || 'default'
      return this.workspace_id
    },
    getPermissions() {
      if (this.userInfo) {
        return this.isXPack && this.XPACK_LICENSE_IS_VALID
          ? [...this.userInfo?.permissions, 'x-pack']
          : this.userInfo?.permissions
      } else {
        return []
      }
    },
    getEdition() {
      if (this.userInfo) {
        if (this.isEE()) {
          return 'X-PACK-EE'
        } else if (this.isPE()) {
          return 'X-PACK-PE'
        } else {
          return 'X-PACK-CE'
        }
      }
      return 'X-PACK-CE'
    },
    getRole() {
      if (this.userInfo) {
        return this.userInfo?.role
      } else {
        return []
      }
    },
    is_admin() {
      return this.userInfo?.role.includes('ADMIN')
    },
    isCE() {
      return this.edition == 'CE'
    },
    isPE() {
      return this.edition == 'PE' && this.license_is_valid
    },
    isEE() {
      return this.edition == 'EE' && this.license_is_valid
    },
    changeUserType(num: number, token?: string) {
      this.userType = num
      this.userAccessToken = token
    },
    getHasPermissionWorkspaceManage() {
      const workspaceManagePermissions = this.userInfo?.role
        .filter((permission) => permission.startsWith('WORKSPACE_MANAGE'))
        .map((permission) => {
          const parts = permission.split('/WORKSPACE/');
          return parts.length > 1 ? parts[1] : null; // 提取工作空间ID
        })
        .filter((id) => id !== null); // 过滤掉无效的ID
      if (workspaceManagePermissions && workspaceManagePermissions.length > 0) {
        if (workspaceManagePermissions.includes(localStorage.getItem('workspace_id') || 'default')) {
          return
        }
        this.setWorkspaceId(workspaceManagePermissions[0])
      }
    },
    getEditionName() {
      return this.edition
    },
    async asyncGetProfile() {
      return new Promise((resolve, reject) => {
        UserApi.getProfile()
          .then(async (ok) => {
            this.version = ok.data?.version || '-'
            this.isXPack = ok.data?.IS_XPACK
            this.XPACK_LICENSE_IS_VALID = ok.data?.XPACK_LICENSE_IS_VALID

            if (this.isEnterprise()) {
              await this.theme()
            } else {
              this.themeInfo = {
                ...defaultPlatformSetting
              }
            }
            resolve(ok)
          })
          .catch((error) => {
            reject(error)
          })
      })
    },

    async theme(loading?: Ref<boolean>) {
      return await ThemeApi.getThemeInfo(loading).then((ok) => {
        this.setTheme(ok.data)
        // window.document.title = this.themeInfo['title'] || 'Porsche'
        // const link = document.querySelector('link[rel="icon"]') as any
        // if (link) {
        //   link['href'] = this.themeInfo['icon'] || '/favicon.ico'
        // }
      })
    },

    async profile(loading?: Ref<boolean>) {
      return UserApi.getUserProfile(loading).then((ok) => {
        this.userInfo = ok.data
        const workspace_list =
          ok.data.workspace_list && ok.data.workspace_list.length > 0
            ? ok.data.workspace_list
            : [{id: 'default', name: 'default'}]
        const workspace_id = this.getWorkspaceId()
        if (!workspace_id || !workspace_list.some((w) => w.id == workspace_id)) {
          this.setWorkspaceId(workspace_list[0].id)
        }
        this.workspace_list = workspace_list
        useLocalStorage<string>(localeConfigKey, 'en-US').value =
          ok?.data?.language || this.getLanguage()
        const theme = useThemeStore()
        theme.setTheme()
        return this.asyncGetProfile()
      })
    },

    async login(auth_type: string, username: string, password: string, captcha: string) {
      return UserApi.login(auth_type, { username, password, captcha }).then((ok) => {
        this.token = ok.data
        localStorage.setItem('token', ok.data)
        return this.profile()
      })
    },
    async dingCallback(code: string) {
      return UserApi.getDingCallback(code).then((ok) => {
        this.token = ok.data
        localStorage.setItem('token', ok.data)
        return this.profile()
      })
    },
    async dingOauth2Callback(code: string) {
      return UserApi.getDingOauth2Callback(code).then((ok) => {
        this.token = ok.data
        localStorage.setItem('token', ok.data)
        return this.profile()
      })
    },
    async wecomCallback(code: string) {
      return UserApi.getWecomCallback(code).then((ok) => {
        this.token = ok.data
        localStorage.setItem('token', ok.data)
        return this.profile()
      })
    },
    async larkCallback(code: string) {
      return UserApi.getlarkCallback(code).then((ok) => {
        this.token = ok.data
        localStorage.setItem('token', ok.data)
        return this.profile()
      })
    },

    async logout() {
      return UserApi.logout().then(() => {
        localStorage.removeItem('token')
        return true
      })
    },
    async getAuthType() {
      return UserApi.getAuthType().then((ok) => {
        return ok.data
      })
    },
    async getQrType() {
      return UserApi.getQrType().then((ok) => {
        return ok.data
      })
    },
    async getQrSource() {
      return UserApi.getQrSource().then((ok) => {
        return ok.data
      })
    },
    async postUserLanguage(lang: string, loading?: Ref<boolean>) {
      return new Promise((resolve, reject) => {
        UserApi.postLanguage({ language: lang }, loading)
          .then(async (ok) => {
            useLocalStorage(localeConfigKey, 'en-US').value = lang
            window.location.reload()
            resolve(ok)
          })
          .catch((error) => {
            reject(error)
          })
      })
    }
  }
})

export default useUserStore
