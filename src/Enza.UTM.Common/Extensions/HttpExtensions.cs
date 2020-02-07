using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;

namespace Enza.UTM.Common.Extensions
{
    public static class HttpExtensions
    {
        public static HttpContent ToFormUrlEncodedContent(this IEnumerable<KeyValuePair<string, string>> values)
        {
            return new FormUrlEncodedContentEx(values);

            //var items = values.Select(o => WebUtility.UrlEncode(o.Key) + "=" + WebUtility.UrlEncode(o.Value)).ToList();
            //return new StringContent(string.Join("&", items), Encoding.GetEncoding(28591), "application/x-www-form-urlencoded");
        }
    }

    public class FormUrlEncodedContentEx : ByteArrayContent
    {
        public FormUrlEncodedContentEx(IEnumerable<KeyValuePair<string, string>> values) : base(GetContentByteArray(values))
        {
            Headers.ContentType = new MediaTypeHeaderValue("application/x-www-form-urlencoded");
        }
        private static byte[] GetContentByteArray(IEnumerable<KeyValuePair<string, string>> nameValueCollection)
        {
            if (nameValueCollection == null)
            {
                throw new ArgumentNullException(nameof(nameValueCollection));
            }
            var sb = new StringBuilder();
            foreach (KeyValuePair<string, string> current in nameValueCollection)
            {
                if (sb.Length > 0)
                {
                    sb.Append('&');
                }
                sb.Append(Encode(current.Key));
                sb.Append('=');
                sb.Append(Encode(current.Value));
            }
            //System.Net.Http.HttpRuleParser
            var encoding = Encoding.GetEncoding(28591);
            return encoding.GetBytes(sb.ToString());
        }
        private static string Encode(string data)
        {
            if (string.IsNullOrEmpty(data))
            {
                return string.Empty;
            }
            return WebUtility.UrlEncode(data);
        }
    }
}
