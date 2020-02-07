using System;
using System.Threading.Tasks;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using Enza.UTM.Services.Abstract;
using System.Configuration;
using System.Net.Http;
using Enza.UTM.Common.Extensions;
using System.Linq;
using System.Data;
using Enza.UTM.Common.Exceptions;

namespace Enza.UTM.BusinessAccess.Services
{
    public class PhenomeServices : IPhenomeServices
    {
        private readonly string BASE_SVC_URL = ConfigurationManager.AppSettings["BasePhenomeServiceUrl"];

        readonly IExcelDataRepository excelDataRepo;
        private readonly ITestRepository _testRepository;
        public PhenomeServices(IExcelDataRepository excelDataRepo, ITestRepository testRepository)
        {
            this.excelDataRepo = excelDataRepo;
            _testRepository = testRepository;
        }

        public async Task<ExcelDataResult> GetPhenomeDataAsync(HttpRequestMessage request, PhenomeImportRequestArgs args)
        {
            PhenoneImportDataResult result = null;
            if (args.ImportLevel.EqualsIgnoreCase("LIST"))
            {
                result = await GetListDataFromPhenomeAsync(request, args);
            }
            else
            {
                result = await GetDataFromPhenomeAsync(request, args);
            }
            if (result.Errors.Any() || result.Warnings.Any())
            {
                return new ExcelDataResult
                {
                    Success = false,
                    Warnings = result.Warnings,
                    Errors = result.Errors
                };
            }
            //TestName and FilePath is same for Phenome
            args.FilePath = args.TestName;
            //import data into database
            await excelDataRepo.ImportDataAsync(result.CropCode, result.BrStationCode, result.SyncCode, result.CountryCode,
                args, result.TVPColumns, result.TVPRows, result.TVPCells,result.TVPList);
            return await excelDataRepo.GetDataAsync(args);
        }

        public async Task<PhenoneImportDataResult> GetDataFromPhenomeAsync(HttpRequestMessage request, PhenomeImportRequestArgs args)
        {
            var result = new PhenoneImportDataResult();

            string cropCode = "";
            string breedingStation = "";
            string syncCode = "";
            string countryCode = "";


            #region prepare datatables for stored procedure call
            var dtCellTVP = new DataTable();
            dtCellTVP.Columns.Add("RowID", typeof(int));
            dtCellTVP.Columns.Add("ColumnID", typeof(int));
            dtCellTVP.Columns.Add("Value");

            var dtRowTVP = new DataTable();
            dtRowTVP.Columns.Add("RowNr");
            dtRowTVP.Columns.Add("MaterialKey");
            dtRowTVP.Columns.Add("GID");
            dtRowTVP.Columns.Add("EntryCode");

            var dtListTVP = new DataTable();
            dtListTVP.Columns.Add("RowID");
            dtListTVP.Columns.Add("GID");
            dtListTVP.Columns.Add("EntryCode");

            var dtColumnsTVP = new DataTable("TVP_Column");
            dtColumnsTVP.Columns.Add("ColumnNr", typeof(int));
            dtColumnsTVP.Columns.Add("TraitID");
            dtColumnsTVP.Columns.Add("ColumnLabel");
            dtColumnsTVP.Columns.Add("DataType");
            #endregion

            using (var client = new RestClient(BASE_SVC_URL))
            {

                client.SetRequestCookies(request);

                var response = await client.PostAsync("/api/v1/simplegrid/grid/create/FieldPlants", values =>
                {
                    values.Add("object_type", args.ObjectType);
                    values.Add("object_id", args.ObjectID);
                    values.Add("grid_id", args.GridID);
                });
                await response.EnsureSuccessStatusCodeAsync();

                var json1 = await response.Content.DeserializeAsync<PhenomeColumnsResponse>();
                //var stringd = await response.Content.ReadAsStringAsync();
                if (!json1.Success)
                {
                    throw new UnAuthorizedException(json1.Message);
                }

                if (!json1.Columns.Any())
                {
                    result.Errors.Add("No columns found.");
                    return result;
                }

                if(!args.ForcedImport && json1.Columns.Count > 50)
                {
                    result.Warnings.Add("You are importing more than 50 columns.This can lead to problem. We recommend to reduce the amount of columns in Phenome. Continue?");
                    return result;
                }

                var response2 = await client.GetAsync("/api/v1/simplegrid/grid/get_json/FieldPlants?" +
                                                      $"object_type={args.ObjectType}&" +
                                                      $"object_id={args.ObjectID}&" +
                                                      $"grid_id={args.GridID}&" +
                                                      "add_header=1&" +
                                                      //$"rows_per_page=99999&" +
                                                      "posStart=0&" +
                                                      "count=99999");

                await response2.EnsureSuccessStatusCodeAsync();

                var json2 = await response2.Content.DeserializeAsync<PhenomeDataResponse>();
                //var stringvar = await response2.Content.ReadAsStringAsync();
                var totalRecords = json2.Properties.Max(x => x.Total_count);

                //if (totalRecords > ConfigurationManager.AppSettings["App:MaxNoOfRecords"].ToInt64())
                //{
                //    result.Errors.Add("Cannot import data having rows greater than " + ConfigurationManager.AppSettings["App:MaxNoOfRecords"]);
                //    return result;
                //}
                //if (!json2.Success)
                //{
                //    throw new UnAuthorizedException(json2.Message);
                //}
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
                }).GroupBy(g => g.ColName.Trim(),StringComparer.OrdinalIgnoreCase)
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

                //call service to get crop code based on cropid
                //https://onprem.unity.phenome-networks.com/api/v1/field/info/
                var rgDetail = await client.GetAsync($"/api/v1/researchgroup/info/{ args.CropID}");
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
                    var cropDetail = values.ToDictionary(k => k.Name, v => v.Value, StringComparer.OrdinalIgnoreCase);
                    if (!cropDetail.TryGetValue("Crop", out cropCode))
                    {
                        result.Errors.Add("Crop code not found. Please add crop code first.");
                        return result;
                    }
                    if (string.IsNullOrWhiteSpace(cropCode))
                    {
                        result.Errors.Add("Crop code can not be null or empty.");
                        return result;
                    }
                }

                //call service to get Breeding station based on breeding station level call on phenome.
                var folderDetail = await client.GetAsync($"/api/v1/folder/info/{ args.FolderID}");
                await folderDetail.EnsureSuccessStatusCodeAsync();

                //var test = await folderDetail.Content.ReadAsStringAsync();

                var folderInfo = await folderDetail.Content.DeserializeAsync<PhenomeFolderInfo>();
                if (folderInfo != null)
                {
                    if (folderInfo.Status != "1")
                    {
                        throw new UnAuthorizedException(researchGroup.Message);
                    }
                    var values = (from t1 in folderInfo.Info.RG_Variables
                                  join t2 in folderInfo.Info.BO_Variables on t1.VID equals t2.VID
                                  select new
                                  {
                                      t1.Name,
                                      t2.Value
                                  }).ToList();
                    var foldervalues = values.ToDictionary(k => k.Name, v => v.Value, StringComparer.OrdinalIgnoreCase);
                    if (!foldervalues.TryGetValue("Breeding Station", out breedingStation) && !foldervalues.TryGetValue("BreedStat", out breedingStation))
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
                    if (!foldervalues.TryGetValue("SyncCode", out syncCode))
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
                    if (!foldervalues.TryGetValue("Country", out countryCode))
                    {
                        result.Errors.Add("Country not found. Please add Country first.");
                        return result;
                    }
                    if (string.IsNullOrWhiteSpace(countryCode))
                    {
                        result.Errors.Add("Country can not be null or empty.");
                        return result;
                    }
                }
                
                if (columns.GroupBy(x => x.ColLabel.Trim(),StringComparer.OrdinalIgnoreCase).Any(g => g.Count() > 1))
                {
                    result.Errors.Add("Duplicate column found on " + args.Source);
                    return result;
                }

                var foundPlantnameColumn = false;
                var foundGIDColumn = false;
                var foundEntryCodeColumn = false;
                for (int i = 0; i < columns.Count; i++)
                {
                    var col = columns[i];
                    var dr = dtColumnsTVP.NewRow();
                    if (col.ColLabel.EqualsIgnoreCase("plant name"))
                    {
                        foundPlantnameColumn = true;
                    }
                    if (col.ColLabel.EqualsIgnoreCase("GID"))
                    {
                        foundGIDColumn = true;
                    }
                    if (col.ColLabel.EqualsIgnoreCase("Entry Code"))
                    {
                        foundEntryCodeColumn = true;
                    }
                    dr["ColumnNr"] = i;
                    dr["TraitID"] = col.TraitID;
                    dr["ColumnLabel"] = col.ColLabel;
                    dr["DataType"] = col.DataType;
                    dtColumnsTVP.Rows.Add(dr);
                }

                if (!foundPlantnameColumn)
                {
                    result.Errors.Add("Plant name column not found. Please add Plant name column on data grid.");
                    return result;
                }
                if (!foundGIDColumn)
                {
                    result.Errors.Add("GID column not found. Please add GID column on data grid.");
                    return result;
                }
                if (!foundEntryCodeColumn)
                {
                    result.Errors.Add("Entry code column not found. Please add Entry code column on Plant data grid.");
                    return result;
                }

                //now fetch data from list level to get rowID of GID which is used when we want to send cumullation result back to phenome based on observation
                //record we get from LIMS to utm result table on plant level.
                var gridid = new Random().Next(10000000, 99999999).ToText();
                var listResponse = await client.PostAsync("/api/v1/simplegrid/grid/create/FieldNursery", values =>
                 {
                     values.Add("object_type", args.ObjectType);
                     values.Add("object_id", args.ObjectID);
                     values.Add("grid_id", gridid);
                 });
                await listResponse.EnsureSuccessStatusCodeAsync();

                var listJson = await listResponse.Content.DeserializeAsync<PhenomeColumnsResponse>();
                if(!listJson.Success)
                {
                    throw new UnauthorizedAccessException(listJson.Message);
                }
                if (!listJson.Columns.Any())
                {
                    result.Errors.Add("No columns found on list level to import List information.");
                    return result;
                }

                var listResponse2 = await client.GetAsync("/api/v1/simplegrid/grid/get_json/FieldNursery?" +
                                                      $"object_type={args.ObjectType}&" +
                                                      $"object_id={args.ObjectID}&" +
                                                      $"grid_id={gridid}&" +
                                                      "add_header=1&" +
                                                      "rows_per_page=99999");
                await listResponse2.EnsureSuccessStatusCodeAsync();
                var listJson2 = await listResponse2.Content.DeserializeAsync<PhenomeDataResponse>();
                var totalList = listJson2.Properties.Max(x => x.Total_count);
                if (totalList <= 0)
                {
                    result.Errors.Add("No list data available.");
                    return result;
                }


                var columnsList1 = listJson.Columns.Select(x => new
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

                var columnsList2 = listJson2.Columns.Select((x, i) => new
                {
                    ID = x.Properties[0].ID,
                    Index = i

                }).GroupBy(g => g.ID).Select(x => new
                {
                    ID = x.Key,
                    Index = x.FirstOrDefault().Index
                });


                var columnsList = (from t1 in columnsList1
                                   join t2 in columnsList2 on t1.ID equals t2.ID
                                   select new
                                   {
                                       t2.ID,
                                       t2.Index,
                                       ColName = t1.ColumnName,
                                       t1.DataType,
                                       t1.ColLabel,
                                       t1.TraitID
                                   }).ToList();

                var getlistColIndex = new Func<string, int>(name =>
                {
                    var fldName = columnsList.FirstOrDefault(o => o.ColLabel.EqualsIgnoreCase(name));
                    if (fldName != null)
                        return fldName.Index;
                    return -1;
                });

                int gidIndex = getlistColIndex("GID");
                int entryCodeIndex = getlistColIndex("Entry Code");
                if(gidIndex==-1)
                {
                    result.Errors.Add("GID column not found on " + args.Source + ". Please add GID column on list data grid.");
                    return result;
                }
                if(entryCodeIndex == -1)
                {
                    result.Errors.Add("Entry code column not found on " + args.Source + ". Please add Entry code column on list data grid.");
                    return result;
                }

                for (int i=0; i<listJson2.Rows.Count; i++)
                {
                    var dr = listJson2.Rows[i];
                    //create row for listTVP
                    var drList = dtListTVP.NewRow();
                    drList["RowID"] = dr.Properties[0].ID;
                    //GID column will always comes with index 4 and entry code with always 5
                    drList["GID"] = dr.Cells[gidIndex].Value;
                    drList["EntryCode"] = dr.Cells[entryCodeIndex].Value;
                    dtListTVP.Rows.Add(drList);
                }

                for (int i = 0; i < json2.Rows.Count; i++)
                {
                    var dr = json2.Rows[i];
                    var drRow = dtRowTVP.NewRow();
                    drRow["RowNr"] = i;

                    drRow["MaterialKey"] = dr.Properties[0].ID;

                    //foreach (var col in columns)
                    for (int j = 0; j < columns.Count; j++)
                    {
                        var col = columns[j];
                        var drCell = dtCellTVP.NewRow();
                        var cellval = dr.Cells[col.Index].Value;

                        if (col.ColLabel.EqualsIgnoreCase("plant name") && string.IsNullOrWhiteSpace(cellval))
                        {
                            result.Errors.Add("Plant name value can not be empty.");
                            return result;
                        }
                        
                        if (col.ColLabel.EqualsIgnoreCase("GID"))
                        {
                            if (string.IsNullOrWhiteSpace(cellval))
                            {
                                result.Errors.Add("GID value can not be empty for plants.");
                                return result;
                            }
                            else
                            {
                                drRow["GID"] = cellval;
                            }
                        }
                        if (col.ColLabel.EqualsIgnoreCase("Entry code"))
                        {
                            drRow["Entrycode"] = cellval;
                        }

                        drCell["RowID"] = i;
                        drCell["ColumnID"] = j;
                        drCell["Value"] = cellval;
                        dtCellTVP.Rows.Add(drCell);
                    }
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

                result.CropCode = cropCode;
                result.BrStationCode = breedingStation;
                result.SyncCode = syncCode;
                result.CountryCode = countryCode;
                result.TVPColumns = dtColumnsTVP;
                result.TVPRows = dtRowTVP;
                result.TVPCells = dtCellTVP;
                result.TVPList = dtListTVP;
                return result;
            }
        }

        public async Task<PhenoneImportDataResult> GetListDataFromPhenomeAsync(HttpRequestMessage request, PhenomeImportRequestArgs args)
        {
            var result = new PhenoneImportDataResult();

            string cropCode = "";
            string breedingStation = "";
            string syncCode = "";
            string countryCode = "";


            #region prepare datatables for stored procedure call
            var dtCellTVP = new DataTable();
            dtCellTVP.Columns.Add("RowID", typeof(int));
            dtCellTVP.Columns.Add("ColumnID", typeof(int));
            dtCellTVP.Columns.Add("Value");

            var dtRowTVP = new DataTable();
            dtRowTVP.Columns.Add("RowNr");
            dtRowTVP.Columns.Add("MaterialKey");
            dtRowTVP.Columns.Add("GID");
            dtRowTVP.Columns.Add("EntryCode");

            var dtListTVP = new DataTable();
            dtListTVP.Columns.Add("RowID");
            dtListTVP.Columns.Add("GID");
            dtListTVP.Columns.Add("EntryCode");

            var dtColumnsTVP = new DataTable("TVP_Column");
            dtColumnsTVP.Columns.Add("ColumnNr", typeof(int));
            dtColumnsTVP.Columns.Add("TraitID");
            dtColumnsTVP.Columns.Add("ColumnLabel");
            dtColumnsTVP.Columns.Add("DataType");
            #endregion

            using (var client = new RestClient(BASE_SVC_URL))
            {

                client.SetRequestCookies(request);

                var response = await client.PostAsync("api/v1/simplegrid/grid/create/FieldNursery", values =>
                {
                    values.Add("object_type", args.ObjectType);
                    values.Add("object_id", args.ObjectID);
                    values.Add("grid_id", args.GridID);
                });
                await response.EnsureSuccessStatusCodeAsync();

                var json1 = await response.Content.DeserializeAsync<PhenomeColumnsResponse>();
                //var stringd = await response.Content.ReadAsStringAsync();
                if (!json1.Success)
                {
                    throw new UnAuthorizedException(json1.Message);
                }

                if (!json1.Columns.Any())
                {
                    result.Errors.Add("No columns found.");
                    return result;
                }
                if(!args.ForcedImport && json1.Columns.Count > 50)
                {
                    result.Warnings.Add("You are importing more than 50 columns.This can lead to problem. We recommend to reduce the amount of columns in Phenome. Continue?");
                    return result;
                }

                var response2 = await client.GetAsync("/api/v1/simplegrid/grid/get_json/FieldNursery?" +
                                                      $"object_type={args.ObjectType}&" +
                                                      $"object_id={args.ObjectID}&" +
                                                      $"grid_id={args.GridID}&" +
                                                      "add_header=1&" +
                                                      //$"rows_per_page=99999&" +
                                                      "posStart=0&" +
                                                      "count=99999");

                await response2.EnsureSuccessStatusCodeAsync();

                var json2 = await response2.Content.DeserializeAsync<PhenomeDataResponse>();
                //var stringvar = await response2.Content.ReadAsStringAsync();
                var totalRecords = json2.Properties.Max(x => x.Total_count);
                //var maxNoOfRecords = ConfigurationManager.AppSettings["App:MaxNoOfRecords"].ToInt32();
                //if (totalRecords > maxNoOfRecords)
                //{
                //    result.Errors.Add($"Cannot import data having rows greater than {maxNoOfRecords}.");
                //    return result;
                //}
                //if (!json2.Success)
                //{
                //    throw new UnAuthorizedException(json2.Message);
                //}
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

                //call service to get crop code based on cropid
                //https://onprem.unity.phenome-networks.com/api/v1/field/info/
                var rgDetail = await client.GetAsync($"/api/v1/researchgroup/info/{ args.CropID}");
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
                    var cropDetail = values.ToDictionary(k => k.Name, v => v.Value, StringComparer.OrdinalIgnoreCase);
                    if (!cropDetail.TryGetValue("Crop", out cropCode))
                    {
                        result.Errors.Add("Crop code not found. Please add crop code first.");
                        return result;
                    }
                    if (string.IsNullOrWhiteSpace(cropCode))
                    {
                        result.Errors.Add("Crop code can not be null or empty.");
                        return result;
                    }
                }

                //call service to get Breeding station based on breeding station level call on phenome.
                var folderDetail = await client.GetAsync($"/api/v1/folder/info/{ args.FolderID}");
                await folderDetail.EnsureSuccessStatusCodeAsync();

                //var test = await folderDetail.Content.ReadAsStringAsync();

                var folderInfo = await folderDetail.Content.DeserializeAsync<PhenomeFolderInfo>();
                if (folderInfo != null)
                {
                    if (folderInfo.Status != "1")
                    {
                        throw new UnAuthorizedException(researchGroup.Message);
                    }
                    var values = (from t1 in folderInfo.Info.RG_Variables
                                  join t2 in folderInfo.Info.BO_Variables on t1.VID equals t2.VID
                                  select new
                                  {
                                      t1.Name,
                                      t2.Value
                                  }).ToList();
                    var foldervalues = values.ToDictionary(k => k.Name, v => v.Value, StringComparer.OrdinalIgnoreCase);
                    if (!foldervalues.TryGetValue("Breeding Station", out breedingStation) && !foldervalues.TryGetValue("BreedStat", out breedingStation))
                    {
                        result.Errors.Add("Breeding station not found on " + args.Source + ". Please add Breeding station code first.");
                        return result;
                    }

                    if (string.IsNullOrWhiteSpace(breedingStation))
                    {
                        result.Errors.Add("Breeding station can not be null or empty.");
                        return result;
                    }
                    //syncCode
                    if (!foldervalues.TryGetValue("SyncCode", out syncCode))
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
                    if (!foldervalues.TryGetValue("Country", out countryCode))
                    {
                        result.Errors.Add("Country not found. Please add Country first.");
                        return result;
                    }
                    if (string.IsNullOrWhiteSpace(countryCode))
                    {
                        result.Errors.Add("Country can not be null or empty.");
                        return result;
                    }
                }

                if (columns.GroupBy(x => x.ColLabel.Trim(), StringComparer.OrdinalIgnoreCase).Any(g => g.Count() > 1))
                {
                    result.Errors.Add("Duplicate column found on " + args.Source);
                    return result;
                }

                var foundGIDColumn = false;
                for (int i = 0; i < columns.Count; i++)
                {
                    var col = columns[i];
                    var dr = dtColumnsTVP.NewRow();
                    if (col.ColLabel.EqualsIgnoreCase("GID"))
                    {
                        foundGIDColumn = true;
                    }
                    dr["ColumnNr"] = i;
                    dr["TraitID"] = col.TraitID;
                    dr["ColumnLabel"] = col.ColLabel;
                    dr["DataType"] = col.DataType;
                    dtColumnsTVP.Rows.Add(dr);
                }

                if (!foundGIDColumn)
                {
                    result.Errors.Add("GID column not found on " + args.Source + ". Please add GID column on data grid.");
                    return result;
                }
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
                    drList["EntryCode"] = dr.Cells[getColIndex("Entry Code")].Value;
                    dtListTVP.Rows.Add(drList);

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
                                result.Errors.Add("GID value can not be empty for list.");
                                return result;
                            }
                            else
                            {
                                drRow["GID"] = cellval;
                            }
                        }
                        if (col.ColLabel.EqualsIgnoreCase("Entry code"))
                        {
                            drRow["Entrycode"] = cellval;
                        }

                        drCell["RowID"] = i;
                        drCell["ColumnID"] = j;
                        drCell["Value"] = cellval;
                        dtCellTVP.Rows.Add(drCell);
                    }
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

                result.CropCode = cropCode;
                result.BrStationCode = breedingStation;
                result.SyncCode = syncCode;
                result.CountryCode = countryCode;
                result.TVPColumns = dtColumnsTVP;
                result.TVPRows = dtRowTVP;
                result.TVPCells = dtCellTVP;
                result.TVPList = dtListTVP;
                return result;
            }
        }
    }
}
