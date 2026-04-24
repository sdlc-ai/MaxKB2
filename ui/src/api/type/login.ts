interface LoginRequest {
  /**
   * 用户名
   */
  username: string
  /**
   * 密码
   */
  password: string
  /**
   * 验证码
   */
  captcha: string
  /**
   * 加密数据
   */
  encryptedData?: string
  /**
   * 邮箱验证码
   */
  email_code?: string
}
export type { LoginRequest }
