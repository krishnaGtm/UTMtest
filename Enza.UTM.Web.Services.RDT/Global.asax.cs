using Enza.UTM.Web.Services.Core.Helpers;
using System;
using System.Web;
using System.Web.Http;

namespace Enza.UTM.Web.Services.RDT
{
    public class WebApiApplication : HttpApplication
    {
        protected void Application_Start()
        {
            log4net.Config.XmlConfigurator.Configure();

            GlobalConfiguration.Configure(WebApiConfig.Register);
            AutofacConfig.Configure(GlobalConfiguration.Configuration);
        }

        protected void Application_BeginRequest(object sender, EventArgs e)
        {
            PreflightRequestHelper.HandlePreflightRequest(sender as HttpApplication);
        }
    }
}
