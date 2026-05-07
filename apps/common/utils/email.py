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
