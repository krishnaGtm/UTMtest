using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.Linq;

namespace Enza.UTM.Common.Extensions
{
    public static class CommonExtensions
    {
        public static string GetDomainNameOnly(this string fullyQualifiedDomainName)
        {
            var chunks = fullyQualifiedDomainName.Split(new[] { '\\' }, 2);
            if (chunks.Length == 2)
            {
                return chunks[1];
            }
            return fullyQualifiedDomainName;
        }
        public static (string UserName, string Password) GetCredentials(this string credentials)
        {
            var chunks = credentials.Split(new[] { '|' }, 2);
            if (chunks.Length == 2)
            {
                return (chunks[0], chunks[1]);
            }
            return (chunks[0], string.Empty);
        }
        public static string ToText(this object o)
        {
            if (o == null || o == DBNull.Value)
                return string.Empty;
            return Convert.ToString(o);
        }

        public static int ToInt32(this object o)
        {
            if (o == null || o == DBNull.Value)
                return default(int);
            return Convert.ToInt32(o);
        }

        public static long ToInt64(this object o)
        {
            if (o == null || o == DBNull.Value)
                return default(int);
            return Convert.ToInt64(o);
        }

        public static DateTime? ToNDateTime(this object o)
        { 
            if (o == null || o == DBNull.Value)
                return null;
            var format = ConfigurationManager.AppSettings["App:DateFormat"];
            var provider = new DateTimeFormatInfo
            {
                ShortDatePattern = format
            };
            return Convert.ToDateTime(o,provider);
        }

        public static DateTime ToDateTime(this object o)
        {
            return o.ToNDateTime().Value;
        }

        public static bool ToBoolean(this object o)
        {
            if (o == null || o == DBNull.Value)
                return false;
            return Convert.ToBoolean(o);
        }

        public static bool EqualsIgnoreCase(this string a, string b)
        {
            return String.Compare(a, b, StringComparison.OrdinalIgnoreCase) == 0;
        }
        public static string ToCamelCase(this string s)
        {
            if (string.IsNullOrEmpty(s) || !char.IsUpper(s[0]))
            {
                return s;
            }

            char[] chars = s.ToCharArray();

            for (int i = 0; i < chars.Length; i++)
            {
                if (i == 1 && !char.IsUpper(chars[i]))
                {
                    break;
                }

                bool hasNext = (i + 1 < chars.Length);
                if (i > 0 && hasNext && !char.IsUpper(chars[i + 1]))
                {
                    // if the next character is a space, which is not considered uppercase 
                    // (otherwise we wouldn't be here...)
                    // we want to ensure that the following:
                    // 'FOO bar' is rewritten as 'foo bar', and not as 'foO bar'
                    // The code was written in such a way that the first word in uppercase
                    // ends when if finds an uppercase letter followed by a lowercase letter.
                    // now a ' ' (space, (char)32) is considered not upper
                    // but in that case we still want our current character to become lowercase
                    if (char.IsSeparator(chars[i + 1]))
                    {
                        chars[i] = ToLower(chars[i]);
                    }

                    break;
                }

                chars[i] = ToLower(chars[i]);
            }

            return new string(chars);
        }
        private static char ToLower(char c)
        {
            #if HAVE_CHAR_TO_STRING_WITH_CULTURE
            c = char.ToLower(c, CultureInfo.InvariantCulture);
            #else
            c = char.ToLowerInvariant(c);
            #endif
            return c;
        }

        //public static string Truncate(this string value, int maxCharsLength)
        //{
        //    return value.Length <= maxCharsLength ? value : value.Substring(0, maxCharsLength) + "...";
        //}

        public static string Truncate(this List<string> keys, int maxKeys = 5)
        {
            var key = string.Join(",", keys.Take(maxKeys).ToArray());
            if (keys.Count > maxKeys)
                key = key + "...";
            return key;
        }

        public static T CloneAs<T>(this object o) where T : class
        {
            if (o == null) return null;

            var serialized = JsonConvert.SerializeObject(o);
            return JsonConvert.DeserializeObject<T>(serialized);
        }

        public static string AddEnv(this string text)
        {
            var env = ConfigurationManager.AppSettings["App:Environment"];
            if (!string.IsNullOrWhiteSpace(env))
            {
                //var envs = new[] { "TEST", "ACCEPT", "ACCEPTATION" };
                //if (envs.Contains(env, StringComparer.OrdinalIgnoreCase))
                //{
                //    return string.Concat(env.ToUpper(), ": ", text);
                //}
                return string.Concat(env.ToUpper(), ": ", text);
            }
            return text;
        }
    }
}
