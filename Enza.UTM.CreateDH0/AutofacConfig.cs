using System.Reflection;
using Autofac;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.BusinessAccess.Services;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.DataAccess.Data.Repositories;
using Enza.UTM.DataAccess.Databases;
using Enza.UTM.DataAccess.Interfaces;

namespace Enza.UTM.CreateDH
{
    public static class AutofacConfig
    {
        public static void Register(ContainerBuilder builder)
        {
            //Database
            builder.RegisterType<UserContext>().As<IUserContext>().InstancePerLifetimeScope();
            builder.RegisterType<SqlDatabase>().As<IDatabase>()
                .WithParameter("nameOrConnectionString", "ConnectionString").InstancePerLifetimeScope();

           

            //Repositories
            builder.RegisterType<S2SRepository>().As<IS2SRepository>().InstancePerLifetimeScope();
            builder.RegisterType<ExcelDataRepository>().As<IExcelDataRepository>().InstancePerLifetimeScope();
            builder.RegisterType<EmailConfigRepository>().As<IEmailConfigRepository>().InstancePerLifetimeScope();
            //Services

            builder.RegisterType<S2SService>().As<IS2SService>().InstancePerLifetimeScope();
            builder.RegisterType<EmailConfigService>().As<IEmailConfigService>().InstancePerLifetimeScope();
            builder.RegisterType<EmailService>().As<IEmailService>().InstancePerLifetimeScope();
        }
    }
}
