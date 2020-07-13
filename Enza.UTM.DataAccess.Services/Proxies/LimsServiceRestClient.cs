using Newtonsoft.Json;
using System;
using System.Collections.Generic;
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
            AccessKey = "BA85DB323D894D8BA9BFC4C1031C112A";
            SecretKey = "0EDD24F2B2CD407F9219E1ECC79D5F27";
            Url = "https://starlimstest.intra.local/starlims11.test/rest.web.api/v1/UTM/request";
        }

        public string RequestSampleTestAsync()
        {
            var materialList = new List<Material> 
            {
                new Material
                {
                    MaterialID = 11001,
                    Name = "MT0000012",
                    ExpectedResultDate = DateTime.UtcNow,
                    MaterialStatus = "ACT"
                }
            };

            var determinationList = new List<Determination>
            {
                new Determination
                {
                    DeterminationID = 2300232,
                    Materials = materialList
                }
            };

            // prepare payload object         
            var payload = new RequestSampleTestRequest
            {
                Crop = "LT",
                BrStation = "NLEN",
                Country = "NL",
                Level = "PLT",
                RequestID = 3332,
                RequestingName = "Binodg",
                RequestingSystem = "UTM",
                RequestingUser = "BinodG",
                TestType = "RDT",
                Determinations = determinationList
            };

            // serialize to JSON, taking extra care for date-times 
            // unless invariant such as DOBs, date-times must be converted to UTC, and serialized with this format: 
            // yyyy-MM-ddTHH:mm:ss.fffZ 

            JsonSerializerSettings jsonSettings = new JsonSerializerSettings();
            jsonSettings.DateFormatString = "yyyy-MM-ddTHH:mm:ss.fffZ";

            var json = JsonConvert.SerializeObject(payload, jsonSettings);

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

            // extract response JSON payload         
            string respJson = ExtractResponseBody(resp);

            return respJson;

            // deserialize into in-memory object         
            //dynamic respObj = JsonConvert.DeserializeObject(respJson);

            // consume the response as needed...     
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

    public class Material
    {
        public int MaterialID { get; set; }
        public string Name { get; set; }
        public DateTime ExpectedResultDate { get; set; }
        public string MaterialStatus { get; set; }
    }

    public class Determination
    {
        public int DeterminationID { get; set; }
        public List<Material> Materials { get; set; }
    }

    public class RequestSampleTestRequest
    {
        public string Crop { get; set; }
        public string BrStation { get; set; }
        public string Country { get; set; }
        public string Level { get; set; }
        public string TestType { get; set; }
        public int RequestID { get; set; }
        public string RequestingUser { get; set; }
        public string RequestingName { get; set; }
        public string RequestingSystem { get; set; }
        public List<Determination> Determinations { get; set; }
    }
}
