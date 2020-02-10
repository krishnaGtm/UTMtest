using System.Globalization;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;

namespace Enza.UTM.Web.Services.Core.Handlers
{
    public class LocalizationHandler : DelegatingHandler
    {
        readonly string dateFormat;
        public LocalizationHandler(string dateFormat)
        {
            this.dateFormat = dateFormat;
        }
        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            var culture = new CultureInfo("en-US")
            {
                DateTimeFormat = new DateTimeFormatInfo
                {
                    ShortDatePattern = dateFormat
                }
            };
            //Thread.CurrentThread.CurrentCulture = Thread.CurrentThread.CurrentUICulture = culture;
            CultureInfo.CurrentCulture = CultureInfo.CurrentUICulture = culture;

            return base.SendAsync(request, cancellationToken);
        }
    }
}