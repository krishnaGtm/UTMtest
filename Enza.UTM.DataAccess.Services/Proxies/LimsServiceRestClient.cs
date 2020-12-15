using Enza.UTM.Entities.Results;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Web;

namespace Enza.UTM.Services.Proxies
{
    public class LimsServiceRestClient
    {
        public string AccessKey { get; set; }
        public string SecretKey { get; set; }
        public string Url { get; set; }

        public LimsServiceRestClient()
        {
            AccessKey = ConfigurationManager.AppSettings["AccessKey"];
            SecretKey = ConfigurationManager.AppSettings["SecretKey"];
            Url = ConfigurationManager.AppSettings["RestLimsServiceUrl"]; ;
        }

        public RequestSampleTestResult RequestSampleTestAsync(RequestSampleTestRequest request)
        {
            // serialize to JSON, taking extra care for date-times 
            // unless invariant such as DOBs, date-times must be converted to UTC, and serialized with this format: 
            // yyyy-MM-ddTHH:mm:ss.fffZ 

            JsonSerializerSettings jsonSettings = new JsonSerializerSettings();
            jsonSettings.DateFormatString = "yyyy-MM-ddTHH:mm:ss.fffZ";

            var json = JsonConvert.SerializeObject(request, jsonSettings);

            HttpWebRequest req = WebRequest.CreateHttp(Url);

            req.Method = "POST";

            // write payload         
            byte[] data = Encoding.UTF8.GetBytes(json);
            req.GetRequestStream().Write(data, 0, data.Length);

            req.Headers.Add("SL-API-Timestamp", DateTime.UtcNow.ToString("yyyy-MMddTHH:mm:ss.fffZ"));
            req.Headers.Add("SL-API-Auth", AccessKey);
            req.Headers.Add("SL-API-Signature", ComputeSignature(req, json));

            req.ContentType = "application/json";

            HttpWebResponse resp = (HttpWebResponse)req.GetResponse();

            if (resp.StatusCode == HttpStatusCode.OK)
            {
                // extract response JSON payload         
                //string respJson = ExtractResponseBody(resp);

                //return respJson;

                // deserialize into in-memory object         
                //var respObj = JsonConvert.DeserializeObject(respJson) as RequestSampleTestResult;

                return new RequestSampleTestResult() { Success = "True" };
            }
            else
                return new RequestSampleTestResult() { Success = "False", ErrorMsg = resp.StatusDescription };

        }

        // used with string payloads, such as JSON     
        private string ComputeSignature(HttpWebRequest req, string payload)
        {
            string data = String.Format("{0}\n{1}\n{2}\n{3}\n{4}\n{5}",
            req.RequestUri.AbsoluteUri,
            req.Method,
            req.Headers["SL-API-Auth"],
            req.Headers["SL-API-Method"] ?? "",
            req.Headers["SL-API-Timestamp"],
            payload);

            byte[] dataBytes = Encoding.UTF8.GetBytes(data);
            return ComputeHash(dataBytes);
        }


        private string ExtractResponseBody(WebResponse resp)
        {
            using (StreamReader reader = new StreamReader(resp.GetResponseStream()))
            {
                return reader.ReadToEnd();
            }
        }

        private string ComputeHash(byte[] dataBytes)
        {
            byte[] keyBytes = Encoding.UTF8.GetBytes(SecretKey);

            HMACSHA256 crypto = new HMACSHA256(keyBytes);
            byte[] hashBytes = crypto.ComputeHash(dataBytes);

            string hash = Convert.ToBase64String(hashBytes);
            string encodedHash = HttpUtility.UrlEncode(hash);

            return encodedHash;
        }
    }

}
