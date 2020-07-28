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
    public class S2SRepository : Repository<object>, IS2SRepository
    {
        private readonly IUserContext userContext;
        private readonly string BASE_SVC_URL = ConfigurationManager.AppSettings["BasePhenomeServiceUrl"];
        public S2SRepository(IDatabase dbContext, IUserContext userContext) : base(dbContext)
        {
            this.userContext = userContext;
        }

        public async Task<IEnumerable<S2SCapacitySlotResult>> GetS2SCapacityAsync(S2SCapacitySlotArgs args)
        {
            var (UserName, Password) = Credentials.GetCredentials();
            using (var svc = new S2SSoapClient
            {
                Url = ConfigurationManager.AppSettings["S2SCapacitySlotUrl"],
                //Credentials = new NetworkCredential("prakash_as", "20prak!!@@19")
                Credentials = new NetworkCredential(UserName, Password)
            })
            {
                svc.Model = new
                {
                    args.BreEzysAdministration,
                    args.CapacitySlotID,
                    args.Crop,
                    args.Source,
                    args.Year
                };
                var response = await svc.GetS2SCapacityAsync();
                return response;
            }

        }

        public async Task<DataSet> GetDataAsync(S2SGetDataRequestArgs requestArgs)
        {
            var p1 = DbContext.CreateOutputParameter("@TotalRows", DbType.Int32);
            var ds = await DbContext.ExecuteDataSetAsync(DataConstants.PR_S2S_GET_DATA,
                CommandType.StoredProcedure, args =>
                {
                    args.Add("@TestID", requestArgs.TestID);
                    args.Add("@Page", requestArgs.PageNumber);
                    args.Add("@PageSize", requestArgs.PageSize);
                    args.Add("@Filters", requestArgs.Filters.ToJson());
                    args.Add("@TotalRows", p1);
                });
            requestArgs.TotalRows = p1.Value.ToInt32();
            ds.Tables[0].TableName = "Rows";
            ds.Tables[1].TableName = "Columns";
            return ds;
        }
        public async Task<PhenoneImportDataResult> ImportDataFromPhenomeAsync(HttpRequestMessage request, S2SRequestArgs args)
        {
            var result = new PhenoneImportDataResult();

            string cropCode = "";
            string breedingStation = "";
            string syncCode = "";
            string countryCode = "";
            var excludeColumnsList = new List<string>
            {               
                "Selected",
                "ProjectCode",
                "DH0Net",
                "Requested",
                "Transplant",
                "ToBeSown"
            };

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
                               }).Where(x=> !excludeColumnsList.Contains(x.ColLabel, StringComparer.OrdinalIgnoreCase)).ToList();

                if (columns.GroupBy(x => x.ColLabel.Trim(), StringComparer.OrdinalIgnoreCase).Any(g => g.Count() > 1))
                {
                    result.Errors.Add("Duplicate column found on " + args.Source);
                    return result;
                }

                var foundGIDColumn = false;
                var foundNameColumn = false;
                var foundMasterNr = false;
                for (int i = 0; i < columns.Count; i++)
                {
                    var col = columns[i];
                    var dr = dtColumnsTVP.NewRow();
                    if (col.ColLabel.EqualsIgnoreCase("GID"))
                    {
                        foundGIDColumn = true;
                    }
                    else if (col.ColLabel.EqualsIgnoreCase("name"))
                    {
                        foundNameColumn = true;
                    }
                    else if (col.ColLabel.EqualsIgnoreCase("masternr"))
                    {
                        foundMasterNr = true;
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
                if (!foundNameColumn)
                {
                    result.Errors.Add("Name column not found. Please add Name column on data grid.");
                    return result;
                }
                if (!foundMasterNr)
                {
                    result.Errors.Add("MasterNr column not found. Please add MasterNr column on data grid.");
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
                    drList["Name"] = getColIndex("Name") > 0 ? dr.Cells[getColIndex("Name")].Value : "";


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
                        else if (col.ColLabel.EqualsIgnoreCase("MasterNr"))
                        {
                            if (string.IsNullOrWhiteSpace(cellval))
                            {
                                result.Errors.Add("MasterNr value can not be empty.");
                                return result;
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


                var dr1 = TVPS2SCapacity.NewRow();
                dr1["CapacitySlotID"] = args.CapacitySlotID;
                dr1["CapacitySlotName"] = args.CapacitySlotName;
                dr1["MaxPlants"] = args.MaxPlants;
                dr1["CordysStatus"] = args.CordysStatus;
                dr1["DH0Location"] = args.DH0Location;
                dr1["AvailPlants"] = args.AvailPlants;
                TVPS2SCapacity.Rows.Add(dr1);

                //TestName and FilePath is same for Phenome
                args.FilePath = args.TestName;
                //import data into database
                await ImportDataAsync(result.CropCode, result.BrStationCode, result.SyncCode, result.CountryCode,
                    args, result.TVPColumns, result.TVPRows, result.TVPCells, result.TVPList, TVPS2SCapacity);

                return result;
            }
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

        private void PrepareTVPS(DataTable dtCellTVP, DataTable dtRowTVP, DataTable dtListTVP, DataTable dtColumnsTVP, DataTable TVPS2SCapacity)
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

            TVPS2SCapacity.Columns.Add("CapacitySlotID", typeof(int));
            TVPS2SCapacity.Columns.Add("CapacitySlotName", typeof(string));
            TVPS2SCapacity.Columns.Add("MaxPlants", typeof(int));
            TVPS2SCapacity.Columns.Add("CordysStatus", typeof(string));
            TVPS2SCapacity.Columns.Add("DH0Location", typeof(string));
            TVPS2SCapacity.Columns.Add("AvailPlants", typeof(int));
        }

        private async Task ImportDataAsync(string cropCode, string brStationCode, string syncCode, string countryCode, S2SRequestArgs requestArgs, DataTable tVPColumns, DataTable tVPRows, DataTable tVPCells, DataTable tVPList, DataTable TVPS2SCapacity)
        {
            var p1 = DbContext.CreateOutputParameter("@TestID", DbType.Int32);
            DbContext.CommandTimeout = 5 * 60; //5 minutes
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_IMPORT_S2S_MATERIAL,
                CommandType.StoredProcedure, args =>
                {
                    args.Add("@CropCode", cropCode);
                    args.Add("@BreedingStationCode", brStationCode);
                    args.Add("@SyncCode", syncCode);
                    args.Add("@CountryCode", countryCode);
                    args.Add("@TestTypeID", requestArgs.TestTypeID);
                    args.Add("@UserID", userContext.GetContext().FullName);
                    args.Add("@FileTitle", requestArgs.FilePath);
                    args.Add("@TVPColumns", tVPColumns);
                    args.Add("@TVPRow", tVPRows);
                    args.Add("@TVPCell", tVPCells);
                    args.Add("@TestID", p1);
                    args.Add("@PlannedDate", requestArgs.PlannedDate);
                    args.Add("@MaterialStateID", requestArgs.MaterialStateID);
                    args.Add("@MaterialTypeID", requestArgs.MaterialTypeID);
                    args.Add("@ContainerTypeID", requestArgs.ContainerTypeID);
                    args.Add("@Isolated", requestArgs.Isolated);
                    args.Add("@Source", requestArgs.Source);
                    args.Add("@TestName", requestArgs.TestName);
                    args.Add("@ObjectID", requestArgs.ObjectID);
                    args.Add("@ExpectedDate", requestArgs.ExpectedDate);
                    args.Add("@Cumulate", requestArgs.Cumulate);
                    args.Add("@ImportLevel", requestArgs.ImportLevel);
                    args.Add("@TVPList", tVPList);
                    args.Add("@TVPCapacityS2s", TVPS2SCapacity);
                    args.Add("@FileID", requestArgs.FileID);
                });
            requestArgs.TestID = p1.Value.ToInt32();
        }

        public async Task<MaterialsWithMarkerResult> MarkerWithMaterialS2SAsync(MaterialsWithMarkerRequestArgs args)
        {
            var result = new MaterialsWithMarkerResult();
            DbContext.CommandTimeout = 2 * 60; //time out is set to 2 minutes
            var data = await DbContext.ExecuteDataSetAsync(DataConstants.PR_GET_MATERIAL_WITH_MARKER_FORS2S, CommandType.StoredProcedure, args1 =>
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

        public async Task<Test> AssignDeterminationsAsync(AssignDeterminationForS2SRequestArgs request)
        {
            var data = await DbContext.ExecuteReaderAsync(DataConstants.PR_SAVE_TEST_MATERIAL_DETERMINATION_FORS2S, CommandType.StoredProcedure, args =>
            {
                args.Add("@TestTypeID", request.TestTypeID);
                args.Add("@TestID", request.TestID);
                args.Add("@Columns", request.ToColumnsString());
                args.Add("@Filter", request.ToFilterString());
                args.Add("@TVPM", request.ToTVPTestMaterialDetermation());
                args.Add("@Determinations", request.ToTVPDeterminations());
                args.Add("@TVP_DonerInfo", request.ToTVPDonerInfo());
            },
            reader => new Test
            {
                TestID = reader.Get<int>(0),
                StatusCode = reader.Get<int>(1)

            });
            return data.FirstOrDefault();
        }
        public async Task<S2SFillRateDetail> GetFillRateDetailsAsync(int testID)
        {
            var items = await DbContext.ExecuteReaderAsync(DataConstants.PR_S2S_GET_FILL_RATE_DETAILS,
                CommandType.StoredProcedure, args => args.Add("@TestID", testID), reader => new S2SFillRateDetail
                {
                    DH0Location = reader.Get<string>(0),
                    MaxPlants = reader.Get<int>(1),
                    AvailPlants = reader.Get<int>(2),
                    CordysStatus = reader.Get<string>(3),
                    CapacitySlotName = reader.Get<string>(4),
                    FilledPlants = reader.Get<int>(5)
                });
            return items.FirstOrDefault();
        }

        public async Task UploadS2SDonorAsync(int testID)
        {
            //prepare data to upload
            var data = await DbContext.ExecuteReaderAsync(DataConstants.PR_S2S_GET_DONOR_INFO_FOR_UPLOAD,
                CommandType.StoredProcedure, args => args.Add("@TestID", testID), reader => new S2SCreateSowingListData
                {
                    CropCode = reader.Get<string>(0),
                    CapacitySlotID = reader.Get<int>(1),
                    CapacitySlotName = reader.Get<string>(2),
                    MasterNumber = reader.Get<string>(3),
                    BreezysPKReference = reader.Get<string>(4),
                    BreezysID = reader.Get<int>(5),
                    BreezysRefCode = reader.Get<int>(6),
                    BreedingStation = reader.Get<string>(7),
                    Project = reader.Get<string>(8),
                    DonorNumber = reader.Get<string>(9),
                    PlantNumber = reader.Get<string>(10),
                    LotNumber = reader.Get<int>(11),
                    CrossingYear = 0,
                    NrOfSeeds = reader.Get<int>(12),
                    NrOfPlannedTransplanted = reader.Get<int>(13),
                    NrOfPlannedDHEmbryoRescueNett = reader.Get<int>(14),
                    NrOfPlannedDHEmbryoRescueGross = reader.Get<int>(15),
                    DH0MakerTestNeeded = reader.Get<bool>(16),
                    BreEzysAdminstration = "PH"
                });

            if (!data.Any())
                throw new BusinessException("No donors selected for uploading to S2S.");

            var param = new S2SCapacitySlotArgs()
            {
                BreEzysAdministration = "PH",
                CapacitySlotID = data.FirstOrDefault().CapacitySlotID,
                Crop = data.FirstOrDefault().CropCode
            };

            //validate sowinglist with the server
            //get capacityslot data
            var getS2SCapacity = await GetS2SCapacityAsync(param);
            if (!getS2SCapacity.Any())
            {
                throw new BusinessException("Could not fetch capacity slot information from Cordys.");
            }
            var s2sCapacity = getS2SCapacity.FirstOrDefault();
            //check if project code is filled or not
            if (data.Any(x => string.IsNullOrWhiteSpace(x.Project)))
            {
                throw new BusinessException("Project Code can not be blank or empty.");
            }

            //check if project code is filled or not
            if (data.Any(x => string.IsNullOrWhiteSpace(x.MasterNumber)))
            {
                throw new BusinessException("MasterNr can not be blank or empty.");
            }

            //update to database
            var TVPS2SCapacity = new DataTable();
            TVPS2SCapacity.Columns.Add("CapacitySlotID", typeof(int));
            TVPS2SCapacity.Columns.Add("CapacitySlotName", typeof(string));
            TVPS2SCapacity.Columns.Add("MaxPlants", typeof(int));
            TVPS2SCapacity.Columns.Add("CordysStatus", typeof(string));
            TVPS2SCapacity.Columns.Add("DH0Location", typeof(string));
            TVPS2SCapacity.Columns.Add("AvailPlants", typeof(int));

            var dr1 = TVPS2SCapacity.NewRow();
            dr1["CapacitySlotID"] = s2sCapacity.CapacitySlotID;
            dr1["CapacitySlotName"] = s2sCapacity.SowingCode;
            dr1["MaxPlants"] = s2sCapacity.MaxPlants;
            dr1["CordysStatus"] = s2sCapacity.Status;
            dr1["DH0Location"] = s2sCapacity.DH0Location;
            dr1["AvailPlants"] = s2sCapacity.AvailableNrPlants;
            TVPS2SCapacity.Rows.Add(dr1);

            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_S2S_CREATE_CAPACITYSLOT, CommandType.StoredProcedure, args =>
            {
                args.Add("@TVPCapacityS2S", TVPS2SCapacity);
            });

            //if NrOfPlannedTransplanted is zero send warning message
            if (data.Any(x => x.NrOfPlannedTransplanted <= 0))
            {
                throw new BusinessException("Transplant value cannot be 0 for selected donor.");
            }
            var totalTransplanted = data.Sum(x => x.NrOfPlannedTransplanted);
            //if nr of avail capacity + material to upload is within range then upload else error
            if(s2sCapacity.AvailableNrPlants < totalTransplanted)
            {
                throw new BusinessException("Available capacity exceeded. Unselect some donor.");
            }
            //upload donors
            var donorResult = await UploadDonorlistAsync(data);
            if(donorResult.Any())
            {
                //update donornumber for all donors and update Test status 
                var TVPDonorInfo = new DataTable();
                TVPDonorInfo.Columns.Add("MaterialID", typeof(int));
                TVPDonorInfo.Columns.Add("DH0net");
                TVPDonorInfo.Columns.Add("Requested");
                TVPDonorInfo.Columns.Add("ToBeSown");
                TVPDonorInfo.Columns.Add("Transplant");
                TVPDonorInfo.Columns.Add("DonorNumber");
                TVPDonorInfo.Columns.Add("ProjectCode");
                foreach (var item in donorResult)
                {
                    var dr = TVPDonorInfo.NewRow();
                    dr["MaterialID"] = item.BreezysPKReference;
                    dr["DonorNumber"] = item.DonorNumber;
                    TVPDonorInfo.Rows.Add(dr);
                }
                var donor = await DbContext.ExecuteNonQueryAsync(DataConstants.PR_S2S_UPDATE_DONORNUMBER, CommandType.StoredProcedure, args => { args.Add("@TVP_DonerInfo", TVPDonorInfo); args.Add("@TestID", testID); });

                //again update s2s capcity slot property with changed available after success             
                dr1["AvailPlants"] = s2sCapacity.AvailableNrPlants - totalTransplanted < 0 ? 0 : s2sCapacity.AvailableNrPlants - totalTransplanted;
                await DbContext.ExecuteNonQueryAsync(DataConstants.PR_S2S_CREATE_CAPACITYSLOT, CommandType.StoredProcedure, args =>
                {
                    args.Add("@TVPCapacityS2S", TVPS2SCapacity);
                });
            }
        }

        public async Task<IEnumerable<S2SCreateSowingListResult>> UploadDonorlistAsync(IEnumerable<S2SCreateSowingListData> args)
        {
            var (UserName, Password) = Credentials.GetCredentials();
            using (var svc = new S2SSoapClient
            {
                Url = ConfigurationManager.AppSettings["S2SCapacitySlotUrl"],
                Credentials = new NetworkCredential(UserName, Password)
            })
            {
                svc.Model = new
                {
                    args.FirstOrDefault().CropCode,
                    args.FirstOrDefault().CapacitySlotID,
                    args.FirstOrDefault().CapacitySlotName,
                    Donors = args
                };
                var response = await svc.UploadDonorlistAsync();
                return response;
            }
        }

        public Task CreateDH0Async()
        {
            return null;
        }

        public async Task<IEnumerable<CreateDHInfo>> GetDataToCreate(DHSyncConfig _config)
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_S2S_GET_DH_TO_CREATE, CommandType.StoredProcedure,
                args =>
                {
                    args.Add("@TestID", _config.TestID);

                }, reader => new CreateDHInfo
                {
                    Materialkey = reader.Get<string>(0),
                    DHProposedName = reader.Get<string>(1),
                    DonorName = reader.Get<string>(2),
                    RefExternal = reader.Get<string>(3),
                    FieldEntityType = reader.Get<string>(4),

                });
        }

        public async Task<IEnumerable<DHSyncConfig>> GetSyncConfigAsync(int statusCode = 100)
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_S2S_GET_DH_CONFIG_SETTING,
                CommandType.StoredProcedure,
                args => args.Add("@StatusCode", statusCode),
                reader => new DHSyncConfig
                {
                    CropCode = reader.Get<string>(0),
                    DHFieldSetSetID = reader.Get<int>(1),
                    ResearchGroupID = reader.Get<int>(2),
                    TestID = reader.Get<int>(3)
                });
        }

        public async Task<IEnumerable<string>> GetDH0ToSyncGID(string cropCode)
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_S2S_GET_DH0_TO_SYNC_GID, CommandType.StoredProcedure, args =>
            {
                args.Add("@CropCode",cropCode);
            }, reader => reader.Get<string>(0));
        }

        public async Task SaveCreatedDHGID(string jsonString)
        {
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_S2S_SAVE_DH_GIDS, CommandType.StoredProcedure, args => args.Add("@Json", jsonString));
        }

        public async Task<IEnumerable<MissingConversionResult>> GetConversionMissingData(DHSyncConfig config)
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_S2S_GET_MISSING_CONVERSION, CommandType.StoredProcedure,
                args => args.Add("@TestID", config.TestID),
                reader =>
                  new MissingConversionResult
                  {
                      DeterminationName = reader.Get<string>(0),
                      Scorevalue = reader.Get<string>(1)
                  });
        }

        public async Task<IEnumerable<S2SGetProgramCodesByCropResult>> GetProjectsAsync(string crop)
        {
            var (UserName, Password) = Credentials.GetCredentials();
            using (var svc = new S2SSoapClient
            {
                Url = ConfigurationManager.AppSettings["S2SCapacitySlotUrl"],
                //Credentials = new NetworkCredential("prakash_as", "20prak!!@@19")
                Credentials = new NetworkCredential(UserName, Password)
            })
            {
                svc.Model = new
                {
                    crop
                };
                var response = await svc.GetProgramCodesByCropAsync();
                return response;
            }
        }

        public Task ManageMarkersAsync(S2SManageMarkersRequestArgs requestArgs)
        {
            var dataAsJson = requestArgs.Details.ToJson();
            return DbContext.ExecuteNonQueryAsync(DataConstants.PR_S2S_MANAGE_MARKERS,
                CommandType.StoredProcedure, args =>
                {
                    args.Add("@TestID", requestArgs.TestID);
                    args.Add("@DataAsJson", dataAsJson);
                });
        }

        public Task<IEnumerable<S2SDH1Info>> GetDH1DetailsAsync(int testID)
        {
            return DbContext.ExecuteReaderAsync(DataConstants.PR_S2S_GET_DH1_DETAILS,
                CommandType.StoredProcedure,
                args => args.Add("@TestID", testID),
                reader => new S2SDH1Info
                {
                    GID = reader.Get<int>(0),
                    PlantNr = reader.Get<string>(1),
                    MasterNr = reader.Get<string>(2),
                    ResearchGroupID = reader.Get<int>(3)
                });
        }

        public Task UpdateRelationDonorStatusAsync(string proposedName, int statusCode)
        {
            return DbContext.ExecuteNonQueryAsync(DataConstants.PR_S2S_UPDATE_RELATION_DONOR_STATUS,
                CommandType.StoredProcedure, args =>
            {
                //args.Add("@TestID", testID);
                args.Add("@ProposedName", proposedName);
                args.Add("@StatusCode", statusCode);
            });
        }
    }
    
}
