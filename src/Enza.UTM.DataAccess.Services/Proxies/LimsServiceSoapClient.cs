using Enza.UTM.Services.Abstract;
using System.Linq;
using System.Threading.Tasks;
using System.Xml.Linq;
using Enza.UTM.Common;
using Enza.UTM.Common.Exceptions;
using Enza.UTM.Common.Extensions;

namespace Enza.UTM.Services.Proxies
{
    public class LimsServiceSoapClient : SoapClient
    {
        public object Model { get; set; }

        protected override string PrepareBody()
        {
            var tpl = typeof(LimsServiceSoapClient).Assembly.GetString("Enza.UTM.Services.Requests.ReservePlatesInLIMSRequest.st");
            var body = Template.Render(tpl, Model);
            return body;
        }

        public async Task<SoapExecutionResult> ReservePlatesInLIMSAsync()
        {
            var response = await ExecuteAsync("http://contract.enzazaden.com/LIMS/v1/ReservePlatesInLIMS");
            XNamespace ns = "http://contract.enzazaden.com/LIMS/v1";
            var result = GetResult(ns, response);
            if (!result.Success)
                throw new SoapException(result.Error);
            return result;
        }

        public async Task<SoapExecutionResult> FillPlatesInLimsAsync()
        {
            var tpl = typeof(LimsServiceSoapClient).Assembly.GetString(
                "Enza.UTM.Services.Requests.FillPlatesInLIMSRequest.st");
            var body = Template.Render(tpl, Model);
            var action = "http://contract.enzazaden.com/LIMS/v1/LimsBinding_v1/FillPlatesWrapperRequest";
            var response = await ExecuteAsync(action, body);

            XNamespace ns = "http://contract.enzazaden.com/LIMS/v1";
            var result = GetResult(ns, response);
            if (!result.Success)
                throw new SoapException(result.Error);
            return result;
        }
    }
}
