using System.Configuration;
using Autofac;
using Enza.UTM.DataAccess.Databases;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.DataAccess.Data.Planning.Repositories;
using Enza.UTM.DataAccess.Data.Planning.Interfaces;
using Enza.UTM.BusinessAccess.Planning.Services;
using Enza.UTM.BusinessAccess.Planning.Interfaces;
using Enza.UTM.DataAccess.Data.Repositories;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.BusinessAccess.Services;
using Enza.UTM.BusinessAccess.Interfaces;

namespace Enza.UTM.BusinessAccess.Planning
{
    public class AutofacModule : Module
    {
        protected override void Load(ContainerBuilder builder)
        {
            //Database
            builder.RegisterType<UserContext>().As<IUserContext>().InstancePerRequest();
            builder.RegisterType<SqlDatabase>().As<IDatabase>().WithParameter("nameOrConnectionString", "ConnectionString").InstancePerRequest();

            //Repositories            

            builder.RegisterType<CapacityRepository>().As<ICapacityRepository>().InstancePerRequest();
            builder.RegisterType<MasterDataRepository>().As<IMasterDataRepository>().InstancePerRequest();
            builder.RegisterType<SlotRepository>().As<ISlotRepository>().InstancePerRequest();
            builder.RegisterType<EmailConfigRepository>().As<IEmailConfigRepository>().InstancePerLifetimeScope();
            builder.RegisterType<MasterRepository>().As<IMasterRepository>().InstancePerLifetimeScope();

            //Services
            builder.RegisterType<CapacityService>().As<ICapacityService>().InstancePerRequest();
            builder.RegisterType<MasterDataService>().As<IMasterDataService>().InstancePerRequest();
            builder.RegisterType<SlotService>().As<ISlotService>().InstancePerRequest();
            builder.RegisterType<EmailConfigService>().As<IEmailConfigService>().InstancePerLifetimeScope();
            builder.RegisterType<EmailService>().As<IEmailService>().InstancePerLifetimeScope();
            builder.RegisterType<MasterService>().As<IMasterService>().InstancePerLifetimeScope();

            builder.RegisterType<MasterRepository>().As<IMasterRepository>().InstancePerLifetimeScope();
            builder.RegisterType<MasterService>().As<IMasterService>().InstancePerLifetimeScope();


            var env = ConfigurationManager.AppSettings["App:Environment"];
            if (env == "DEV")
            {
                //builder.RegisterType<Mocks.ScaleServiceMock>().As<IScaleService>().InstancePerRequest();
                //builder.RegisterType<Mocks.MasterDataServiceMock>().As<IMasterDataService>().InstancePerRequest();
                //builder.RegisterType<Mocks.EazyServiceMock>().As<IEazyService>().InstancePerRequest();
            }
            else
            {
                //builder.RegisterType<ExcelDataService>().As<IExcelDataService>().InstancePerRequest();
                //builder.RegisterType<MasterDataService>().As<IMasterDataService>().InstancePerRequest();
                //builder.RegisterType<EazyService>().As<IEazyService>().InstancePerRequest();
            }
        }
    }
}
