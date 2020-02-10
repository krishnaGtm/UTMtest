using System.Linq;
using System.Xml.Linq;
using Enza.UTM.Common.Extensions;

namespace Enza.UTM.Services
{
    public static class SoapExtensions
    {
        public static (string Result, string Error) GetResult(this string response, XNamespace ns)
        {
            var doc = XDocument.Parse(response);
            var result = doc.Descendants(ns + "Result")?.FirstOrDefault()?.Value;
            var error = string.Empty;
            if (result.EqualsIgnoreCase("Failure"))
            {
                error = GetErrorDetails(ns, doc);
            }
            return (result, error);
        }

        static string GetErrorDetails(XNamespace ns, XDocument doc)
        {
            var element = doc.Descendants(ns + "Errors")?.FirstOrDefault();
            if (!element.HasElements)
                return element.Value;
            return element.Element(ns + "faultDetails").Value;
        }
    }
}
