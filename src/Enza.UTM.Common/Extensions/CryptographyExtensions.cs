using System;
using System.Security.Cryptography;
using System.Text;

namespace Enza.UTM.Common.Extensions
{
    public static class CryptographyExtensions
    {
        private const string salt = "#एन्जाजडेन@२०१७";
        public static String ToMd5(this String clearText)
        {
            string result;
            string saltedString = String.Concat(clearText, salt);
            // Encrypt this user's password information.
            using (var md5 = new MD5CryptoServiceProvider())
            {
                var originalStringBytes = Encoding.Default.GetBytes(saltedString);
                var encodedStringBytes = md5.ComputeHash(originalStringBytes);
                var sb = new StringBuilder();
                foreach (byte b in encodedStringBytes)
                {
                    sb.Append(b.ToString("x2").ToLower());
                }
                result = sb.ToString();
            }
            return result;
        }
        static TripleDES CreateDES(string key)
        {
            var md5 = new MD5CryptoServiceProvider();
            var des = new TripleDESCryptoServiceProvider
            {
                Key = md5.ComputeHash(Encoding.Unicode.GetBytes(key))
            };
            des.IV = new byte[des.BlockSize / 8];
            return des;
        }
        public static byte[] Encrypt(this string clearText, string key)
        {
            var des = CreateDES(key);
            var ct = des.CreateEncryptor();
            var input = Encoding.Unicode.GetBytes(clearText);
            return ct.TransformFinalBlock(input, 0, input.Length);
        }
        public static byte[] Decrypt(this string encText, string key)
        {
            var b = Convert.FromBase64String(encText);
            var des = CreateDES(key);
            var ct = des.CreateDecryptor();
            return ct.TransformFinalBlock(b, 0, b.Length);
        }
        public static string Encrypt(this String clearText)
        {
            var buffer = Encrypt(clearText, salt);
            return Convert.ToBase64String(buffer);
        }
        public static string Decrypt(this String encText)
        {
            var output = Decrypt(encText, salt);
            return Encoding.Unicode.GetString(output);
        }
    }
}
