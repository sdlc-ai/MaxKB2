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
