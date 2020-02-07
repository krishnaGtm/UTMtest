using Enza.UTM.Common.Extensions;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading;
using System.Threading.Tasks;

namespace Enza.UTM.Services.Abstract
{
    public class RestClient : IDisposable
    {
        private bool disposed;
        private readonly HttpClient _client;
        private readonly HttpClientHandler _handler;
        private const int DEFAULT_TIMEOUT = 100;//seconds

        public RestClient(string baseAddress)
        {
            _handler = new HttpClientHandler
            {
                PreAuthenticate = false,
                UseCookies = true,
                UseDefaultCredentials = false,
                CookieContainer = new CookieContainer(),
                AutomaticDecompression = DecompressionMethods.Deflate | DecompressionMethods.GZip
            };
            _client = new HttpClient(_handler)
            {
                BaseAddress = new Uri(baseAddress),
                Timeout = Timeout.InfiniteTimeSpan
            };
            ServicePointManager.ServerCertificateValidationCallback = (sender, certificate, chain, errors) =>
            {
                return true;
            };
        }

        public void AddRequestHeaders(NameValueCollection headers)
        {
            foreach (string key in headers.Keys)
            {
                var values = headers.GetValues(key);
                _client.DefaultRequestHeaders.Add(key, values);
            }
        }

        public void AddRequestHeaders(Action<NameValueCollection> headers)
        {
            var list = new NameValueCollection();
            headers(list);
            AddRequestHeaders(list);
        }

        public void SetRequestCookies(HttpRequestMessage request)
        {
            var cookieHeaderValues = request.Headers.GetCookies();
            foreach (var cookieHeaderValue in cookieHeaderValues)
            {
                foreach (var cookie in cookieHeaderValue.Cookies)
                {
                    _handler.CookieContainer.Add(new Cookie(cookie.Name, cookie.Value)
                    {
                        Domain = _client.BaseAddress.Host
                    });
                }
            }
        }

        public void SetResponseCookies(HttpRequestMessage request, HttpResponseMessage response)
        {
            //add cookie to track cookie cache
            var cookies = GetResponseCookies();
            var secured = request.RequestUri.Scheme == Uri.UriSchemeHttps;
            response.AddCookies(secured, cookies);
        }

        public void SetResponseCookies(HttpRequestMessage request, HttpResponseMessage response, IEnumerable<string> includes)
        {
            //add cookie to track cookie cache
            var cookies = GetResponseCookies();
            var secured = request.RequestUri.Scheme == Uri.UriSchemeHttps;
            response.AddCookies(secured, cookies, includes);
        }


        public IEnumerable<Cookie> GetResponseCookies()
        {
            return _handler.CookieContainer.GetCookies(_client.BaseAddress).OfType<Cookie>();
        }

        public async Task<HttpResponseMessage> GetAsync(string url, int timeout)
        {
            try
            {
                using (var cts = new CancellationTokenSource(TimeSpan.FromSeconds(timeout)))
                {
                    var response = await _client.GetAsync(url, cts.Token);
                    response.HandleCORSResponse();
                    return response;
                }
            }
            catch (TaskCanceledException ex)
            {
                throw new TimeoutException("Request timeout occured.", ex);
            }
        }

        public Task<HttpResponseMessage> GetAsync(string url)
        {
            return GetAsync(url, DEFAULT_TIMEOUT);
        }

        public async Task<HttpResponseMessage> PostAsync(string url, HttpContent content, int timeout)
        {
            try
            {
                using (var cts = new CancellationTokenSource(TimeSpan.FromSeconds(timeout)))
                {
                    var response = await _client.PostAsync(url, content, cts.Token);
                    //remove CORS Response headers
                    response.HandleCORSResponse();

                    return response;
                }
            }
            catch (TaskCanceledException ex)
            {
                throw new TimeoutException("Request timeout occured.", ex);
            }
        }

        public Task<HttpResponseMessage> PostAsync(string url, HttpContent content)
        {
            return PostAsync(url, content, DEFAULT_TIMEOUT);
        }

        public Task<HttpResponseMessage> PostAsync(string url, IEnumerable<KeyValuePair<string, string>> values, int timeout)
        {
            //var content = new FormUrlEncodedContent(values);
            //handling large data in FormUrlEncodedContent issues.
            //Exception: Invalid URI: The Uri string is too long.
            var content = values.ToFormUrlEncodedContent();
            return PostAsync(url, content, timeout);
        }

        public Task<HttpResponseMessage> PostAsync(string url, IEnumerable<KeyValuePair<string, string>> values)
        {
            return PostAsync(url, values, DEFAULT_TIMEOUT);
        }

        public Task<HttpResponseMessage> PostAsync(string url, Action<FormValues> values, int timeout)
        {
            var list = new FormValues();
            values(list);
            return PostAsync(url, list, timeout);
        }

        public Task<HttpResponseMessage> PostAsync(string url, Action<FormValues> values)
        {
            return PostAsync(url, values, DEFAULT_TIMEOUT);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (disposed) return;

            if (disposing)
            {
                _handler?.Dispose();
                _client?.Dispose();
            }

            disposed = true;
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }
    }

    public class FormValues : List<KeyValuePair<string, string>>
    {
        public void Add(string key, string value)
        {
            Add(new KeyValuePair<string, string>(key, value));
        }
    }

    public static class RestClientExtensions
    {
        public static void AddCookies(this HttpResponseMessage response, bool secured, IEnumerable<Cookie> cookies)
        {
            response.Headers.Remove("Set-Cookie");
            response.Headers.AddCookies(cookies.Select(c => new CookieHeaderValue(c.Name, c.Value)
            {
                //Domain = c.Domain,
                Path = c.Path,
                Expires = c.Expires,
                HttpOnly = c.HttpOnly,
                Secure = secured // c.Secure
            }));
        }

        public static void AddCookies(this HttpResponseMessage response, bool secured, IEnumerable<Cookie> cookies, IEnumerable<string> includes)
        {
            var headers = cookies.Where(o => includes.Contains(o.Name, StringComparer.OrdinalIgnoreCase)).ToList();
            response.AddCookies(secured, headers);
        }

        public static void HandleCORSResponse(this HttpResponseMessage response)
        {
            var headers = response.Headers.Select(o => o.Key).ToList();
            foreach (var header in headers)
            {
                if (header.StartsWith("Access-Control-"))
                {
                    response.Headers.Remove(header);
                }
            }
        }
    }
}
