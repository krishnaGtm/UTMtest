﻿using System;
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
                    dr["ColumnNr"] = i;
                    dr["TraitID"] = col.TraitID;
                    dr["ColumnLabel"] = col.ColLabel;
                    dr["DataType"] = col.DataType;
                    dtColumnsTVP.Rows.Add(dr);
                }

                if (!foundGIDColumn)
                {
                    result.Errors.Add("GID column not found. Please add GID column on data grid.");
                    return result;
                }
                if (args.ImportLevel.EqualsIgnoreCase("list") && !foundLotNrColumn)
                {
                    result.Errors.Add("LotNr column not found. Please add LotNr column on data grid.");
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

        public async Task<string> RequestSampleTestAsync(TestRequestArgs args)
        {
            return await ImplementRequestSampleTest();
        }

        private async Task<string> ImplementRequestSampleTest()
        {
            await Task.Delay(1);

            var client = new LimsServiceRestClient();
            return client.RequestSampleTestAsync();
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
    }
    
}
