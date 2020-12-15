using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.DataAccess.Data.Interfaces
{
    public interface ITestRepository : IRepository<TestLookup>
    {
        Task<IEnumerable<TestLookup>> GetLookupAsync(string cropCode, string breedingStationCode);
        Task<bool> UpdateTestStatusAsync(UpdateTestStatusRequestArgs request);
        Task<bool> SaveRemarkAsync(SaveRemarkRequestArgs request);
        Task<bool> SavePlannedDateAsync(SavePlannedDateRequestArgs request);
        Task<IEnumerable<PlateLabel>> GetPlateLabelsAsync(int testID);
        Task<TestForLIMS> ReservePlatesInLimsAsync(int testID);
        Task<PlateForLimsResult> GetPlatesForLimsAsync(int testID);
        Task<Test> GetTestDetailAsync(GetTestDetailRequestArgs request);
        Task<bool> ReservePlateplansInLIMSCallbackAsync(ReservePlateplansInLIMSCallbackRequestArgs args);
        Task<bool> ReserveScoreResult(ReceiveScoreArgs receiveScoreArgs);
        Task<IEnumerable<ContainerType>> GetContainerTypeLookupAsync();
        Task<bool> UpdateTest(UpdateTestArgs args);
        Task<IEnumerable<SlotForTestResult>> GetSlotForTest(int testID);
        Task<Test> LinkSlotToTest(SaveSlotTestRequestArgs args);
        //Task<IEnumerable<TestResultCumulate>> CumulateAsync();
        //Task<IEnumerable<MigrationDataResult>> GetTraitDeterminationResultAsync(string source);
        Task SaveNrOfSamplesAsync(SaveNrOfSamplesRequestArgs args);
        Task<bool> MarkSentResult(string wellIDS,int testID);

        Task DeleteTestAsync(DeleteTestRequestArgs args);

        Task<IEnumerable<TraitDeterminationResultTest>> GetTestsForTraitDeterminationResultsAsync(string source);
        Task<string> GetCropOfTestAsync(int testID);
        Task<PlatePlanResult> getPlatePlanOverviewAsync(PlatePlanRequestArgs args);
        Task<TraitDeterminationValue> GetTraitValue(string cropCode, string columnLabel);
        Task<DataSet> PlatePlanResultAsync(int testID, bool? withControlPosition);
        Task<DataSet> TestToExcelAsync(int testID);
        Task<bool> GetSettingToExcludeScoreAsync(int testId);
        Task<int> GetTotalMarkerAsync(int testID);
        Task<Slot> GetSlotDetailForTestAsync(int testID);
    }
}
