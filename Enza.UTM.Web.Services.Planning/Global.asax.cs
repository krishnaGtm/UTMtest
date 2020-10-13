using Enza.UTM.Web.Services.Core.Helpers;
using System;
using System.Web;

namespace Enza.UTM.Web.Services.Planning
{
    public class WebApiApplication : HttpApplication
    {
        protected void Application_Start()
        {
            log4net.Config.XmlConfigurator.Configure();
        }

        protected void Application_BeginRequest(object sender, EventArgs e)
        {
            PreflightRequestHelper.HandlePreflightRequest(sender as HttpApplication);
        }
    }
}
