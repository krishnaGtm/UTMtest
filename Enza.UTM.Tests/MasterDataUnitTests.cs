using Autofac;
using Enza.UTM.BusinessAccess;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.Entities;
using FakeItEasy;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Enza.UTM.Tests
{
    [TestClass]
    public class MasterDataUnitTests
    {
        private IMasterService _masterService;
        private ContainerBuilder builder;

        public MasterDataUnitTests()
        {
            builder = new ContainerBuilder();
            builder.RegisterModule<AutofacModule>();
            IEnumerable<Crop> cropList = new List<Crop>()
            {
                new Crop{CropCode = "CC",CropName="Cauliflower"},
                new Crop{CropCode = "TO",CropName="Tomato"}
            };

            IEnumerable<BreedingStation> breedingStationList = new List<BreedingStation>()
            {
                new BreedingStation{BreedingStationCode = "NL",BreedingStationName="Netherlands"},
                new BreedingStation{BreedingStationCode = "NP",BreedingStationName="Nepal"},
            };
            var masterdatarepo = A.Fake<IMasterRepository>();
            A.CallTo(() => masterdatarepo.GetCropAsync()).Returns(cropList);
            A.CallTo(() => masterdatarepo.GetBreedingStationAsync()).Returns(breedingStationList);

            builder.RegisterInstance(masterdatarepo).As<IMasterRepository>().SingleInstance();

            var container = builder.Build();
            _masterService = container.Resolve<IMasterService>();
        }

        [TestMethod]
        public async Task GetCropTestMethod()
        {
            var croplist = await _masterService.GetCropAsync();
            Assert.AreEqual(2, croplist.Count());
           
        }

        [TestMethod]
        public async Task GetBreedingStationTestMethod()
        {
            var breedingStations = await _masterService.GetBreedingStationAsync();
            Assert.AreEqual(2, breedingStations.Count());

        }
    }
}
