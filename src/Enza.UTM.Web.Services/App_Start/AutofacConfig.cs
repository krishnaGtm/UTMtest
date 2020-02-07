using System.Reflection;
using System.Web.Http;
using Autofac;
using Autofac.Integration.WebApi;
using Enza.UTM.BusinessAccess;

namespace Enza.UTM.Web.Services
{
    public static class AutofacConfig
    {
        //public static void Configure(HttpConfiguration config, Action<ContainerBuilder> registration, Action<ILifetimeScope> callback)
        public static void Configure(HttpConfiguration config)
        {
            var builder = new ContainerBuilder();
            builder.RegisterApiControllers(Assembly.GetExecutingAssembly());

            //register other types
            builder.RegisterModule<AutofacModule>();

            var container = builder.Build();
            config.DependencyResolver = new AutofacWebApiDependencyResolver(container);
        }
    }
}
