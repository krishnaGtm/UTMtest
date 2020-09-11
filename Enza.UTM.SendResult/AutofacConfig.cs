using System.Reflection;
using Autofac;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.BusinessAccess.Services;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.DataAccess.Data.Repositories;
using Enza.UTM.DataAccess.Databases;
using Enza.UTM.DataAccess.Interfaces;

namespace Enza.UTM.SendResult
{
    public static class AutofacConfig
    {
        public static void Register(ContainerBuilder builder)
        {
            //Database
            builder.RegisterType<UserContext>().As<IUserContext>().InstancePerLifetimeScope();
            builder.RegisterType<SqlDatabase>().As<IDatabase>()
                .WithParameter("nameOrConnectionString", "ConnectionString").InstancePerLifetimeScope();

            ////UEL
            //builder.RegisterType<UELService>().As<IUELService>().InstancePerLifetimeScope();

            ////Repo
            //builder.RegisterType<GermplasmRepository>().As<IGermplasmRepository>().InstancePerLifetimeScope();
            ////Sync
            //builder.RegisterType<GermplasmService>().As<IGermplasmService>().InstancePerLifetimeScope();
            //builder.RegisterType<SynchronizationService>().As<ISynchronizationService>().InstancePerLifetimeScope();

            //Repositories
            builder.RegisterType<DataValidationRepository>().As<IDataValidationRepository>().InstancePerLifetimeScope();
            builder.RegisterType<TestRepository>().As<ITestRepository>().InstancePerLifetimeScope();
            builder.RegisterType<EmailConfigRepository>().As<IEmailConfigRepository>().InstancePerLifetimeScope();
            builder.RegisterType<ExternalTestRepository>().As<IExternalTestRepository>().InstancePerLifetimeScope();
            //Services

            builder.RegisterType<DataValidationService>().As<IDataValidationService>().InstancePerLifetimeScope();
            builder.RegisterType<TestService>().As<ITestService>().InstancePerLifetimeScope();
            builder.RegisterType<EmailConfigService>().As<IEmailConfigService>().InstancePerLifetimeScope();
            builder.RegisterType<EmailService>().As<IEmailService>().InstancePerLifetimeScope();
            builder.RegisterType<ExternalTestService>().As<IExternalTestService>().InstancePerLifetimeScope();
        }
    }
}
