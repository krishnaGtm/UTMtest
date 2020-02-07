using Autofac;
using Autofac.Integration.Web;
using Enza.UTM.Web.Services.Soap.Models;
using System;

namespace Enza.UTM.Web.Services.Soap
{
    public class Global : System.Web.HttpApplication, IContainerProviderAccessor
    {
        private static IContainerProvider _containerProvider;
        
        public IContainerProvider ContainerProvider => _containerProvider;

        protected void Application_Start(object sender, EventArgs e)
        {
            log4net.Config.XmlConfigurator.Configure();

            Configure();
        }
        private void Configure()
        {
            var builder = new ContainerBuilder();
            //register other types
            builder.RegisterModule<AutofacModule>();

            _containerProvider = new ContainerProvider(builder.Build());
        }
        
    }
}