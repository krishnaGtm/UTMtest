using Autofac;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.BusinessAccess.Services;
using Enza.UTM.DataAccess.Databases;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.DataAccess.Data.Repositories;
using Enza.UTM.DataAccess.Data.Interfaces;

namespace Enza.UTM.Web.Services.Soap.Models
{
    public class AutofacModule : Module
    {
        protected override void Load(ContainerBuilder builder)
        {
            //Database
            builder.RegisterType<UserContext>().As<IUserContext>().InstancePerRequest();
            builder.RegisterType<SqlDatabase>().As<IDatabase>().WithParameter("nameOrConnectionString", "ConnectionString").InstancePerRequest();

            //Repositories            
            builder.RegisterType<TestRepository>().As<ITestRepository>().InstancePerRequest();
            builder.RegisterType<ExternalTestRepository>().As<IExternalTestRepository>().InstancePerRequest();
            builder.RegisterType<DataValidationRepository>().As<IDataValidationRepository>().InstancePerRequest();
            builder.RegisterType<EmailConfigRepository>().As<IEmailConfigRepository>().InstancePerRequest();

            //Services
            builder.RegisterType<TestService>().As<ITestService>().InstancePerRequest();
            builder.RegisterType<DataValidationService>().As<IDataValidationService>().InstancePerRequest();
            builder.RegisterType<EmailConfigService>().As<IEmailConfigService>().InstancePerRequest();
            builder.RegisterType<EmailService>().As<IEmailService>().InstancePerRequest();

        }
    }
}
