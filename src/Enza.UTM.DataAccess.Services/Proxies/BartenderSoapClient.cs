using System.Linq;
using System.Threading.Tasks;
using System.Xml.Linq;
using Enza.UTM.Common;
using Enza.UTM.Common.Extensions;
using Enza.UTM.Services.Abstract;

namespace Enza.UTM.Services.Proxies
{
    public class BartenderSoapClient : SoapClient
    {
        public async Task<SoapExecutionResult> PrintToBarTenderAsync()
        {
            var response = await ExecuteAsync("http://contract.enzazaden.com/BarTender/v1/printToBarTender");
            XNamespace ns = "http://contract.enzazaden.com/BarTender";
            return GetResult(ns, response);
        }

        public object Model { get; set; }

        protected override string PrepareBody()
        {
            var body = typeof(BartenderSoapClient).Assembly.GetString(
                "Enza.UTM.Services.Requests.PrintToBarTenderRequest.st");
            var tpl = Template.Render(body, Model);
            return tpl;
        }

        
    }
}
