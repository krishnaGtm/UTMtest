using System;
using System.Data;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Abstract;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using System.Configuration;
using System.Net.Http;
using Enza.UTM.Services.Abstract;
using System.Collections.Generic;
using Enza.UTM.Common.Extensions;
using Enza.UTM.Common.Exceptions;
using System.Linq;
using System.IO;

namespace Enza.UTM.DataAccess.Data.Repositories
{
    public class CNTRepository : Repository<object>, ICNTRepository
    {
        private readonly IUserContext _userContext;
        private readonly string BASE_SVC_URL = ConfigurationManager.AppSettings["BasePhenomeServiceUrl"];
        private readonly IExcelDataRepository _excelDataRepository;
        public CNTRepository(IDatabase dbContext, IUserContext userContext, IExcelDataRepository excelDataRepository) : base(dbContext)
        {
            _userContext = userContext;
            _excelDataRepository = excelDataRepository;
        }

        public Task<ExcelDataResult> GetDataAsync(ExcelDataRequestArgs requestArgs)
        {
            return _excelDataRepository.GetDataAsync(requestArgs);
        }

        public async Task<PhenoneImportDataResult> ImportDataFromPhenomeAsync(HttpRequestMessage request, CNTRequestArgs args)
        {
            var result = new PhenoneImportDataResult();

            var cropCode = "";
            var breedingStation = "";
            var syncCode = "";
            var countryCode = "";

            #region Prepare datatables for stored procedure call

            var dtCellTVP = new DataTable();
            var dtRowTVP = new DataTable();
            var dtListTVP = new DataTable();
            var dtColumnsTVP = new DataTable();

            PrepareTVPS(dtCellTVP, dtRowTVP, dtListTVP, dtColumnsTVP);

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

                if (cropCode != args.CropCode)
                {
                    result.Errors.Add("Crop code in Phenome and S2S capacity don't match with each other");
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
                //country code
                breedingStationDetail.TryGetValue("Country", out countryCode);

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

                var json1 = await response.Content.DeserializeAsync<PhenomeColumnsResponse>();
                if (!json1.Success)
                {
                    throw new UnAuthorizedException(json1.Message);
                }

                if (!json1.Columns.Any())
                {
                    result.Errors.Add("No columns found.");
                    return result;
                }

                //get field name from settings
                var donorColumnName = ConfigurationManager.AppSettings["CNT:DonorNrColumnName"];
                //required columns validations
                //validate if column Entry Code or another column defined in pipeline variables exists which is stored on Donor Number field
                var requiredFields = new List<string>
                {
                    "GID",
                    "name"
                };
                if (args.ImportLevel.EqualsIgnoreCase("list"))
                {
                    requiredFields.Add("Entry Code");
                }
                else
                {
                    requiredFields.Add(donorColumnName);
                }

                var notFoundColumns = requiredFields.Where(x => !json1.Columns.Any(y => y.desc.EqualsIgnoreCase(x)));
                if (notFoundColumns.Any())
                {
                    result.Errors.Add($"Following fields are required but not available in the Phenome grid: ({string.Join(",", notFoundColumns)}).");
                    return result;
                }

                if (!args.ForcedImport && json1.Columns.Count > 50)
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

                var response2 = await client.GetAsync(URI);
                await response2.EnsureSuccessStatusCodeAsync();

                var json2 = await response2.Content.DeserializeAsync<PhenomeDataResponse>();
                
                var totalRecords = json2.Properties.Max(x => x.Total_count);
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

                var columns1 = json1.Columns.Select(x => new
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

                var columns2 = json2.Columns.Select((x, i) => new
                {
                    x.Properties[0].ID,
                    Index = i

                }).GroupBy(g => g.ID).Select(x => new
                {
                    ID = x.Key,
                    x.FirstOrDefault().Index
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
                
                //var foundGIDColumn = false;
                //var foundNameColumn = false;
                for (int i = 0; i < columns.Count; i++)
                {
                    var col = columns[i];
                    var dr = dtColumnsTVP.NewRow();
                    //if (col.ColLabel.EqualsIgnoreCase("GID"))
                    //{
                    //    foundGIDColumn = true;
                    //}
                    //else if (col.ColLabel.EqualsIgnoreCase("name"))
                    //{
                    //    foundNameColumn = true;
                    //}
                    dr["ColumnNr"] = i;
                    dr["TraitID"] = col.TraitID;
                    dr["ColumnLabel"] = col.ColLabel;
                    dr["DataType"] = col.DataType;
                    dtColumnsTVP.Rows.Add(dr);
                }

                //if (!foundGIDColumn)
                //{
                //    result.Errors.Add("GID column not found. Please add GID column on data grid.");
                //    return result;
                //}
                //if (!foundNameColumn)
                //{
                //    result.Errors.Add("Name column not found. Please add Name column on data grid.");
                //    return result;
                //}
                var getColIndex = new Func<string, int>(name =>
                {
                    var fldName = columns.FirstOrDefault(o => o.ColLabel.EqualsIgnoreCase(name));
                    if (fldName != null)
                        return fldName.Index;
                    return -1;
                });

                for (int i = 0; i < json2.Rows.Count; i++)
                {
                    var dr = json2.Rows[i];

                    var drRow = dtRowTVP.NewRow();
                    drRow["RowNr"] = i;
                    drRow["MaterialKey"] = dr.Properties[0].ID;

                    //prepare rows for list tvp as well
                    var drList = dtListTVP.NewRow();
                    drList["RowID"] = dr.Properties[0].ID;
                    drList["GID"] = dr.Cells[getColIndex("GID")].Value;
                    drList["Name"] = getColIndex("Name") > 0 ? dr.Cells[getColIndex("Name")].Value : "";

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
                            drRow["GID"] = cellval;
                        }
                        else if (col.ColLabel.EqualsIgnoreCase("Name"))
                        {
                            if (string.IsNullOrWhiteSpace(cellval))
                            {
                                result.Errors.Add("Name value can not be empty.");
                                return result;
                            }
                            drRow["Name"] = cellval;
                            drList["Name"] = cellval;
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
                await ImportDataAsync(result.CropCode, result.BrStationCode, result.SyncCode, result.CountryCode,
                    args, result.TVPColumns, result.TVPRows, result.TVPCells, result.TVPList, donorColumnName);

                //get imported data
                var ds = await GetDataAsync(new ExcelDataRequestArgs
                {
                    TestID = args.TestID,
                    PageNumber = 1,
                    PageSize = 200
                });

                result.Total = ds.Total;
                result.DataResult = ds.DataResult;                
                return result;
            }
        }

        public async Task AssignMarkersAsync(CNTAssignMarkersRequestArgs requestArgs)
        {
            var columnNames = string.Join(",", requestArgs.Filter.Select(x => x.Name));
            var determinations = string.Join(",", requestArgs.Determinations);
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_CNT_ASSIGN_MARKERS, CommandType.StoredProcedure, args =>
            {
                args.Add("@TestID", requestArgs.TestID);
                args.Add("@Determinations", determinations);
                args.Add("@ColNames", columnNames);
                args.Add("@Filters", requestArgs.FiltersAsSQL());
            });
        }

        public async Task ManageMarkersAsync(CNTManageMarkersRequestArgs requestArgs)
        {
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_CNT_MANAGE_MARKERS, CommandType.StoredProcedure, args =>
            {
                args.Add("@TestID", requestArgs.TestID);
                args.Add("@MaterialsAsJson", requestArgs.Markers.ToJson());
            });
        }

        public async Task ManageInfoAsync(CNTManageInfoRequestArgs requestArgs)
        {
            var dataAsJson = requestArgs.ToJson();
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_CNT_MANAGE_INFO, CommandType.StoredProcedure, args =>
            {
                args.Add("@TestID", requestArgs.TestID);
                args.Add("@DataAsJson", dataAsJson);
            });
        }

        public async Task<MaterialsWithMarkerResult> GetDataWithMarkersAsync(MaterialsWithMarkerRequestArgs args)
        {
            var result = new MaterialsWithMarkerResult();
            DbContext.CommandTimeout = 2 * 60; //time out is set to 2 minutes
            var data = await DbContext.ExecuteDataSetAsync(DataConstants.PR_CNT_GET_DATA_WITH_MARKER, CommandType.StoredProcedure, args1 =>
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

        public async Task<byte[]> GetDataForExcelAsync(int testID)
        {
            //get data and only determination columns
            var data = await GetDataWithMarkerForExcelAsync(testID);
            //create excel file here
            var wb = new NPOI.XSSF.UserModel.XSSFWorkbook();
            var sheet1 = wb.CreateSheet("Sheet1");
            //write headers
            var header = sheet1.CreateRow(0);
            var ColNr = 0;
            int maxMarkers = 20;
            
            foreach (DataColumn dc in data.Columns)
            {
                ColNr = dc.Ordinal;
                //var cell = header.CreateCell(dc.Ordinal);
                if (!dc.ColumnName.EqualsIgnoreCase("Determinations"))
                {
                    var cell = header.CreateCell(ColNr);
                    cell.SetCellValue(dc.ColumnName);
                }
            }
            for (int i = 1; i <= maxMarkers; i++)
            {
                var cell = header.CreateCell(ColNr);
                cell.SetCellValue("Marker" + i.ToString("00"));
                ColNr++;
            }
            

            //write data
            var rowNr = 1;

            foreach(DataRow dr in data.Rows)
            {

                var row = sheet1.CreateRow(rowNr++);
                foreach(DataColumn dc in data.Columns)
                {
                    ColNr = dc.Ordinal;
                    var value = dr[dc.ColumnName].ToText();
                    if (dc.ColumnName.EqualsIgnoreCase("Determinations"))
                    {
                        var determinations = value.Split(',').ToList();
                        foreach(var determination in determinations)
                        {
                            var cell = row.CreateCell(ColNr);
                            cell.SetCellValue(determination);
                            ColNr++;
                        }
                        
                    }
                    else
                    {
                        var cell = row.CreateCell(ColNr);
                        cell.SetCellValue(value);
                    }
                }
            }

            byte[] result = null;
            using(var ms = new MemoryStream())
            {
                wb.Write(ms);
                //ms.Seek(0, SeekOrigin.Begin);
                result =  ms.ToArray();
            }
            return result;
        }

        #region Private Methods

        private void PrepareTVPS(DataTable dtCellTVP, DataTable dtRowTVP, DataTable dtListTVP, DataTable dtColumnsTVP)
        {
            dtCellTVP.Columns.Add("RowID", typeof(int));
            dtCellTVP.Columns.Add("ColumnID", typeof(int));
            dtCellTVP.Columns.Add("Value");

            dtRowTVP.Columns.Add("RowNr");
            dtRowTVP.Columns.Add("MaterialKey");
            dtRowTVP.Columns.Add("GID");
            dtRowTVP.Columns.Add("Name"); //"entry code" for other test type "Name" for s2s testtype.

            dtListTVP.Columns.Add("RowID");
            dtListTVP.Columns.Add("GID");
            dtListTVP.Columns.Add("Name");

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

        private async Task ImportDataAsync(string cropCode, string brStationCode, string syncCode, string countryCode, 
            CNTRequestArgs requestArgs, DataTable tVPColumns, DataTable tVPRows, 
            DataTable tVPCells, DataTable tVPList, string donorNrColumnName)
        {
            var p1 = DbContext.CreateInOutParameter("@TestID", requestArgs.TestID, DbType.Int32, int.MaxValue);
            DbContext.CommandTimeout = 5 * 60; //5 minutes
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_CNT_IMPORT_MATERIALS,
                CommandType.StoredProcedure, args =>
                {
                    args.Add("@TestID", p1);
                    args.Add("@TestTypeID", requestArgs.TestTypeID);
                    args.Add("@CropCode", cropCode);
                    args.Add("@BrStationCode", brStationCode);
                    args.Add("@SyncCode", syncCode);
                    args.Add("@CountryCode", countryCode);
                    args.Add("@UserID", _userContext.GetContext().FullName);
                    args.Add("@TestName", requestArgs.TestName);
                    args.Add("@Source", requestArgs.Source);
                    args.Add("@ObjectID", requestArgs.ObjectID);
                    args.Add("@ImportLevel", requestArgs.ImportLevel);
                    args.Add("@TVPColumns", tVPColumns);
                    args.Add("@TVPRow", tVPRows);
                    args.Add("@TVPCell", tVPCells);
                    args.Add("@TVPList", tVPList);
                    args.Add("@DonorNrColumnName", donorNrColumnName);
                    args.Add("@FileID", requestArgs.FileID);
                });
            requestArgs.TestID = p1.Value.ToInt32();
        }

        private async Task<DataTable> GetDataWithMarkerForExcelAsync(int testID)
        {
            //this will return dataset with data and only determination columns
            var ds =  await DbContext.ExecuteDataSetAsync(DataConstants.PR_CNT_GET_DATA_WITH_MARKER_FOR_EXCEL,
                CommandType.StoredProcedure, args =>
                {
                    args.Add("@TestID", testID);
                });
            return ds.Tables[0];
        }

        #endregion
    }
}