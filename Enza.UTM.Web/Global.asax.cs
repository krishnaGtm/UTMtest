using System.Web;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;

namespace Enza.UTM.Web
{
    public class WebApiApplication : HttpApplication
    {
        protected void Application_Start()
        {
            AreaRegistration.RegisterAllAreas();           
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);

            ViewEngines.Engines.Clear();
            ViewEngines.Engines.Add(new RazorViewEngine
            {
                FileExtensions = new[] { "cshtml" }
            });
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);
        }
    }
}
