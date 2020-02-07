using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.DataAccess.Data.Interfaces;
using System.Configuration;
using System.Net;
using Enza.UTM.Common;
using Enza.UTM.Entities.Args;
using Enza.UTM.Services.Proxies;
using System.Data;
using System.Net.Http;
using System.Linq;
using Enza.UTM.Entities.Results;
using Enza.UTM.Common.Extensions;
using System;
using Enza.UTM.Common.Exceptions;
using Enza.UTM.Services.Abstract;

namespace Enza.UTM.BusinessAccess.Services
{
    public class ThreeGBService : IThreeGBService
    {
        private readonly string BASE_SVC_URL = ConfigurationManager.AppSettings["3GBServiceUrl"];
        private readonly string PHENOME_BASE_SVC_URL = ConfigurationManager.AppSettings["BasePhenomeServiceUrl"];
        private readonly IThreeGBRepository _threeGBRepository;
        private readonly IExcelDataRepository _excelDataRepository;
        public ThreeGBService(IThreeGBRepository threeGBRepository, IExcelDataRepository excelDataRepository)
        {
            _threeGBRepository = threeGBRepository;
            _excelDataRepository = excelDataRepository;
        }

        public async Task<IEnumerable<ThreeGBSlotData>> GetAvailableProjectsAsync(AvailableThreeGBProjectsRequestArgs requestArgs)
        {
            var (UserName, Password) = Credentials.GetCredentials();
            using (var svc = new ThreeGBSoapClient
            {
                Url = BASE_SVC_URL,
                Credentials = new NetworkCredential(UserName, Password)
            })
            {
                svc.Model = new
                {
                    requestArgs.CropCode,
                    requestArgs.BrStationCode,
                    ThreeGBType = requestArgs.TestTypeCode
                };
                var response =  await svc.GetAvailable3GBProjectAsync();
                //apply data filter if required.
                return response;
            }
        }

        public async Task<PhenoneImportDataResult> GetDataFromPhenomeAsync(HttpRequestMessage request, ThreeGBImportRequestArgs args)
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

            var dtColumnsTVP = new DataTable("TVP_Column");
            dtColumnsTVP.Columns.Add("ColumnNr", typeof(int));
            dtColumnsTVP.Columns.Add("TraitID");
            dtColumnsTVP.Columns.Add("ColumnLabel");
            dtColumnsTVP.Columns.Add("DataType");
            #endregion

            using (var client = new RestClient(PHENOME_BASE_SVC_URL))
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
                if (!args.ForcedImport && json1.Columns.Count > 50)
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
                }).GroupBy(g => g.ColName)
                .Select(y =>
                {
                    var elem = y.FirstOrDefault();
                    var item = new
                    {
                        ColumnName = y.Key,
                        ID = elem.ID,
                        DataType = elem.DataType,
                        ColLabel = elem.ColLabel,
                        TraitID = elem.TraitID
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
                        result.Errors.Add("Crop code not found on " + args.Source + ". Please add crop code first.");
                        return result;
                    }
                    if (string.IsNullOrWhiteSpace(cropCode))
                    {
                        result.Errors.Add("CropCode can not be null or empty.");
                        return result;
                    }
                }

                //call service to get Breeding station based on breeding station level call on phenome.
                var folderDetail = await client.GetAsync($"/api/v1/folder/info/{ args.FolderID}");
                await folderDetail.EnsureSuccessStatusCodeAsync();

                //validate crop code matches with phenome crop code
                
                //if (!args.CropCode.EqualsIgnoreCase(cropCode) && !args.BrStationCode.EqualsIgnoreCase(result.BrStationCode))
                //{
                //    result.Errors.Add("Crop code and breeding station in phenome and 3GB don't match with each other.");
                //    return result;
                //}

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

                    //if (!foldervalues.TryGetValue("Breeding Station", out breedingStation))
                    //{
                    //    result.Errors.Add("Breeding station not found on " + args.Source + ". Please add Breeding station code first.");
                    //    return result;
                    //}

                    if (string.IsNullOrWhiteSpace(breedingStation))
                    {
                        result.Errors.Add("Breeding station can not be null or empty.");
                        return result;
                    }
                    //syncCode
                    if (!foldervalues.TryGetValue("SyncCode", out syncCode))
                    {
                        result.Errors.Add("SyncCode not found on " + args.Source + ". Please add SyncCode first.");
                        return result;
                    }
                    if (string.IsNullOrWhiteSpace(syncCode))
                    {
                        result.Errors.Add("SyncCode can not be null or empty.");
                        return result;
                    }

                    //get country code if available
                    foldervalues.TryGetValue("Country", out countryCode);
                    result.CountryCode = countryCode;
                }

                //if (!args.CropCode.EqualsIgnoreCase(cropCode) && !args.BrStationCode.EqualsIgnoreCase(breedingStation))
                //{
                //    result.Errors.Add("Crop code and breeding station in phenome and 3GB don't match with each other.");
                //    return result;
                //}
                if (!args.CropCode.EqualsIgnoreCase(cropCode))
                {
                    result.Errors.Add("Crop code in phenome and 3GB don't match with each other.");
                    return result;
                }

                if (columns.GroupBy(x => x.ColLabel).Any(g => g.Count() > 1))
                {
                    result.Errors.Add("Duplicate column found on " + args.Source);
                    return result;
                }

                var foundPlantnameColumn = false;
                for (int i = 0; i < columns.Count; i++)
                {
                    var col = columns[i];
                    var dr = dtColumnsTVP.NewRow();
                    if (col.ColLabel.EqualsIgnoreCase("plant name"))
                    {
                        foundPlantnameColumn = true;
                    }
                    dr["ColumnNr"] = i;
                    dr["TraitID"] = col.TraitID;
                    dr["ColumnLabel"] = col.ColLabel;
                    dr["DataType"] = col.DataType;
                    dtColumnsTVP.Rows.Add(dr);
                }
                if (!foundPlantnameColumn)
                {
                    result.Errors.Add("Plant name column not found on " + args.Source + ". Please add Plant name column on data grid.");
                    return result;
                }
                //validate if gen column exists only for TestType GMAS
                if (!columns.Any(o => o.ColLabel.EqualsIgnoreCase("gen")) && args.TestTypeID == 5)
                {
                    result.Errors.Add("Column 'Gen' not found on " + args.Source + ". Please add 'Gen' column on data grid.");
                    return result;
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
                        //check if gen column contains any value. It is mandatory field for GMAS
                        if (col.ColLabel.EqualsIgnoreCase("gen") && string.IsNullOrWhiteSpace(cellval) && args.TestTypeID == 5)
                        {
                            result.Errors.Add("Generation can not be empty.");
                            return result;
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
                return result;
            }
        }

        public async Task<ExcelDataResult> ImportDataAsync(HttpRequestMessage request, ThreeGBImportRequestArgs requestArgs)
        {
            var result = await GetDataFromPhenomeAsync(request, requestArgs);
            if (result.Errors.Any() || result.Warnings.Any())
            {
                return new ExcelDataResult
                {
                    Success = false,
                    Warnings = result.Warnings,
                    Errors = result.Errors
                };
            }

            requestArgs.SyncCode = result.SyncCode;
            requestArgs.CropCode = result.CropCode;
            requestArgs.BrStationCode = result.BrStationCode;
            requestArgs.CountryCode = result.CountryCode;
            //import data into database
            await _threeGBRepository.ImportDataAsync(requestArgs, result.TVPColumns, result.TVPRows, result.TVPCells);
            return await _excelDataRepository.GetDataAsync(requestArgs);
        }

        public async Task Upload3GBMaterialsAsync(int testID)
        {
            var materials = await _threeGBRepository.Get3GBMaterialsAsync(testID);

            if (!materials.Any())
            {
                throw new BusinessException("No materials added to this Slot. Please add materials to upload.");
            }

            var model = materials.GroupBy(g => g.PlantID)
                .Select(o =>
                {
                    var item = o.FirstOrDefault(); 
                    return new
                    {
                        item.BreEZysAdministrationCode,
                        item.ThreeGBTaskID,
                        item.PlantNumber,
                        item.BreedingProject,
                        item.PlantID,
                        item.Generation,
                        item.TwoGBPlatePlanID,
                        item.TwoGBPlateNumber,
                        item.TwoGBRow,
                        item.TwoGBColumn,
                        item.TwoGBWeek,
                        TwoGBResults = o.Where(x => x.TwoGBPlatePlanID != null)
                        .GroupBy(g => g.MarkerName)
                        .Select(x => new
                        {
                            MarkerName = x.Key,
                            x.LastOrDefault()?.Result
                        }).ToList(),
                        Purpose = "", /* TBD*/
                        Remark = ""   /* TBD*/
                    };
                }).ToList();


            var (UserName, Password) = Credentials.GetCredentials();
            using (var svc = new ThreeGBSoapClient
            {
                Url = BASE_SVC_URL,
                Credentials = new NetworkCredential(UserName, Password)
            })
            {
                svc.Model = new
                {
                    PlantLists = model
                };
                var response = await svc.Upload3GBMaterialsAsync();
                //update database with ThreeGBPlantID
                await _threeGBRepository.Update3GBMaterialsAsync(testID, response);           
            }
        }
    }
}
