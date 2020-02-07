using System.IO;
using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace Enza.UTM.Common.Extensions
{
    public static class JsonExtensions
    {
        public static async Task<T> DeserializeAsync<T>(this HttpContent httpContent)
        {
            var stream = await httpContent.ReadAsStreamAsync();
            var serializer = new JsonSerializer();
            using (var sr = new StreamReader(stream))
            {
                using (var jsonTextReader = new JsonTextReader(sr))
                {
                    return serializer.Deserialize<T>(jsonTextReader);
                }
            }
        }

        public static string ToJson(this object o, bool camelCase = false)
        {
            if (camelCase)
            {
                return JsonConvert.SerializeObject(o, new JsonSerializerSettings
                {
                    ContractResolver = new Newtonsoft.Json.Serialization.CamelCasePropertyNamesContractResolver()
                });
            }
            return JsonConvert.SerializeObject(o);
        }
    }
}
