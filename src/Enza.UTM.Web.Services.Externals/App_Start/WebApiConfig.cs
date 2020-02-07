using System.Configuration;
using System.Web.Http;
using System.Web.Http.Cors;
using System.Web.Http.ExceptionHandling;
using Newtonsoft.Json.Serialization;
using Enza.UTM.Web.Services.Core.Handlers;

namespace Enza.UTM.Web.Services.Externals
{
    public static class WebApiConfig
    {
        public static void Register(HttpConfiguration config)
        {
            // Web API configuration and services
            var origins = ConfigurationManager.AppSettings["Cors:Origins"];
            var cors = new EnableCorsAttribute(origins, "*", "*")
            {
                SupportsCredentials = true
            };
            config.EnableCors(cors);

            ConfigureServices(config);

            // Web API routes
            config.MapHttpAttributeRoutes();

            config.Routes.MapHttpRoute(
                name: "DefaultApi",
                routeTemplate: "api/v1/{controller}/{id}",
                defaults: new { id = RouteParameter.Optional }
            );

            config.Formatters.Remove(config.Formatters.XmlFormatter);

            var json = config.Formatters.JsonFormatter;
            json.SerializerSettings.DateFormatString = ConfigurationManager.AppSettings["App:DateFormat"];
            json.SerializerSettings.ContractResolver = new CamelCasePropertyNamesContractResolver();
        }

        static void ConfigureServices(HttpConfiguration config)
        {
            config.Services.Add(typeof(IExceptionLogger), new GlobalErrorLogger());
            config.Services.Replace(typeof(IExceptionHandler), new GlobalExceptionHandler());

            config.MessageHandlers.Add(new EnzaJWTHandler());
        }
    }
}
