using System;
using System.Collections.ObjectModel;
using System.Collections.Specialized;
using System.IO;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;

namespace Enza.UTM.Web.Services.RDT.Models
{
    public class MultipartFormDataMemoryStreamProvider : MultipartMemoryStreamProvider
    {
        private readonly Collection<bool> _isFormData = new Collection<bool>();
        public NameValueCollection FormData { get; } = new NameValueCollection(StringComparer.OrdinalIgnoreCase);

        public override Stream GetStream(HttpContent parent, HttpContentHeaders headers)
        {
            if (parent == null) throw new ArgumentNullException(nameof(parent));
            if (headers == null) throw new ArgumentNullException(nameof(headers));

            var contentDisposition = headers.ContentDisposition;

            if (contentDisposition != null)
            {
                _isFormData.Add(string.IsNullOrWhiteSpace(contentDisposition.FileName));
                return base.GetStream(parent, headers);
            }
            throw new InvalidOperationException("Did not find required 'Content-Disposition' header field in MIME multipart body part.");
        }

        public override async Task ExecutePostProcessingAsync()
        {
            for (var index = 0; index < Contents.Count; index++)
            {
                if (IsStream(index))
                    continue;

                var formContent = Contents[index];
                var contentDisposition = formContent.Headers.ContentDisposition;
                var formFieldName = UnquoteToken(contentDisposition.Name) ?? string.Empty;
                var formFieldValue = await formContent.ReadAsStringAsync();
                FormData.Add(formFieldName, formFieldValue);
            }
        }

        private static string UnquoteToken(string token)
        {
            if (string.IsNullOrWhiteSpace(token))
                return token;

            if (token.StartsWith("\"", StringComparison.Ordinal) && token.EndsWith("\"", StringComparison.Ordinal) && token.Length > 1)
                return token.Substring(1, token.Length - 2);

            return token;
        }

        public bool IsStream(int idx)
        {
            return !_isFormData[idx];
        }
    }
}