using System;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;
using Enza.UTM.Common.Exceptions;

namespace Enza.UTM.Services.Abstract
{
    public abstract class SoapClient : IDisposable
    {
        private bool disposed;

        private readonly HttpClient client;
        private readonly HttpClientHandler handler;

        protected SoapClient()
        {
            handler = new HttpClientHandler
            {
                PreAuthenticate = false,
                UseCookies = true,
                UseDefaultCredentials = false,
                CookieContainer = new CookieContainer(),
                AutomaticDecompression = DecompressionMethods.Deflate | DecompressionMethods.GZip
            };
            client = new HttpClient(handler);
            ServicePointManager.ServerCertificateValidationCallback = (sender, certificate, chain, errors) =>
            {
                return true;
            };
        }

        public string Url { get; set; }
        public NetworkCredential Credentials { get; set; }

        protected async Task<string> ExecuteAsync(string url, string actionName, string body)
        {
            if (Credentials != null)
                handler.Credentials = Credentials;

            client.DefaultRequestHeaders.Add("SOAPAction", actionName);

            //client.DefaultRequestHeaders.Accept.Add(new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("text/xml"));
            var content = new StringContent(body, Encoding.UTF8, "text/xml");
            using (var response = await client.PostAsync(url, content))
            {
                var result = await response.Content.ReadAsStringAsync();
                if (response.IsSuccessStatusCode)
                    return result;

                if (response.StatusCode == HttpStatusCode.Unauthorized)
                    throw new SoapException("Response status code does not indicate success: 401 (Unauthorized).");

                var fault = GetSoapFaults(result);
                throw new SoapException(fault.FaultCode, fault.FaultString, fault.Detail);
            }
        }

        protected Task<string> ExecuteAsync(string actionName, string body)
        {
            return ExecuteAsync(Url, actionName, body);
        }

        protected async Task<string> ExecuteAsync(string actionName)
        {
            var body = PrepareBody();
            return await ExecuteAsync(actionName, body);
        }

        protected virtual string PrepareBody()
        {
            return string.Empty;
        }


        protected virtual SoapFault GetSoapFaults(string response)
        {
            var doc = XDocument.Parse(response);
            var faultCode = doc.Descendants("faultcode").FirstOrDefault()?.Value;
            var faultString = doc.Descendants("faultstring").FirstOrDefault()?.Value;
            var detail = doc.Descendants("detail").FirstOrDefault()?.Value;
            return new SoapFault
            {
                FaultCode = faultCode,
                FaultString = faultString,
                Detail = detail
            };
        }

        protected virtual SoapExecutionResult GetResult(XNamespace ns,  string response)
        {

            var doc = XDocument.Parse(response);
            var result = doc.Descendants(ns + "Result").FirstOrDefault()?.Value;
            var error = string.Empty;
            if (result != null && result.ToLower().Contains("failure"))
            {
                error = GetErrorDetails(ns, doc);
                if (string.IsNullOrWhiteSpace(error))
                {
                    error = result;
                    result = "Failure";
                }
            }
            return new SoapExecutionResult(result, error);
        }


        protected virtual string GetErrorDetails(XNamespace ns, XDocument doc)
        {
            var element = doc.Descendants(ns + "Errors").FirstOrDefault();
            if (element != null)
            {
                if (!element.HasElements)
                    return element.Value;
                return element.Element(ns + "faultDetails")?.Value;
            }
            return string.Empty;
        }

        #region IDisposable Support

        protected virtual void Dispose(bool disposing)
        {
            if (!disposed)
            {
                if (disposing)
                {
                    // TODO: dispose managed state (managed objects).
                    handler.Dispose();
                    client.Dispose();
                }

                // TODO: free unmanaged resources (unmanaged objects) and override a finalizer below.
                // TODO: set large fields to null.

                disposed = true;
            }
        }

        // TODO: override a finalizer only if Dispose(bool disposing) above has code to free unmanaged resources.
        // ~SoapClient() {
        //   // Do not change this code. Put cleanup code in Dispose(bool disposing) above.
        //   Dispose(false);
        // }

        // This code added to correctly implement the disposable pattern.
        public void Dispose()
        {
            // Do not change this code. Put cleanup code in Dispose(bool disposing) above.
            Dispose(true);
            // TODO: uncomment the following line if the finalizer is overridden above.
            // GC.SuppressFinalize(this);
        }

        #endregion
    }
}
