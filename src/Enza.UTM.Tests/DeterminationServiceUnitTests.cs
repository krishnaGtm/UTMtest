using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using Autofac;
using Enza.UTM.BusinessAccess;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.Common.Exceptions;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using FakeItEasy;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Enza.UTM.Tests
{
    [TestClass]
    public class DeterminationServiceUnitTests
    {
        private IDeterminationService _determinationService;
        private ContainerBuilder builder;
        private DeterminationRequestArgs determinationRequestArgs;
        private DataWithMarkerRequestArgs dataWithMarkerRequestArgs;
        private MaterialsWithMarkerRequestArgs materialsWithMarkerRequestArgs;
        private ExternalDeterminationRequestArgs externalDeterminationRequestArgs;

        public DeterminationServiceUnitTests()
        {
            builder = new ContainerBuilder();
            builder.RegisterModule<AutofacModule>();
            IEnumerable<DeterminationResult> determinationlists = new List<DeterminationResult>()
            {
                new DeterminationResult{DeterminationID =1, DeterminationName = "Test1",DeterminationAlias = "T1",ColumnLabel ="Col1"},
                new DeterminationResult{DeterminationID =2, DeterminationName = "Test2",DeterminationAlias = "T2",ColumnLabel ="Col2"}
            };

            determinationRequestArgs = new DeterminationRequestArgs
            {
                CropCode = "TO",
                TestID = 1,
                TestTypeID = 1
            };

            dataWithMarkerRequestArgs = new Entities.Args.DataWithMarkerRequestArgs
            {
                TestID = 1,
                PageNumber = 1,
                PageSize = 100
            };

            materialsWithMarkerRequestArgs = new Entities.Args.MaterialsWithMarkerRequestArgs
            {
                TestID = 1,
                PageNumber = 1,
                PageSize = 100
            };
            externalDeterminationRequestArgs = new Entities.Args.ExternalDeterminationRequestArgs
            {
                CropCode = "TO",
                TestTypeID = 1
            };

            var dataWithMarker = new DataWithMarkerResult
            {
                Data = new DataTable(),
                Total = 5
            };
            var materialWithMarker = new MaterialsWithMarkerResult
            {
                Total = 5,
                Data = new DataTable()
            };

            var determinationRepo = A.Fake<IDeterminationRepository>();
            
            A.CallTo(() => determinationRepo.GetDeterminationsAsync(determinationRequestArgs)).Returns(determinationlists);
            A.CallTo(() => determinationRepo.GetDataWithDeterminationsAsync(dataWithMarkerRequestArgs)).Returns(dataWithMarker);
            A.CallTo(() => determinationRepo.GetMaterialsWithDeterminationsAsync(materialsWithMarkerRequestArgs)).Returns(materialWithMarker);
            A.CallTo(() => determinationRepo.GetDeterminationsForExternalTestsAsync(externalDeterminationRequestArgs)).Returns(determinationlists);
            A.CallTo(() => determinationRepo.GetMaterialsWithDeterminationsForExternalTestAsync(materialsWithMarkerRequestArgs)).Returns(materialWithMarker);

            builder.RegisterInstance(determinationRepo).As<IDeterminationRepository>().SingleInstance();

            var container = builder.Build();
            _determinationService = container.Resolve<IDeterminationService>();
        }
        
        [TestMethod]
        public async Task GetDeterminationAsyncTestMathod()
        {
            var data = await _determinationService.GetDeterminationsAsync((determinationRequestArgs));
            Assert.AreEqual(2, data.Count());
        }

        [TestMethod]
        public async Task GetDataWithDeterminationsAsync()
        {
            var result = await _determinationService.GetDataWithDeterminationsAsync(dataWithMarkerRequestArgs);
            Assert.AreEqual(result.Total, 5);
        }

        [TestMethod]
        public async Task GetMaterialsWithDeterminationsAsync()
        {
            var result = await _determinationService.GetMaterialsWithDeterminationsAsync(materialsWithMarkerRequestArgs);
            Assert.AreEqual(result.Total, 5);
        }

        [TestMethod]
        public async Task GetDeterminationsForExternalTestsAsync()
        {
            var result = await _determinationService.GetDeterminationsForExternalTestsAsync(externalDeterminationRequestArgs);
            Assert.AreEqual(result.Count(), 2);
        }
        [TestMethod]
        public async Task GetMaterialsWithDeterminationsForExternalTestAsync()
        {
            var result = await _determinationService.GetMaterialsWithDeterminationsForExternalTestAsync(materialsWithMarkerRequestArgs);
            Assert.AreEqual(result.Total, 5);
        }
    }
}
