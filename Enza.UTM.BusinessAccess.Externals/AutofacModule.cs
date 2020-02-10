using Autofac;
using Enza.UTM.BusinessAccess.Externals.Interfaces;
using Enza.UTM.BusinessAccess.Externals.Services;
using Enza.UTM.DataAccess.Data.Externals.Interfaces;
using Enza.UTM.DataAccess.Data.Externals.Repositories;
using Enza.UTM.DataAccess.Databases;
using Enza.UTM.DataAccess.Interfaces;

namespace Enza.UTM.BusinessAccess.Externals
{
    public class AutofacModule : Module
    {
        protected override void Load(ContainerBuilder builder)
        {
            //Database
            builder.RegisterType<UserContext>().As<IUserContext>().InstancePerRequest();
            builder.RegisterType<SqlDatabase>().As<IDatabase>().WithParameter("nameOrConnectionString", "ConnectionString").InstancePerRequest();

            //Repositories           
            builder.RegisterType<MarkerTestDataRepository>().As<IMarkerTestDataRepository>().InstancePerRequest();
            builder.RegisterType<MarkerTestDataService>().As<IMarkerTestDataService>().InstancePerRequest();

            builder.RegisterType<DHRepository>().As<IDHRepository>().InstancePerRequest();
            builder.RegisterType<DHService>().As<IDHService>().InstancePerRequest();
        }
    }
}
