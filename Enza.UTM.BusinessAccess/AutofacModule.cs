using System.Configuration;
using Autofac;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.BusinessAccess.Services;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.DataAccess.Data.Repositories;
using Enza.UTM.DataAccess.Databases;
using Enza.UTM.DataAccess.Interfaces;

namespace Enza.UTM.BusinessAccess
{
    public class AutofacModule : Module
    {
        protected override void Load(ContainerBuilder builder)
        {
            //Database
            builder.RegisterType<UserContext>().As<IUserContext>().InstancePerLifetimeScope();
            builder.RegisterType<SqlDatabase>().As<IDatabase>().WithParameter("nameOrConnectionString", "ConnectionString").InstancePerLifetimeScope();

            //Repositories
            builder.RegisterType<ExcelDataRepository>().As<IExcelDataRepository>().InstancePerLifetimeScope();
            builder.RegisterType<TestTypeRepository>().As<ITestTypeRepository>().InstancePerLifetimeScope();
            builder.RegisterType<FileRepository>().As<IFileRepository>().InstancePerLifetimeScope();
            builder.RegisterType<DeterminationRepository>().As<IDeterminationRepository>().InstancePerLifetimeScope();
            builder.RegisterType<MaterialRepository>().As<IMaterialRepository>().InstancePerLifetimeScope();
            builder.RegisterType<TestRepository>().As<ITestRepository>().InstancePerLifetimeScope();
            builder.RegisterType<WellRepository>().As<IWellRepository>().InstancePerLifetimeScope();
            builder.RegisterType<PunchlistRepository>().As<IPunchlistRepository>().InstancePerLifetimeScope();
            builder.RegisterType<StatusRepository>().As<IStatusRepository>().InstancePerLifetimeScope();
            builder.RegisterType<TraitDeterminationRepository>().As<ITraitDeterminationRepository>().InstancePerLifetimeScope();
            builder.RegisterType<MasterRepository>().As<IMasterRepository>().InstancePerLifetimeScope();
            builder.RegisterType<DataValidationRepository>().As<IDataValidationRepository>().InstancePerLifetimeScope();
            builder.RegisterType<ThreeGBRepository>().As<IThreeGBRepository>().InstancePerLifetimeScope();
            builder.RegisterType<ExternalTestRepository>().As<IExternalTestRepository>().InstancePerLifetimeScope();
            builder.RegisterType<EmailConfigRepository>().As<IEmailConfigRepository>().InstancePerLifetimeScope();
            builder.RegisterType<S2SRepository>().As<IS2SRepository>().InstancePerLifetimeScope();
            builder.RegisterType<MaterialTypeTestProtocolRepository>().As<IMaterialTypeTestProtocolRepository>().InstancePerLifetimeScope();
            

            //Services
            builder.RegisterType<ExcelDataService>().As<IExcelDataService>().InstancePerLifetimeScope();
            builder.RegisterType<TestTypeService>().As<ITestTypeService>().InstancePerLifetimeScope();
            builder.RegisterType<FileService>().As<IFileService>().InstancePerLifetimeScope();
            builder.RegisterType<DeterminationService>().As<IDeterminationService>().InstancePerLifetimeScope();
            builder.RegisterType<MaterialService>().As<IMaterialService>().InstancePerLifetimeScope();
            builder.RegisterType<TestService>().As<ITestService>().InstancePerLifetimeScope();
            builder.RegisterType<WellService>().As<IWellService>().InstancePerLifetimeScope();
            builder.RegisterType<PunchlistService>().As<IPunchlistService>().InstancePerLifetimeScope();
            builder.RegisterType<StatusService>().As<IStatusService>().InstancePerLifetimeScope();
            builder.RegisterType<PhenomeServices>().As<IPhenomeServices>().InstancePerLifetimeScope();
            builder.RegisterType<TraitDeterminationService>().As<ITraitDeterminationService>().InstancePerLifetimeScope();
            builder.RegisterType<MasterService>().As<IMasterService>().InstancePerLifetimeScope();
            builder.RegisterType<DataValidationService>().As<IDataValidationService>().InstancePerLifetimeScope();
            builder.RegisterType<ThreeGBService>().As<IThreeGBService>().InstancePerLifetimeScope();
            builder.RegisterType<ExternalTestService>().As<IExternalTestService>().InstancePerLifetimeScope();
            builder.RegisterType<EmailConfigService>().As<IEmailConfigService>().InstancePerLifetimeScope();
            builder.RegisterType<EmailService>().As<IEmailService>().InstancePerLifetimeScope();
            builder.RegisterType<S2SService>().As<IS2SService>().InstancePerLifetimeScope();
            builder.RegisterType<MaterialTypeTestProtocolService>().As<IMaterialTypeTestProtocolService>().InstancePerLifetimeScope();

            //C&T
            builder.RegisterType<CNTRepository>().As<ICNTRepository>().InstancePerLifetimeScope();
            builder.RegisterType<CNTService>().As<ICNTService>().InstancePerLifetimeScope();

            //RDT
            builder.RegisterType<RDTRepository>().As<IRDTRepository>().InstancePerLifetimeScope();
            builder.RegisterType<RDTService>().As<IRDTService>().InstancePerLifetimeScope();


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
