using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using Enza.UTM.Common.Exceptions;
using Enza.UTM.DataAccess.Abstract;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using System.Configuration;
using Enza.UTM.Common.Extensions;

namespace Enza.UTM.DataAccess.Data.Repositories
{
    public class TestRepository : Repository<TestLookup>, ITestRepository
    {
        private readonly IUserContext userContext;
        public TestRepository(IDatabase dbContext, IUserContext userContext) : base(dbContext)
        {
            this.userContext = userContext;
        }

        public async Task<IEnumerable<TestLookup>> GetLookupAsync(string cropCode, string breedingStationCode)
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_GET_TESTS_LOOKUP, CommandType.StoredProcedure, args => 
            {
                args.Add("@CropCode", cropCode);
                args.Add("@BreedingStationCode", breedingStationCode);
            }, reader => new TestLookup
            {
                TestID = reader.Get<int>(0),
                TestName = reader.Get<string>(1),
                TestTypeID = reader.Get<int>(2),
                TestTypeName = reader.Get<string>(3),
                Remark = reader.Get<string>(4),
                RemarkRequired = reader.Get<bool>(5),
                StatusCode = reader.Get<int>(6),
                FixedPostionAssigned = reader.Get<bool>(7),
                MaterialStateID = reader.Get<int?>(8),
                MaterialTypeID = reader.Get<int?>(9),
                ContainerTypeID = reader.Get<int?>(10),
                MaterialReplicated = reader.Get<bool>(11),
                PlannedDate = reader.Get<DateTime>(12),
                Isolated = reader.Get<bool>(13),
                SlotID = reader.Get<int?>(14),
                WellsPerPlate = reader.Get<int>(15),
                BreedingStationCode = reader.Get<string>(16),
                CropCode = reader.Get<string>(17),
                ExpectedDate = reader.Get<DateTime>(18),
                SlotName = reader.Get<string>(19),
                PlatePlanName = reader.Get<string>(20),
                Source = reader.Get<string>(21),
                Cumulate = reader.Get<bool>(22),
                ImportLevel = reader.Get<string>(23)
            });
        }

        public async Task<bool> UpdateTestStatusAsync(UpdateTestStatusRequestArgs request)
        {
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_UPDATE_TESTSTATUS, CommandType.StoredProcedure,
                args =>
                {
                    args.Add("@TestID", request.TestId);
                    args.Add("@StatusCode", request.StatusCode);
                });
            return true;
        }

        public async Task<bool> SaveRemarkAsync(SaveRemarkRequestArgs request)
        {
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_SAVEREMARK, CommandType.StoredProcedure,
               args =>
               {
                   args.Add("@TestID", request.TestId);
                   args.Add("@Remark", request.Remark);
               });

            return true;
        }

        public async Task<IEnumerable<PlateLabel>> GetPlateLabelsAsync(int testID)
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_GET_PLATE_LABELS,
                CommandType.StoredProcedure,
                args =>
                {
                    args.Add("@TestID", testID);
                    //args.Add("@UserID", userContext.GetContext().FullName);
                }, reader => new PlateLabel
                {
                    BreedingStationCode = reader.Get<string>(0),
                    CropCode = reader.Get<string>(1),
                    PlateName = reader.Get<string>(2),
                    PlateNumber = reader.Get<int?>(3)
                });
        }

        public async Task<TestForLIMS> ReservePlatesInLimsAsync(int testId)
        {
            var userName = userContext.GetContext().FullName;
            var data = await DbContext.ExecuteReaderAsync<TestForLIMS>(DataConstants.PR_GET_TESTINFO_FOR_LIMS,
                CommandType.StoredProcedure,
                args =>
                {
                    args.Add("@TestID", testId);
                    //args.Add("@UserID", userName);
                    args.Add("@MaxPlates", ConfigurationManager.AppSettings["App:MaxNoOfPlates"].ToInt64());
                }, reader => new TestForLIMS
                {
                    PlannedYear = reader.Get<int?>(0),
                    TotalPlates = reader.Get<int>(1),
                    TotalTests = reader.Get<int>(2),
                    SynCode = reader.Get<string>(3),
                    Remark = reader.Get<string>(4),
                    Isolated = reader.Get<string>(5),
                    CropCode = reader.Get<string>(6),
                    PlannedWeek = reader.Get<int?>(7),
                    MaterialState = reader.Get<string>(8),
                    MaterialType = reader.Get<string>(9),
                    ContainerType = reader.Get<string>(10),
                    ExpectedYear = reader.Get<int?>(11),
                    ExpectedWeek = reader.Get<int?>(12),
                    CountryCode = reader.Get<string>(13),
                    PlannedDate = reader.Get<string>(14),
                    ExpectedDate = reader.Get<string>(15)
                });

            return data.FirstOrDefault();
        }

        public async Task<PlateForLimsResult> GetPlatesForLimsAsync(int testID)
        {
            var ds = await DbContext.ExecuteDataSetAsync(DataConstants.PR_GET_PLATES_FOR_LIMS,
                CommandType.StoredProcedure, args =>
                {
                    args.Add("@TestID", testID);
                    //args.Add("@UserID", userContext.GetContext().FullName);
                });
            var items = ds.Tables[0].AsEnumerable()
                .Select(o => new
                {
                    CropCode = o.Field<string>("CropCode"),
                    LimsPlateplanID = o.Field<int?>("LimsPlateplanID"),
                    RequestID = o.Field<int>("RequestID"),
                    LimsPlateID = o.Field<int>("LimsPlateID"),
                    LimsPlateName = o.Field<string>("LimsPlateName"),
                    PlateColumn = o.Field<string>("PlateColumn"),
                    PlateRow = o.Field<string>("PlateRow"),
                    PlantNr = o.Field<string>("PlantNr"),
                    PlantName = o.Field<string>("PlantName"),
                    BreedingStationCode = o.Field<string>("BreedingStationCode")
                }).ToList();

            if (!items.Any())
                throw new BusinessException($"Couldn't find any plate information of the specified TestID = {testID}.");

            var markers = ds.Tables[1].AsEnumerable()
                .Select(o => new
                {
                    LimsPlateID = o.Field<int>("LimsPlateID"),
                    MarkerNr = o.Field<int>("MarkerNr"),
                    MarkerName = o.Field<string>("MarkerName"),
                });

            var plates = items.GroupBy(g => new {g.LimsPlateID, g.LimsPlateName})
                .Select(o => new PlateInfo
                {
                    LimsPlateID = o.Key.LimsPlateID,
                    LimsPlateName = o.Key.LimsPlateName,
                    Wells = o.OrderBy(x=> x.PlateRow).ThenBy(x=>x.PlateColumn).Select(w => new WellInfo
                    {
                        PlateColumn = w.PlateColumn,
                        PlateRow = w.PlateRow,
                        PlantNr = w.PlantNr,
                        PlantName = w.PlantName,
                        BreedingStationCode = w.BreedingStationCode
                    }).ToList(),
                    Markers = markers.Where(m => m.LimsPlateID == o.Key.LimsPlateID).Select(m => new MarkerInfo
                    {
                        MarkerNr = m.MarkerNr,
                        MarkerName = m.MarkerName
                    }).ToList()
                }).OrderBy(x=>x.LimsPlateID).ToList();

            var plate = items.FirstOrDefault();
            var rs = new PlateForLimsResult
            {
                CropCode = plate.CropCode,
                LimsPlatePlanID = plate.LimsPlateplanID,
                RequestID = plate.RequestID,
                Plates = plates
            };
            return rs;
        }       
        public async Task<Test> GetTestDetailAsync(GetTestDetailRequestArgs request)
        {
            var data = await DbContext.ExecuteReaderAsync(DataConstants.PR_GET_TEST_DETAIL,
                CommandType.StoredProcedure,
                args =>
                {
                    args.Add("@TestID", request.TestID);
                    //args.Add("@UserID", userContext.GetContext().FullName);
                }, reader => new Test
                {
                    TestID = reader.Get<int>(0),
                    StatusCode = reader.Get<int>(1)
                });

            return data.FirstOrDefault();
        }

        public async Task<bool> ReservePlateplansInLIMSCallbackAsync(ReservePlateplansInLIMSCallbackRequestArgs requestArgs)
        {
            DbContext.CommandTimeout = 300;//5 minutes
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_ASSIGNLIMSPLATE, CommandType.StoredProcedure,
               args =>
               {                   
                   //args.Add("@UserID", requestArgs.UserID);
                   args.Add("@LIMSPlateplanID", requestArgs.LIMSPlatePlanID);
                   args.Add("@LIMSPlateplanName", requestArgs.LIMSPlatePlanName);
                   args.Add("@TestID", requestArgs.TestID);
                   args.Add("@TVP_Plates", requestArgs.ToTVPPlates());
               });
            return true;
        }

        public async Task<bool> SavePlannedDateAsync(SavePlannedDateRequestArgs request)
        {
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_SAVEPLANNEDDATE, CommandType.StoredProcedure,
               args =>
               {
                   args.Add("@TestID", request.TestID);
                   //args.Add("@UserID", userContext.GetContext().FullName);
                   args.Add("@PlannedDate", request.PlannedDate);
                   
               });
            return true;
        }

        public async Task<bool> ReserveScoreResult(ReceiveScoreArgs receiveScoreArgs)
        {
            DbContext.CommandTimeout = 300;//5 minutes
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_SAVE_SCORE, CommandType.StoredProcedure,
               args =>
               {
                   args.Add("@TestID", receiveScoreArgs.RequestID);
                   args.Add("@TVP_ScoreResult", receiveScoreArgs.ToScoreResultDataTable());
               });
            return true;
        }
        public async Task<bool> UpdateTest(UpdateTestArgs updatetestArgs)
        {
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_UPDATE_TEST, CommandType.StoredProcedure,
              args =>
              {
                  args.Add("@TestID", updatetestArgs.TestID);
                  //args.Add("@UserID", userContext.GetContext().FullName);
                  args.Add("@ContainerTypeID", updatetestArgs.ContainerTypeID);
                  args.Add("@Isolated", updatetestArgs.Isolated);
                  args.Add("@MaterialTypeID", updatetestArgs.MaterialTypeID);
                  args.Add("@MaterialStateID", updatetestArgs.MaterialStateID);
                  args.Add("@PlannedDate", updatetestArgs.PlannedDate);
                  args.Add("@TestTypeID", updatetestArgs.TestTypeID);
                  args.Add("@ExpectedDate", updatetestArgs.ExpectedDate);
                  args.Add("@Cumulate", updatetestArgs.Cumulate);
              });
            return true;
        }
        

        public async Task<IEnumerable<ContainerType>> GetContainerTypeLookupAsync()
        {
            const string query = "SELECT ContainerTypeID, ContainerTypeCode, ContainerTypeName FROM ContainerType";
            return await DbContext.ExecuteReaderAsync(query, reader => new ContainerType
            {
                ContainerTypeID = reader.Get<int>(0),
                ContainerTypeCode = reader.Get<string>(1),
                ContainerTypeName = reader.Get<string>(2)
            });
        }

        public async Task<IEnumerable<SlotForTestResult>> GetSlotForTest(int testID)
        {
            var data = await DbContext.ExecuteReaderAsync(DataConstants.PR_GET_SLOT_FOR_TEST,
                CommandType.StoredProcedure,
                args =>
                {
                    args.Add("@TestID", testID);
                    
                }, reader => new SlotForTestResult
                {
                    SlotID = reader.Get<int>(0),
                    SlotName = reader.Get<string>(1)
                });
            return data;
            
        }

        public async Task<Test> LinkSlotToTest(SaveSlotTestRequestArgs requestargs)
        {
            var data = await DbContext.ExecuteReaderAsync(DataConstants.PR_SAVE_SLOTTEST, CommandType.StoredProcedure,
             args =>
             {
                 args.Add("@TestID", requestargs.TestID);
                 //args.Add("@UserID", userContext.GetContext().FullName);
                 args.Add("@SlotID", requestargs.SlotID);

             }, reader => new Test
             {
                 TestID = reader.Get<int>(0),
                 StatusCode = reader.Get<int>(1)
             });

            return data.FirstOrDefault();
        }

        public Task SaveNrOfSamplesAsync(SaveNrOfSamplesRequestArgs request)
        {
            var data = request.Samples.Select(x => new
            {
                id = x.MaterialID,
                nr = x.NrOfSample
            }).ToList();

            return DbContext.ExecuteNonQueryAsync(DataConstants.PR_SAVE_NR_OF_SAMPLES,
                CommandType.StoredProcedure,
              args =>
              {
                  args.Add("@FileID", request.FileID);
                  args.Add("@DATA", data.ToJson());
              });
        }

        public async Task<bool> MarkSentResult(string wellIDS,int testID)
        {
             await DbContext.ExecuteNonQueryAsync(DataConstants.PR_MARK_SENT_RESULT,
               CommandType.StoredProcedure,
             args =>
             {
                 args.Add("@WellID", wellIDS);
                 args.Add("@TestID", testID);
             });
            return true;
        }

        public async Task DeleteTestAsync(DeleteTestRequestArgs requestargs)
        {
            
            var p1 = DbContext.CreateOutputParameter("@Status", DbType.Int32);
            var p2 = DbContext.CreateOutputParameter("@PlatePlanName", DbType.String,1000);
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_DELETE_TEST,
              CommandType.StoredProcedure,
            args =>
            {
                args.Add("@TestID", requestargs.TestID);
                args.Add("@ForceDelete", requestargs.IsLabUser);
                args.Add("@Status", p1);
                args.Add("@PlatePlanName", p2);
            });
            requestargs.StatusCode = p1.Value.ToInt32();
            requestargs.PlatePlanName = p2.Value.ToText();
           
        }

        public Task<IEnumerable<TraitDeterminationResultTest>> GetTestsForTraitDeterminationResultsAsync(string source)
        {
            var query = @"SELECT 
		                        T.TestID,
		                        T.TestName,
		                        T.StatusCode,
                                T.LabPlatePlanName,
                                T.BreedingStationCode	
	                        FROM Test T 
	                        WHERE T.RequestingSystem  = @Source AND T.StatusCode BETWEEN 600 AND 650 AND TestTypeID = 1";
            return DbContext.ExecuteReaderAsync(query, CommandType.Text, args =>
            {
                args.Add("@Source", source);
            },
            reader => new TraitDeterminationResultTest
            {
                TestID = reader.Get<int>(0),
                TestName = reader.Get<string>(1),
                StatusCode = reader.Get<int>(2),
                PlatePlanName = reader.Get<string>(3),
                BrStationCode = reader.Get<string>(4)
            });
        }

        public async Task<PlatePlanResult> getPlatePlanOverviewAsync(PlatePlanRequestArgs requestArgs)
        {
            var ds = await DbContext.ExecuteDataSetAsync(DataConstants.PR_GET_PLATE_PLAN_OVERVIEW, 
                CommandType.StoredProcedure,
                args =>
                {
                    args.Add("@Active", requestArgs.Active);
                    args.Add("@Crops", requestArgs.Crops);
                    args.Add("@Filter", requestArgs.ToFilterString());
                    args.Add("@Sort", "");
                    args.Add("@Page", requestArgs.PageNumber);
                    args.Add("@PageSize", requestArgs.PageSize);
                });

            var dt = ds.Tables[0];
            var result = new PlatePlanResult();
            if (dt.Rows.Count > 0)
            {
                result.Total = dt.Rows[0]["TotalRows"].ToInt32();
                dt.Columns.Remove("TotalRows");
            }
            result.Data = dt;
            return result;
        }

        public async Task<TraitDeterminationValue> GetTraitValue(string cropCode, string columnLabel)
        {
            var query = @"SELECT TDR.TraitResChar 
                                FROM Trait T
                                JOIN CropTrait CT ON CT.TraitID = T.TraitID
                                JOIN RelationTraitDetermination RTD on RTD.CropTraitID = CT.CropTraitID
                                JOIN TraitDeterminationResult TDR ON TDR.RelationID = RTD.RelationID
                                WHERE CT.CropCode = @CropCode
                                    AND TDR.DetResChar = '5555'
                                    AND T.ColumnLabel = @ColumnLabel";
            var res =  await DbContext.ExecuteReaderAsync(query,
                CommandType.Text,
                args =>
                {
                    args.Add("@CropCode", cropCode);
                    args.Add("@ColumnLabel", columnLabel);
                }, reader => new TraitDeterminationValue
                {
                    ColumnLabel = columnLabel,
                    CropCode = cropCode,
                    DeterminationValue = "5555",
                    TraitValue = reader.Get<string>(0)

                });
            return res.FirstOrDefault();
            

        }

        public async Task<DataSet> PlatePlanResultAsync(int testID)
        {
            return await DbContext.ExecuteDataSetAsync(DataConstants.PR_GET_PLATEPLAN_WITH_RESULT, CommandType.StoredProcedure, args =>
            {
                args.Add("@TestID", testID);
            });
            
        }
        public async Task<DataSet> TestToExcelAsync(int testID)
        {
            return await DbContext.ExecuteDataSetAsync(DataConstants.PR_GET_TEST_WITH_PLATE_AND_WELL, CommandType.StoredProcedure, args =>
            {
                args.Add("@TestID", testID);
            });

        }
        public async Task<int> GetTotalMarkerAsync(int testID)
        {
            var p1 = DbContext.CreateOutputParameter("@TotalMarker", DbType.Int32);
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_GET_TOTAL_MARKER,
              CommandType.StoredProcedure,
            args =>
            {
                args.Add("@TestID", testID);
                args.Add("@TotalMarker", p1);
            });
            return p1.Value.ToInt32();
        }

        public async Task<bool> GetSettingToExcludeScoreAsync(int testId)
        {
            var query = @"SELECT 
                                T.TestID
                        FROM [Test] T
                        JOIN[File] F ON F.FileID = T.FileID
                        JOIN CropRD C ON C.CropCode = F.CropCode
                        WHERE T.TestID = @TestID AND ISNULL(C.ExcludeUndefindScore,0) = 1";
            var result = await DbContext.ExecuteDataSetAsync(query, CommandType.Text,
                args =>
                {
                    args.Add("@TestID", testId);
                });
            if (result.Tables[0].Rows.Count > 0)
                return true;
            return false;
        }

        public async Task<Slot> GetSlotDetailForTestAsync(int testID)
        {
            var query = @"  SELECT  
                                S.SlotID, 
                                S.SlotName, 
                                S.Remark 
                            FROM Slot S 
                            JOIN SlotTest ST ON S.SlotID = ST.SlotID
                            WHERE ST.TestID = @TestID";

            var res = await DbContext.ExecuteReaderAsync(query,
                CommandType.Text,
                args =>
                {
                    args.Add("@TestID", testID);
                }, reader => new Slot
                {
                    SlotID = reader.Get<int>(0),
                    SlotName = reader.Get<string>(1),
                    Remarks = reader.Get<string>(2)

                }); 
            return res.FirstOrDefault();
        }
    }
}
