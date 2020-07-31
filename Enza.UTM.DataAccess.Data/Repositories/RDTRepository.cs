using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Abstract;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using System.Configuration;
using Enza.UTM.Common.Extensions;
using Enza.UTM.Services.Proxies;
using System.Net;
using System.Net.Http;
using Enza.UTM.Services.Abstract;
using Enza.UTM.Common.Exceptions;
using System.Linq;
using Enza.UTM.Common;

namespace Enza.UTM.DataAccess.Data.Repositories
{
    public class RDTRepository : Repository<object>, IRDTRepository
    {
        private readonly IUserContext userContext;
        readonly IExcelDataRepository excelDataRepo;
        private readonly string BASE_SVC_URL = ConfigurationManager.AppSettings["BasePhenomeServiceUrl"];
        public RDTRepository(IDatabase dbContext, IUserContext userContext,IExcelDataRepository excelDataRepository) : base(dbContext)
        {
            this.userContext = userContext;
            this.excelDataRepo = excelDataRepository;
        }

        public async Task<PhenoneImportDataResult> ImportDataFromPhenomeAsync(HttpRequestMessage request, PhenomeImportRequestArgs args)
        {
            var result = new PhenoneImportDataResult();

            string cropCode = "";
            string breedingStation = "";
            string syncCode = "";
            string countryCode = "";

            #region prepare datatables for stored procedure call
            var dtCellTVP = new DataTable();
            var dtRowTVP = new DataTable();
            var dtListTVP = new DataTable();
            var dtColumnsTVP = new DataTable();
            var TVPS2SCapacity = new DataTable();

            PrepareTVPS(dtCellTVP, dtRowTVP, dtListTVP, dtColumnsTVP, TVPS2SCapacity);

            #endregion

            using (var client = new RestClient(BASE_SVC_URL))
            {
                var URI = "";
                client.SetRequestCookies(request);
                #region Get Variables detail from Tree Structure

                //call service to get crop code based on cropid
                URI = $"/api/v1/researchgroup/info/{ args.CropID}";
                var cropDetail = await GetFolderVariablesDetail(client, URI);
                if (!cropDetail.TryGetValue("Crop", out cropCode))
                {
                    result.Errors.Add("Crop code not found. Please add crop code first.");
                    return result;
                }
                if (string.IsNullOrWhiteSpace(cropCode))
                {
                    result.Errors.Add("CropCode can not be null or empty.");
                    return result;
                }


                //call service to get Breeding station and SyncCode based on breeding station level call on phenome from folder in tree structure.
                URI = $"/api/v1/folder/info/{ args.FolderID}";
                var breedingStationDetail = await GetFolderVariablesDetail(client, URI);
                if (!breedingStationDetail.TryGetValue("Breeding Station", out breedingStation) && !breedingStationDetail.TryGetValue("BreedStat", out breedingStation))
                {
                    result.Errors.Add("Breeding station not found. Please add Breeding station code first.");
                    return result;
                }

                if (string.IsNullOrWhiteSpace(breedingStation))
                {
                    result.Errors.Add("Breeding station can not be null or empty.");
                    return result;
                }
                //syncCode
                if (!breedingStationDetail.TryGetValue("SyncCode", out syncCode))
                {
                    result.Errors.Add("SyncCode not found. Please add SyncCode first.");
                    return result;
                }
                if (string.IsNullOrWhiteSpace(syncCode))
                {
                    result.Errors.Add("SyncCode can not be null or empty.");
                    return result;
                }
                //countrycode
                if (!breedingStationDetail.TryGetValue("Country", out countryCode))
                {
                    result.Errors.Add("Country not found. Please add Country first.");
                    return result;
                }
                if (string.IsNullOrWhiteSpace(countryCode))
                {
                    result.Errors.Add("Country can not be null or empty.");
                    return result;
                }

                #endregion


                if (args.ImportLevel.EqualsIgnoreCase("list"))
                    URI = "/api/v1/simplegrid/grid/create/FieldNursery";
                else
                    URI = "/api/v1/simplegrid/grid/create/FieldPlants";
                var response = await client.PostAsync(URI, values =>
                {
                    values.Add("object_type", args.ObjectType);
                    values.Add("object_id", args.ObjectID);
                    values.Add("grid_id", args.GridID);
                });
                await response.EnsureSuccessStatusCodeAsync();

                var columnResponse = await response.Content.DeserializeAsync<PhenomeColumnsResponse>();
                if (!columnResponse.Success)
                {
                    throw new UnAuthorizedException(columnResponse.Message);
                }

                if (!columnResponse.Columns.Any())
                {
                    result.Errors.Add("No columns found.");
                    return result;
                }
                if (!args.ForcedImport && columnResponse.Columns.Count > 50)
                {
                    result.Warnings.Add("You are importing more than 50 columns.This can lead to problem. We recommend to reduce the amount of columns in Phenome. Continue?");
                    return result;
                }

                if (args.ImportLevel.EqualsIgnoreCase("list"))
                    URI = "/api/v1/simplegrid/grid/get_json/FieldNursery?" +
                                                      $"object_type={args.ObjectType}&" +
                                                      $"object_id={args.ObjectID}&" +
                                                      $"grid_id={args.GridID}&" +
                                                      "add_header=1&" +
                                                      "posStart=0&" +
                                                      "count=99999";
                else
                    URI = "/api/v1/simplegrid/grid/get_json/FieldPlants?" +
                                                      $"object_type={args.ObjectType}&" +
                                                      $"object_id={args.ObjectID}&" +
                                                      $"grid_id={args.GridID}&" +
                                                      "add_header=1&" +
                                                      "posStart=0&" +
                                                      "count=99999";

                response = await client.GetAsync(URI);

                await response.EnsureSuccessStatusCodeAsync();

                var dataResponse = await response.Content.DeserializeAsync<PhenomeDataResponse>();
                var totalRecords = dataResponse.Properties.Max(x => x.Total_count);
                if (totalRecords <= 0)
                {
                    result.Errors.Add("No data to process.");
                    return result;
                }
                var getTraitID = new Func<string, int?>(o =>
                {
                    var traitid = 0;
                    if (int.TryParse(o, out traitid))
                    {
                        if (traitid > 0)
                            return traitid;
                    }
                    return null;
                });

                var columns1 = columnResponse.Columns.Select(x => new
                {
                    ID = x.id,
                    ColName = getTraitID(x.variable_id) == null ? x.desc : getTraitID(x.variable_id).ToString(),
                    DataType = string.IsNullOrWhiteSpace(x.data_type) || x.data_type == "C" ? "NVARCHAR(255)" : x.data_type,
                    ColLabel = x.desc,
                    TraitID = getTraitID(x.variable_id)
                }).GroupBy(g => g.ColName.Trim(), StringComparer.OrdinalIgnoreCase)
                .Select(y =>
                {
                    var elem = y.FirstOrDefault();
                    var item = new
                    {
                        ColumnName = elem.ColName,
                        elem.ID,
                        elem.DataType,
                        elem.ColLabel,
                        elem.TraitID
                    };
                    return item;
                });

                var columns2 = dataResponse.Columns.Select((x, i) => new
                {
                    ID = x.Properties[0].ID,
                    Index = i

                }).GroupBy(g => g.ID).Select(x => new
                {
                    ID = x.Key,
                    Index = x.FirstOrDefault().Index
                });


                var columns = (from t1 in columns1
                               join t2 in columns2 on t1.ID equals t2.ID
                               select new
                               {
                                   t2.ID,
                                   t2.Index,
                                   ColName = t1.ColumnName,
                                   t1.DataType,
                                   t1.ColLabel,
                                   t1.TraitID
                               }).ToList();

                if (columns.GroupBy(x => x.ColLabel.Trim(), StringComparer.OrdinalIgnoreCase).Any(g => g.Count() > 1))
                {
                    result.Errors.Add("Duplicate column found on " + args.Source);
                    return result;
                }

                var foundGIDColumn = false;
                var foundLotNrColumn = false;
                var foundEntryCode = false;
                var foundPlantName = false;
                var foundMasterNr = false;
                for (int i = 0; i < columns.Count; i++)
                {
                    var col = columns[i];
                    var dr = dtColumnsTVP.NewRow();
                    if (col.ColLabel.EqualsIgnoreCase("GID"))
                    {
                        foundGIDColumn = true;
                    }
                    else if (col.ColLabel.EqualsIgnoreCase("LotNr"))
                    {
                        foundLotNrColumn = true;
                    }
                    else if (col.ColLabel.EqualsIgnoreCase("MasterNr"))
                    {
                        foundMasterNr = true;
                    }
                    else if (col.ColLabel.EqualsIgnoreCase("Entry Code"))
                    {
                        foundEntryCode = true;
                    }
                    else if (col.ColLabel.EqualsIgnoreCase("plant name"))
                    {
                        foundPlantName = true;
                    }
                    dr["ColumnNr"] = i;
                    dr["TraitID"] = col.TraitID;
                    dr["ColumnLabel"] = col.ColLabel;
                    dr["DataType"] = col.DataType;
                    dtColumnsTVP.Rows.Add(dr);
                }

                var missedMendatoryColumns = new List<string>();

                if (!foundGIDColumn)
                {
                    missedMendatoryColumns.Add("GID");
                }
                if (!foundEntryCode)
                {
                    missedMendatoryColumns.Add("Entry Code");
                }
                if (!foundMasterNr)
                {
                    missedMendatoryColumns.Add("MasterNr");
                }
                if (args.ImportLevel.EqualsIgnoreCase("list") && !foundLotNrColumn)
                {
                    missedMendatoryColumns.Add("LotNr");
                }
                if (!args.ImportLevel.EqualsIgnoreCase("list") && !foundPlantName)
                {
                    missedMendatoryColumns.Add("Plant name");
                }
                

                if(missedMendatoryColumns.Any())
                {
                    result.Errors.Add("Please add following columns during import: "+ string.Join(",", missedMendatoryColumns));
                    return result;
                }
                var getColIndex = new Func<string, int>(name =>
                {
                    var fldName = columns.FirstOrDefault(o => o.ColLabel.EqualsIgnoreCase(name));
                    if (fldName != null)
                        return fldName.Index;
                    return -1;
                });

                for (int i = 0; i < dataResponse.Rows.Count; i++)
                {
                    var dr = dataResponse.Rows[i];
                    var drRow = dtRowTVP.NewRow();
                    drRow["RowNr"] = i;
                    drRow["MaterialKey"] = dr.Properties[0].ID;

                    //prepare rows for list tvp as well
                    var drList = dtListTVP.NewRow();
                    drList["RowID"] = dr.Properties[0].ID;
                    drList["GID"] = dr.Cells[getColIndex("GID")].Value;
                    drList["EntryCode"] = getColIndex("EntryCode") > 0 ? dr.Cells[getColIndex("EntryCode")].Value : "";


                    //foreach (var col in columns)
                    for (int j = 0; j < columns.Count; j++)
                    {
                        var col = columns[j];
                        var drCell = dtCellTVP.NewRow();
                        var cellval = dr.Cells[col.Index].Value;

                        if (col.ColLabel.EqualsIgnoreCase("GID"))
                        {
                            if (string.IsNullOrWhiteSpace(cellval))
                            {
                                result.Errors.Add("GID value can not be empty.");
                                return result;
                            }
                            else
                            {
                                drRow["GID"] = cellval;
                            }
                        }
                        drCell["RowID"] = i;
                        drCell["ColumnID"] = j;
                        drCell["Value"] = cellval;
                        dtCellTVP.Rows.Add(drCell);
                    }
                    dtListTVP.Rows.Add(drList);
                    dtRowTVP.Rows.Add(drRow);
                }
                //check for duplicate material key
                var data = dtRowTVP.AsEnumerable().Select(x => x.Field<string>("MaterialKey"))
                    .GroupBy(g => g)
                    .Select(x => new
                    {
                        MaterialKey = x.Key,
                        Count = x.Count()
                    });

                if (data.Any(x => x.MaterialKey.ToText() == string.Empty))
                {
                    result.Errors.Add("Material Key cannot be null or empty");
                }
                var keys = data.Where(x => x.Count > 1).ToList();
                if (keys.Any())
                {
                    var keylist = keys.Select(x => x.MaterialKey).ToList();
                    var key = keylist.Truncate();
                    result.Errors.Add($"Duplicate Material key {key}");
                }

                if (result.Errors.Any())
                {
                    return result;
                }

                result.CropCode = cropCode;
                result.BrStationCode = breedingStation;
                result.SyncCode = syncCode;
                result.CountryCode = countryCode;
                result.TVPColumns = dtColumnsTVP;
                result.TVPRows = dtRowTVP;
                result.TVPCells = dtCellTVP;
                result.TVPList = dtListTVP;

                //TestName and FilePath is same for Phenome
                args.FilePath = args.TestName;
                //import data into database
                await excelDataRepo.ImportDataAsync(result.CropCode, result.BrStationCode, result.SyncCode, result.CountryCode,
                    args, result.TVPColumns, result.TVPRows, result.TVPCells, result.TVPList);

                return result;
            }
        }

        public async Task<MaterialsWithMarkerResult> GetMaterialWithtTestsAsync(MaterialsWithMarkerRequestArgs args)
        {
            var result = new MaterialsWithMarkerResult();
            DbContext.CommandTimeout = 2 * 60; //time out is set to 2 minutes
            var data = await DbContext.ExecuteDataSetAsync(DataConstants.PR_RDT_GET_MATERIAL_WITH_TESTS, CommandType.StoredProcedure, args1 =>
            {
                args1.Add("@TestID", args.TestID);
                args1.Add("@Page", args.PageNumber);
                args1.Add("@PageSize", args.PageSize);
                args1.Add("@Filter", args.ToFilterString());
            });
            if (data.Tables.Count == 2)
            {
                var table0 = data.Tables[0];
                if (table0.Columns.Contains("TotalRows"))
                {
                    if (table0.Rows.Count > 0)
                    {
                        result.Total = table0.Rows[0]["TotalRows"].ToInt32();
                    }
                    table0.Columns.Remove("TotalRows");
                }
                result.Data = new
                {
                    Columns = data.Tables[1],
                    Data = table0
                };
            }
            return result;
        }

        public async Task<Test> AssignTestAsync(AssignDeterminationForRDTRequestArgs request)
        {
            var data = await DbContext.ExecuteReaderAsync(DataConstants.PR_SAVE_TEST_MATERIAL_DETERMINATION_ForRDT, CommandType.StoredProcedure, args =>
            {
                args.Add("@TestTypeID", request.TestTypeID);
                args.Add("@TestID", request.TestID);
                args.Add("@Columns", request.ToColumnsString());
                args.Add("@Filter", request.ToFilterString());
                args.Add("@TVPTestWithExpDate", request.ToTVPTestMaterialDetermation());
                args.Add("@Determinations", request.ToTVPDeterminations());
                args.Add("@TVPProperty", request.ToTVPPropertyValue());
            },
            reader => new Test
            {
                TestID = reader.Get<int>(0),
                StatusCode = reader.Get<int>(1)

            });
            return data.FirstOrDefault();

        }

        public async Task<RequestSampleTestResult> RequestSampleTestAsync(TestRequestArgs request)
        {
            //Prepare data
            var data = await DbContext.ExecuteReaderAsync(DataConstants.PR_RDT_GetMaterialForUpload, CommandType.StoredProcedure, args =>
            {
                args.Add("@TestID", request.TestID);
            },
            reader => new RequestSampleTest
            {
                Crop = reader.Get<string>(0),
                BrStation = reader.Get<string>(1),
                Country = reader.Get<string>(2),
                Level = reader.Get<string>(3),
                TestType = reader.Get<string>(4),
                RequestID = reader.Get<int>(5),
                RequestingSystem = reader.Get<string>(6),
                DeterminationID = reader.Get<int>(7),
                MaterialID = reader.Get<int>(8),
                Name = reader.Get<string>(9),
                ExpectedResultDate = reader.Get<string>(10),
                MaterialStatus = reader.Get<string>(11)

            });

            return await ExecuteRequestSampleTest(data.ToList());
        }

        private async Task<RequestSampleTestResult> ExecuteRequestSampleTest(List<RequestSampleTest> request)
        {
            await Task.Delay(1);
            var limsServiceUser = ConfigurationManager.AppSettings["LimsServiceUser"];


            var data = request.GroupBy(g => new { g.RequestID })
                .Select(o => new RequestSampleTestRequest
                {
                    Crop = o.FirstOrDefault().Crop,
                    BrStation = o.FirstOrDefault().BrStation,
                    Country = o.FirstOrDefault().Country,
                    Level = o.FirstOrDefault().Level,
                    TestType = o.FirstOrDefault().TestType,
                    RequestID = o.Key.RequestID,
                    RequestingUser = limsServiceUser,
                    RequestingName = limsServiceUser,
                    RequestingSystem = o.FirstOrDefault().RequestingSystem,
                    Determinations = o.GroupBy(y => y.DeterminationID).Select(p => new Entities.Results.DeterminationDT
                    {
                        DeterminationID = p.Key,
                        Materials = p.Select(q=>new Entities.Results.MaterialDT
                        {
                            MaterialID = q.MaterialID,
                            Name = q.Name,
                            ExpectedResultDate = q.ExpectedResultDate,
                            MaterialStatus = q.MaterialStatus
                        }).ToList()
                    }).ToList()
                }).FirstOrDefault();

            //var data1 = request.GroupBy(g => new { g.RequestID })
            //    .Select(o => new RequestSampleTestRequest
            //    {
            //        Crop = o.FirstOrDefault().Crop,
            //        BrStation = o.FirstOrDefault().BrStation,
            //        Country = o.FirstOrDefault().Country,
            //        Level = o.FirstOrDefault().Level,
            //        TestType = o.FirstOrDefault().TestType,
            //        RequestID = o.Key.RequestID,
            //        RequestingUser = limsServiceUser,
            //        RequestingName = limsServiceUser,
            //        RequestingSystem = o.FirstOrDefault().RequestingSystem,
            //        Determinations = o.Select(p => new Entities.Results.DeterminationDT
            //        {
            //            DeterminationID = p.DeterminationID,
            //            Materials = o.Where(q => q.DeterminationID == p.DeterminationID).Select(q => new Entities.Results.MaterialDT
            //            {
            //                MaterialID = p.MaterialID,
            //                Name = p.Name,
            //                ExpectedResultDate = p.ExpectedResultDate,
            //                MaterialStatus = p.MaterialStatus
            //            }).ToList()
            //        }).ToList()
            //    }).FirstOrDefault();

            var client = new LimsServiceRestClient();
            return client.RequestSampleTestAsync(data);
        }

        private void PrepareTVPS(DataTable dtCellTVP, DataTable dtRowTVP, DataTable dtListTVP, DataTable dtColumnsTVP, DataTable TVPS2SCapacity)
        {

            dtCellTVP.Columns.Add("RowID", typeof(int));
            dtCellTVP.Columns.Add("ColumnID", typeof(int));
            dtCellTVP.Columns.Add("Value");

            dtRowTVP.Columns.Add("RowNr");
            dtRowTVP.Columns.Add("MaterialKey");
            dtRowTVP.Columns.Add("GID");
            dtRowTVP.Columns.Add("EntryCode");

            dtListTVP.Columns.Add("RowID");
            dtListTVP.Columns.Add("GID");
            dtListTVP.Columns.Add("EntryCode");

            dtColumnsTVP.Columns.Add("ColumnNr", typeof(int));
            dtColumnsTVP.Columns.Add("TraitID");
            dtColumnsTVP.Columns.Add("ColumnLabel");
            dtColumnsTVP.Columns.Add("DataType");
        }

        private async Task<Dictionary<string, string>> GetFolderVariablesDetail(RestClient client, string uRI)
        {
            var rgDetail = await client.GetAsync(uRI);
            await rgDetail.EnsureSuccessStatusCodeAsync();
            var researchGroup = await rgDetail.Content.DeserializeAsync<PhenomeFolderInfo>();
            if (researchGroup != null)
            {
                if (researchGroup.Status != "1")
                {
                    throw new UnAuthorizedException(researchGroup.Message);
                }
                var values = (from t1 in researchGroup.Info.RG_Variables
                              join t2 in researchGroup.Info.BO_Variables on t1.VID equals t2.VID
                              select new
                              {
                                  t1.Name,
                                  t2.Value
                              }).ToList();
                return values.ToDictionary(k => k.Name, v => v.Value, StringComparer.OrdinalIgnoreCase);

            }
            return new Dictionary<string, string>();
        }

        public async Task<List<MaterialState>> GetmaterialStatusAsync()
        {
            var list = new List<MaterialState>()
            {
                new MaterialState{Code ="DH",Name = "DH"},
                new MaterialState{Code ="Breeding Line",Name = "Breeding Line"},
                new MaterialState{Code ="Parent",Name = "Parent"},
                new MaterialState{Code ="Variety",Name = "Variety"},
            };
            return list;
        }

        public async Task<PlatePlanResult> GetRDTtestsOverviewAsync(PlatePlanRequestArgs requestArgs)
        {
            var ds = await DbContext.ExecuteDataSetAsync(DataConstants.PR_RDT_GET_TEST_OVERVIEW,
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

        public async Task<RequestSampleTestCallbackResult> RequestSampleTestCallbackAsync(RequestSampleTestCallBackRequestArgs request)
        {
            await DbContext.ExecuteReaderAsync(DataConstants.PR_RDT_REQUEST_SAMPLE_TEST_CALLBACK, CommandType.StoredProcedure, args =>
            {
                args.Add("@TestID", request.RequestID);
                args.Add("@FolderName", request.FolderName);
                args.Add("@TVPDeterminationMaterial", request.ToTVPDeterminationMaterial());
            });

            return new RequestSampleTestCallbackResult() { Success = "True" };
        }

        public async Task<PrintLabelResult> PrintLabelAsync(PrintLabelForRDTRequestArgs reqArgs)
        {
            var printlabelResult = new List<PrintLabelResult>();
            //var result = await DbContext.ExecuteReaderAsync()
            //key of dictionary should contain following 
            //REFID,Testname, LimsID, MaterNr, GID, NrOfPlants (Flow 1)
            //REFID, TestName, LimsID, E-Number,LotNr, NrOfPlants (flow 2)
            //REFID, PlantName, LimsID, PlantID, 
            var resultdata = await DbContext.ExecuteReaderAsync(DataConstants.PR_RDT_GET_MATERIAL_TO_PRINT, CommandType.StoredProcedure, args =>
            {
                args.Add("@TestID", reqArgs.TestID);
                args.Add("@TVPMaterialStatus", string.Join(",", reqArgs.MaterialStatus));
                args.Add("@TVP_TMD", reqArgs.ToTMDTable());
            }, reader => new RDTPrintData
            {
                LimsID = reader.Get<int>(0),
                MaterialStatus = reader.Get<string>(1),
                NrOfPlants = reader.Get<int>(2),
                DeterminationName = reader.Get<string>(3),
                MaterialKey = reader.Get<string>(4),
                GID = reader.Get<string>(5),
                PlantName = reader.Get<string>(6),
                LotNr = reader.Get<string>(7),
                ENumber = reader.Get<string>(8),
                MasterNr = reader.Get<string>(9),
                ImportLevel = reader.Get<string>(10)

            });
            foreach (var _data in resultdata)
            {
                var dict = new Dictionary<string, string>();
                if (_data.ImportLevel.EqualsIgnoreCase("Plant"))
                {
                    dict["QRCODE"] = _data.LimsID.ToText();
                    dict["PLANTNAME"] = _data.PlantName;
                    dict["PLANTID"] = _data.MaterialKey;
                }
                else if (_data.MaterialStatus.EqualsIgnoreCase("variety") || _data.MaterialStatus.EqualsIgnoreCase("parent"))
                {

                    dict["QRCODE"] = _data.LimsID.ToText();
                    dict["TESTNAME"] = _data.DeterminationName;
                    dict["ENumber"] = _data.ENumber;
                    dict["LOTNR"] = _data.LotNr;
                    dict["NROFPLANTS"] = _data.NrOfPlants.ToText();
                }
                else
                {
                    dict["QRCODE"] = _data.LimsID.ToText();
                    dict["TESTNAME"] = _data.DeterminationName;
                    dict["LIMSID"] = _data.LimsID.ToText();
                    dict["MaterNr"] = _data.MasterNr;
                    dict["GID"] = _data.GID;
                    dict["NROFPLANTS"] = _data.NrOfPlants.ToText();
                }
                printlabelResult.Add(await PrintToBartenderAsync(dict));
            }
            var error =  printlabelResult.FirstOrDefault(x => !string.IsNullOrWhiteSpace(x.Error));
            if(error != null)
            {
                return new PrintLabelResult
                {
                    Error = "Some of the print request is not completed successfully",
                    Success = false,
                    PrinterName = error.PrinterName
                };
            }
            else
            {
                return printlabelResult.FirstOrDefault();
            }
        }

        private async Task<PrintLabelResult> PrintToBartenderAsync(Dictionary<string,string> data)
        {
            var labelType = ConfigurationManager.AppSettings["RDTPrinterLabelType"];
            if (string.IsNullOrWhiteSpace(labelType))
                throw new Exception("Please specify LabelType in settings.");

            var loggedInUser = userContext.GetContext().Name;
            var credentials = Credentials.GetCredentials();
            using (var svc = new BartenderSoapClient
            {
                Url = ConfigurationManager.AppSettings["BartenderServiceUrl"],
                Credentials = new NetworkCredential(credentials.UserName, credentials.Password)
            })
            {
                svc.Model = new
                {
                    User = loggedInUser,
                    LabelType = labelType,
                    Copies = 1,
                    LabelData = data
                    //LabelData = new Dictionary<string, string>
                    //{
                    //    { "QRCODE", data.LotID.ToString()},
                    //    { "STCK", data.GID.ToString()},
                    //    { "MSTR", data.MasterNrText },
                    //    { "PLNTNR", data.PlantNrText},
                    //    { "WGHT", data.Weight.ToString()},
                    //    { "NAME", "Comment"},
                    //    { "VALUE", data.TraitValue}
                    //}

                };
                var result = await svc.PrintToBarTenderAsync();
                return new PrintLabelResult
                {
                    Success = result.Success,
                    Error = result.Error,
                    PrinterName = labelType
                };
            }

        }
    }
    
}
