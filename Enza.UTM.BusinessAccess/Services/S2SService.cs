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
using Enza.UTM.Entities;
using System.Text;
using System.IO;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;
using System.Text.RegularExpressions;
using System.Xml.Linq;
using log4net;

namespace Enza.UTM.BusinessAccess.Services
{
    public class S2SService : IS2SService
    {
        private static readonly ILog _logger =
           LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        private readonly string BASE_SVC_URL = ConfigurationManager.AppSettings["3GBServiceUrl"];
        private readonly string PHENOME_BASE_SVC_URL = ConfigurationManager.AppSettings["BasePhenomeServiceUrl"];
        private readonly IS2SRepository s2SRepository;
        private readonly IExcelDataRepository excelDataRepository;
        private readonly IEmailService _emailService;
        private readonly IEmailConfigService _emailConfigService;

        public S2SService(IS2SRepository s2SRepository, IExcelDataRepository excelDataRepository, IEmailService emailService, IEmailConfigService emailConfigService)
        {
            this.s2SRepository = s2SRepository;
            this.excelDataRepository = excelDataRepository;
            _emailService = emailService;
            _emailConfigService = emailConfigService;
        }

        public async Task<Test> AssignDeterminationsAsync(AssignDeterminationForS2SRequestArgs args)
        {
            return await s2SRepository.AssignDeterminationsAsync(args);
        }

        public async Task<ExcelDataResult> GetDataAsync(ExcelDataRequestArgs requestArgs)
        {
            return await excelDataRepository.GetDataAsync(requestArgs);
        }

        public Task<S2SFillRateDetail> GetFillRateDetailsAsync(int testID)
        {
            return s2SRepository.GetFillRateDetailsAsync(testID);
        }

        public async Task<IEnumerable<S2SCapacitySlotResult>> GetS2SCapacityAsync(S2SCapacitySlotArgs args)
        {
            args.BreEzysAdministration = "PH";
            return await s2SRepository.GetS2SCapacityAsync(args);
        }

        public async Task<ExcelDataResult> ImportDataAsync(HttpRequestMessage request, S2SRequestArgs args)
        {
            var result = await s2SRepository.ImportDataFromPhenomeAsync(request, args);

            if (result.Errors.Any() || result.Warnings.Any())
            {
                return new ExcelDataResult
                {
                    Errors = result.Errors,
                    Warnings = result.Warnings
                };
            }
            return await GetDataAsync(args);
        }

        public async Task<MaterialsWithMarkerResult> MarkerWithMaterialS2SAsync(MaterialsWithMarkerRequestArgs args)
        {
            return await s2SRepository.MarkerWithMaterialS2SAsync(args);
        }

        public async Task UploadS2SDonorAsync(int testID)
        {
            await s2SRepository.UploadS2SDonorAsync(testID);
        }

        public async Task<List<ExecutableError>> CreateDHAsync()
        {
            //bool response = true;
            var response = new List<ExecutableError>();
            //get configuration to which crop and test we need to create DH germplasm
            LogInfo("Getting configuration settings.");
            var config = await s2SRepository.GetSyncConfigAsync();
            //create a new DH0 germplasm on phenome
            if(config.Any())
            {
                //create DHO
                response = await CreateDH0GermpmasmAsync(config);
            }
            return response;
        }
        private async Task<List<ExecutableError>> CreateDH0GermpmasmAsync(IEnumerable<DHSyncConfig> config)
        {
            var errorMessage = new List<ExecutableError>();
            using (var client = new RestClient(PHENOME_BASE_SVC_URL))
            {
                var resp = await SignInAsync(client);
                await resp.EnsureSuccessStatusCodeAsync();
                var loginresp = await resp.Content.DeserializeAsync<PhenomeResponse>();
                if (loginresp.Status != "1")
                {
                    LogError("Login failed. Invalid user name or password");                    
                    throw new Exception("Login failed. Invalid user name or password");
                }
                var dH0MethodID = string.Empty;
                var dH1MethodID = string.Empty;
                var masterNrColPerCrop = new Dictionary<int, string>();

                foreach (var _config in config)
                {
                    try
                    {
                        
                        LogInfo("Fetching Method to create DH0 and DH1 germplasm.");
                        var getMethodURL = $"/api/v2/germplasm/methods/get?rgId={_config.ResearchGroupID}&methodType=DER";
                        var setGridURL = "/api/v1/simplegrid/grid/create/FieldSelections";
                        //var setGridURL = "/api/v1/simplegrid/grid/create_rows/FieldSelections";
                        var fetchDataURL = "/api/v1/simplegrid/grid/get/FieldSelections";
                        var setOrderURL = "/api/v2/fieldentity/columns/set_order";
                        //var fieldSetCreateColumnsURL = "/api/v1/simplegrid/grid/create_columns/FieldSelections";
                        //var createRowsSelectionUsingFilterURL = "api/v1/simplegrid/grid/create_rows/FieldSelections";
                        var createSelectionURL = "/api/v2/fieldentity/selection/set";
                        var methodResp = await client.GetAsync(getMethodURL);
                        await methodResp.EnsureSuccessStatusCodeAsync();
                        var dHOMethodLevel = "Double Haploid";
                        var dH1MethodLevel = "Selfing";
                        var methodRespContent = JsonConvert.DeserializeObject<GetMethodResult>(await methodResp.Content.ReadAsStringAsync());
                        if(methodRespContent.Success)
                        {
                            dH0MethodID = methodRespContent.Combo.FirstOrDefault(x => x.Label.EqualsIgnoreCase(dHOMethodLevel))?.Value;
                            if(string.IsNullOrWhiteSpace(dH0MethodID))
                            {
                                LogError($"Unable to find method {dHOMethodLevel} for Crop {_config.CropCode} with research group ID {_config.ResearchGroupID}");
                                errorMessage.Add(new ExecutableError
                                {
                                    Success = false,
                                    CropCode = _config.CropCode,
                                    ErrorType = "data",
                                    ErrorMessage = $"Unable to find method {dHOMethodLevel} for Crop {_config.CropCode} with research group ID {_config.ResearchGroupID}"

                                });
                                continue;
                            }
                            dH1MethodID = methodRespContent.Combo.FirstOrDefault(x => x.Label.EqualsIgnoreCase(dH1MethodLevel))?.Value;
                            if (string.IsNullOrWhiteSpace(dH1MethodID))
                            {
                                LogError($"Unable to find method {dH1MethodLevel} for Crop {_config.CropCode} with research group ID {_config.ResearchGroupID}");
                                errorMessage.Add(new ExecutableError
                                {
                                    Success = false,
                                    CropCode = _config.CropCode,
                                    ErrorType = "data",
                                    ErrorMessage = $"Unable to find method {dH1MethodLevel} for Crop {_config.CropCode} with research group ID {_config.ResearchGroupID}"

                                });
                                continue;
                            }
                        }
                        else
                        {
                            LogError($"Unable to find any method for Crop {_config.CropCode} with research group ID {_config.ResearchGroupID}");
                            errorMessage.Add(new ExecutableError
                            {
                                Success = false,
                                CropCode = _config.CropCode,
                                ErrorType = "data",
                                ErrorMessage = $"Unable to find any method for Crop {_config.CropCode} with research group ID {_config.ResearchGroupID}"

                            });                           
                            continue;
                        }

                        if (!masterNrColPerCrop.ContainsKey(_config.ResearchGroupID))
                        {
                            LogInfo("Fetching Germplasm columns to get MasterNr column that must be defined for Crop.");
                            //get id of MasterNr germplasm column which is required to fetch masternr data of DH1
                            var getColumnURL = $"/api/v1/simplegrid/grid/get_columns_list/Germplasms";
                            var response = await client.PostAsync(getColumnURL, values =>
                            {
                                values.Add("object_type", "5");
                                values.Add("object_id", _config.ResearchGroupID.ToText());
                                values.Add("base_entity_id", _config.ResearchGroupID.ToText());
                            });
                            await response.EnsureSuccessStatusCodeAsync();
                            var colInfo = await response.Content.DeserializeAsync<GermplmasColumnsAll>();
                            if (!colInfo.Status.EqualsIgnoreCase("1"))
                            {
                                LogError($"Unable to find Germplasm columns for Crop {_config.CropCode} with research group ID {_config.ResearchGroupID}.");
                                errorMessage.Add(new ExecutableError
                                {
                                    Success = false,
                                    CropCode = _config.CropCode,
                                    ErrorType = "Exception",
                                    ErrorMessage = $"Unable to find Germplasm columns for Crop {_config.CropCode} with research group ID {_config.ResearchGroupID}."

                                });
                                throw new Exception($"Unable to find Germplasm columns for Crop {_config.CropCode} with research group ID {_config.ResearchGroupID}.");
                            }
                            var masterNrCol = colInfo.All_Columns.FirstOrDefault(x => x.desc.EqualsIgnoreCase("MasterNr") && x.id.ToLower().StartsWith("ger"));
                            if (masterNrCol == null)
                            {
                                LogError($"Unable to find MasterNr for Crop {_config.CropCode} with research group ID {_config.ResearchGroupID}.");
                                errorMessage.Add(new ExecutableError
                                {
                                    Success = false,
                                    CropCode = _config.CropCode,
                                    ErrorType = "data",
                                    ErrorMessage = $"Unable to find MasterNr for Crop {_config.CropCode} with research group ID {_config.ResearchGroupID}."

                                });
                                continue;
                                
                            }
                            else
                                masterNrColPerCrop.Add(_config.ResearchGroupID, masterNrCol.id);
                        }

                        //get data from db to be created on Phenome.
                        LogInfo($"Fetch data to create on phenome.");
                        var getDHToCreate = await s2SRepository.GetDataToCreate(_config);

                        //this group is needed to create DH0 and DH1 based on FieldSet (because user can import material from more then 1 Fieldset to single test on UTM).
                        var groupedData = getDHToCreate.GroupBy(g => g.RefExternal);
                        foreach (var _groupdeData in groupedData)
                        {
                            try
                            {
                                var keyvalues = new List<Tuple<string, string>>();

                                //var jobWithStatus = new List<CreateSelectionJobResp>();

                                //apply filter on FieldSet => Selection name column to check if data is created or not
                                //1. Get columns 
                                //1. Set required columns if not available on grid Fieldset=> selection
                                //2. set grid with filter value
                                //3. get data after applying filter
                                var gridID = new Random().Next(10000000, 99999999).ToText();
                                //1. get columns
                                LogInfo($"Get Columns from Phenome for field {_groupdeData.Key}");
                                var columnsResp = await PrepareFilterGrid(client, setGridURL, _groupdeData.Key, gridID, "{}", "28");

                                //2. if any of two columns is not found add it on grid  
                                LogInfo($"Set required Columns from Phenome for field {_groupdeData.Key}");
                                var requiredColumns = new List<string>();                                
                                requiredColumns.Add("gid");
                                requiredColumns.Add("name");
                                var addColumnsResp = await AddColumns(client, setOrderURL, keyvalues, requiredColumns, columnsResp, _groupdeData.Key, "6");
                                if (!addColumnsResp)
                                {
                                    LogError($"Unable to set column in selection grid on fieldID: {_config.DHFieldSetSetID.ToText()}");
                                    errorMessage.Add(new ExecutableError
                                    {
                                        Success = false,
                                        CropCode = _config.CropCode,
                                        ErrorType = "Exception",
                                        ErrorMessage = $"Unable to set column in selection grid on fieldID: {_config.DHFieldSetSetID.ToText()}"

                                    });
                                    continue;
                                }

                                //3. set grid with filter value
                                LogInfo($"Set Grid with filter value on field {_groupdeData.Key}");
                                var filtervalue = string.Join(",", _groupdeData.Select(x => x.DHProposedName).ToList());
                                var filterString = "{\"name\":\"" + filtervalue + "\"}";
                                var jsonresp = await PrepareFilterGrid(client, setGridURL, _groupdeData.Key, gridID, filterString,"28");
                                if (jsonresp.Status.ToText().EqualsIgnoreCase("1"))
                                {
                                    //check if selection name column exists on response or not
                                    var nameCol = jsonresp.Columns.FirstOrDefault(x => x.id.EqualsIgnoreCase("name"));
                                    if (nameCol == null)
                                    {
                                        LogError($"Selection name column not found on field { _groupdeData.Key.ToText()}");
                                        errorMessage.Add(new ExecutableError
                                        {
                                            Success = false,
                                            CropCode = _config.CropCode,
                                            ErrorType = "Exception",
                                            ErrorMessage = $"Selection name column not found on field { _groupdeData.Key.ToText()}"

                                        });
                                        continue;
                                    }
                                    //4. fetch data
                                    List<CreatedDH> createdDH0Data = new List<CreatedDH>();
                                    List<CreatedDH> createdDH1NurseryList = new List<CreatedDH>();
                                    List<CreatedDH> createdDH1SelectionData = new List<CreatedDH>();
                                    LogInfo($"Check if DH0 is already created in field {_groupdeData.Key.ToText()}");
                                    createdDH0Data = await FetchCreatedSelectionData(client, fetchDataURL, gridID, _groupdeData.Key.ToText(), "28", requiredColumns);

                                    //create data if it is not already created
                                    var tobeCreated = _groupdeData.Select(x => x).Where(x => !createdDH0Data.Any(y => y.ProposedName == x.DHProposedName)).ToList();
                                    if (tobeCreated.Any())
                                    {
                                        LogInfo($"Create Selection for DHO on field {_groupdeData.Key.ToText()}");
                                        foreach (var _toBeCreated in tobeCreated)
                                        {
                                            //create DH0 record
                                            var createSelectionResp = await CreateDH(client, createSelectionURL, _toBeCreated.Materialkey, _groupdeData.Key, _toBeCreated.DHProposedName, _toBeCreated.FieldEntityType, dH0MethodID);
                                            if(!createSelectionResp.Status.EqualsIgnoreCase("1"))
                                            {
                                                errorMessage.Add(new ExecutableError
                                                {
                                                    Success = false,
                                                    CropCode = _config.CropCode,
                                                    ErrorType = "data",
                                                    ErrorMessage = $"Unable to create selection (Double Haploid) with methodID: {dH0MethodID} () on fieldID: {_groupdeData.Key} with name: {_toBeCreated.DHProposedName}"

                                                });
                                            }
                                        }
                                        //again fetch created Data by applying filter and set grid with value.
                                        gridID = new Random().Next(10000000, 99999999).ToText();

                                        //1. get columns
                                        jsonresp = await PrepareFilterGrid(client, setGridURL, _groupdeData.Key, gridID, filterString, "28");
                                        if (jsonresp.Status.ToText().EqualsIgnoreCase("1"))
                                        {
                                            LogInfo($"Get Created Selection (Double Haploid) data on field {_groupdeData.Key}.");
                                            //get created DH0 data from Fieldset => selection
                                            createdDH0Data = await FetchCreatedSelectionData(client, fetchDataURL, gridID, _groupdeData.Key.ToText(),"28", requiredColumns);
                                        }

                                    }

                                    
                                    //process to know whether created DH0 is moved to field set defined in settings table begins. If not moved, we need to move record
                                    // and then start to create DH1 based on moved DH0 
                                    //1. get grid columns
                                    //2. if required columns is not available add it
                                    //3. get data
                                    //4. if created DH0 on donor field is not moved to this field move from source to destination field 

                                    var nurseryGridID = new Random().Next(10000000, 99999999).ToText();

                                    var setFieldsetGridURL = "/api/v1/simplegrid/grid/create/FieldNursery";
                                    var fetchFieldSetDataURL = "/api/v1/simplegrid/grid/get/FieldNursery";
                                    //1. get grid colummns
                                    LogInfo($"Get Columns from Phenome for field {_config.DHFieldSetSetID}");
                                    columnsResp = await PrepareFilterGrid(client, setFieldsetGridURL, _config.DHFieldSetSetID.ToText(), nurseryGridID, "{}", "24");

                                    //2. if any of two columns is not found add it on grid
                                    LogInfo($"Set required Columns from Phenome for field {_config.DHFieldSetSetID}");
                                    keyvalues.Clear();
                                    requiredColumns.Clear();                                    
                                    requiredColumns.Add("gid");
                                    addColumnsResp = await AddColumns(client, setOrderURL, keyvalues, requiredColumns, columnsResp, _config.DHFieldSetSetID.ToText(), "1");
                                    if (!addColumnsResp)
                                    {
                                        LogError($"Unable to set column in List grid on fieldID: {_config.DHFieldSetSetID.ToText()}");
                                        errorMessage.Add(new ExecutableError
                                        {
                                            Success = false,
                                            CropCode = _config.CropCode,
                                            ErrorType = "Exception",
                                            ErrorMessage = $"Unable to set column in List grid on fieldID: {_config.DHFieldSetSetID.ToText()}"

                                        });
                                        continue;
                                    }

                                    //3. filter grid with value.
                                    LogInfo($"Set Grid with filter value on field {_config.DHFieldSetSetID}");
                                    var nurseryfiltervalue = string.Join(",", createdDH0Data.Select(x => x.DH0GID).ToList());
                                    var nurseryfilterString = "{\"gid\":\"" + nurseryfiltervalue + "\"}";

                                    var jsonresp1 = await PrepareFilterGrid(client, setFieldsetGridURL, _config.DHFieldSetSetID.ToText(), nurseryGridID, nurseryfilterString, "24");
                                    if (jsonresp1.Status.ToText().EqualsIgnoreCase("1"))
                                    {
                                        createdDH1NurseryList = await FetchCreatedSelectionData(client, fetchFieldSetDataURL, nurseryGridID, _config.DHFieldSetSetID.ToText(), "24", requiredColumns);
                                    }
                                    else
                                    {
                                        LogError($"Unable to set grid on field {_config.DHFieldSetSetID.ToText()}");
                                        errorMessage.Add(new ExecutableError
                                        {
                                            Success = false,
                                            CropCode = _config.CropCode,
                                            ErrorType = "Exception",
                                            ErrorMessage = $"Unable to set grid on field {_config.DHFieldSetSetID.ToText()}"

                                        });
                                        //success = false;
                                        continue;
                                    }

                                    //get data that need to be moved to DH fieldset defined per crop
                                    var dataToMove = createdDH0Data.Except((from t1 in createdDH0Data
                                                     join t2 in createdDH1NurseryList
                                                     on t1.DH0GID equals t2.DH0GID
                                                     select t1).ToList()).ToList();

                                    //move created GID to DH1 list to create DH1
                                    var moveToTargetField = "";
                                    var count = dataToMove.Count;
                                    if (dataToMove.Any())
                                    {
                                        LogInfo($"Move created DH0 to Field {_config.DHFieldSetSetID}");
                                        var dragDropURL = "/api/v2/fieldentity/nurseries/set";
                                        var createdSelectionID = string.Join("\",\"", dataToMove.Select(x => x.DH0RowID).ToList());
                                        var selectionIDS = $"[\"{ createdSelectionID }\"]";                                        
                                        moveToTargetField = await MoveDH0ToTargetField(client, dragDropURL, _config.DHFieldSetSetID, selectionIDS, count, _groupdeData.Key.ToText());
                                    }
                                        
                                    if ((count > 0 && JsonConvert.DeserializeObject<PhenomeResponse>(moveToTargetField).Status == "1") || count <=0)
                                    {
                                        nurseryGridID = new Random().Next(10000000, 99999999).ToText();
                                        jsonresp1 = await PrepareFilterGrid(client, setFieldsetGridURL, _config.DHFieldSetSetID.ToText(), nurseryGridID, nurseryfilterString, "24");
                                        if (jsonresp1.Status.ToText().EqualsIgnoreCase("1"))
                                        {   
                                            createdDH1NurseryList = await FetchCreatedSelectionData(client, fetchFieldSetDataURL, nurseryGridID, _config.DHFieldSetSetID.ToText(), "24", requiredColumns);

                                            var listWithNewRowID = (from t1 in createdDH0Data
                                                                   join t2 in createdDH1NurseryList on t1.DH0GID equals t2.DH0GID
                                                                   select  new CreatedDH()
                                                                   {
                                                                       DH0GID = t2.DH0GID,
                                                                       ProposedName = t1.ProposedName,
                                                                       DH0RowID = t2.DH0RowID
                                                                   }).ToList();

                                            gridID = new Random().Next(10000000, 99999999).ToText();

                                            //get created DH1 data now
                                            LogInfo($"Check if DH1 is already created in field {_config.DHFieldSetSetID.ToText()}");
                                            //1. get columns
                                            columnsResp = await PrepareFilterGrid(client, setGridURL, _config.DHFieldSetSetID.ToText(), gridID, "{}", "28");

                                            //2. add required columns if not available
                                            keyvalues.Clear();
                                            requiredColumns.Clear();                                            
                                            requiredColumns.Add("gid");
                                            requiredColumns.Add("name");
                                            requiredColumns.Add(masterNrColPerCrop[_config.ResearchGroupID]);                                            

                                            addColumnsResp = await AddColumns(client, setOrderURL, keyvalues, requiredColumns, columnsResp, _config.DHFieldSetSetID.ToText(), "6");                                            
                                            if (!addColumnsResp)
                                            {
                                                LogError($"Unable to set column in selection grid on fieldID: { _config.DHFieldSetSetID.ToText()}");
                                                errorMessage.Add(new ExecutableError
                                                {
                                                    Success = false,
                                                    CropCode = _config.CropCode,
                                                    ErrorType = "Exception",
                                                    ErrorMessage = $"Unable to set column in selection grid on fieldID: { _config.DHFieldSetSetID.ToText()}"

                                                });
                                                continue;
                                            }
                                            var createdDH1 = await PrepareFilterGrid(client, setGridURL, _config.DHFieldSetSetID.ToText(), gridID, filterString, "28");
                                            if(createdDH1.Status.ToText().EqualsIgnoreCase("1"))
                                            {
                                                var createdDH1Data = await FetchCreatedSelectionData(client, fetchDataURL, gridID, _config.DHFieldSetSetID.ToText(), "28", requiredColumns);
                                                var tobeCreatedDH1 = _groupdeData.Select(x => x).Where(x => !createdDH1Data.Any(y => y.ProposedName == x.DHProposedName)).ToList();
                                                if (tobeCreatedDH1.Any())
                                                {
                                                    LogInfo($"Create Selection for DH1 on field {_config.DHFieldSetSetID}");
                                                    foreach (var _tobeCreatedDH1 in tobeCreatedDH1)
                                                    {
                                                        
                                                        var rowID = listWithNewRowID.FirstOrDefault(x => x.ProposedName == _tobeCreatedDH1.DHProposedName)?.DH0RowID;
                                                        if (!string.IsNullOrWhiteSpace(rowID))
                                                        {
                                                            var createDH1Resp = await CreateDH(client, createSelectionURL, rowID, _config.DHFieldSetSetID.ToText(), _tobeCreatedDH1.DHProposedName, "1", dH1MethodID);
                                                            if (!createDH1Resp.Status.EqualsIgnoreCase("1"))
                                                            {
                                                                errorMessage.Add(new ExecutableError
                                                                {
                                                                    Success = false,
                                                                    CropCode = _config.CropCode,
                                                                    ErrorType = "data",
                                                                    ErrorMessage = $"Unable to create selection (Selfing) with methodID: {dH1MethodID} () on fieldID: {_config.DHFieldSetSetID} with name: { _tobeCreatedDH1.DHProposedName}"
                                                                });
                                                            }

                                                        }
                                                    }
                                                }

                                                //again fetch created Data by applying filter and set grid with value.
                                                
                                                jsonresp = await PrepareFilterGrid(client, setGridURL, _config.DHFieldSetSetID.ToText(), gridID, filterString, "28");

                                                if (jsonresp.Status.ToText().EqualsIgnoreCase("1"))
                                                {
                                                    createdDH1Data = await FetchCreatedSelectionData(client, fetchDataURL, gridID, _config.DHFieldSetSetID.ToText(), "28",requiredColumns);
                                                }
                                                var jsonvalue = JsonConvert.SerializeObject((from t1 in createdDH0Data
                                                                                                      join t2 in createdDH1Data
                                                                                                      on t1.ProposedName equals t2.ProposedName
                                                                                                      select new CreatedDH
                                                                                                      {
                                                                                                          DH0GID = t1.DH0GID,
                                                                                                          DH1GID = t2.DH0GID,
                                                                                                          ProposedName = t1.ProposedName,
                                                                                                          DH1MasterNr = t2.DH1MasterNr
                                                                                                      }).Where(x=> !string.IsNullOrWhiteSpace(x.DH0GID) && !string.IsNullOrWhiteSpace(x.DH1GID) && !string.IsNullOrWhiteSpace(x.DH1MasterNr)).ToList());

                                                LogInfo($"Store created GID of DH0 and DH1 in table");
                                                await s2SRepository.SaveCreatedDHGID(jsonvalue);

                                            }
                                            else
                                            {
                                                LogError($"Unable to search already created DH1 on field {_config.DHFieldSetSetID.ToText()}");
                                                errorMessage.Add(new ExecutableError
                                                {
                                                    Success = false,
                                                    CropCode = _config.CropCode,
                                                    ErrorType = "Exception",
                                                    ErrorMessage = $"Unable to search already created DH1 on field {_config.DHFieldSetSetID.ToText()}"

                                                });
                                                //success = false;
                                                continue;
                                            }
                                        }
                                        else
                                        {
                                            LogError($"Unable to set grid on field {_config.DHFieldSetSetID.ToText()}");
                                            errorMessage.Add(new ExecutableError
                                            {
                                                Success = false,
                                                CropCode = _config.CropCode,
                                                ErrorType = "Exception",
                                                ErrorMessage = $"Unable to set grid on field {_config.DHFieldSetSetID.ToText()}"

                                            });
                                            //success = false;
                                            continue;
                                        }                                       

                                    }
                                    else
                                    {
                                        LogError($"Unable to move Created DHO to fieldset field {_config.DHFieldSetSetID.ToText()}");
                                        errorMessage.Add(new ExecutableError
                                        {
                                            Success = false,
                                            CropCode = _config.CropCode,
                                            ErrorType = "Exception",
                                            ErrorMessage = $"Unable to move Created DHO to fieldset field {_config.DHFieldSetSetID.ToText()}"

                                        });
                                        //success = false;
                                        continue;
                                    }

                                }
                                else
                                {
                                    LogError($"Unable to set grid on field { _groupdeData.Key.ToText()}");
                                    errorMessage.Add(new ExecutableError
                                    {
                                        Success = false,
                                        CropCode = _config.CropCode,
                                        ErrorType = "Exception",
                                        ErrorMessage = $"Unable to set grid on field { _groupdeData.Key.ToText()}"

                                    });
                                    //success = false;
                                    continue;
                                }
                            }
                            catch (Exception ex)
                            {
                                LogError(ex);
                                errorMessage.Add(new ExecutableError
                                {
                                    Success = false,
                                    CropCode = _config.CropCode,
                                    ErrorType = "Exception",
                                    ErrorMessage = $"Unable to set grid on field { _groupdeData.Key.ToText()}"

                                });
                                //success = false;
                            }

                        }

                    }
                    catch (Exception ex)
                    {
                        LogError(ex);
                        errorMessage.Add(new ExecutableError
                        {
                            Success = false,
                            CropCode = _config.CropCode,
                            ErrorType = "Exception",
                            ErrorMessage = ex.Message

                        });
                        //success = false;
                    }
                }
            }
            return errorMessage;
        }

        private async Task<bool> AddColumns(RestClient client, string setOrderURL, List<Tuple<string, string>> keyvalues, List<string> requiredColumns, PhenomeColumnsResponse columnsResp, string fieldID,string fieldType)
        {
            foreach(var _requiredColumn in requiredColumns)
            {
                var col =  columnsResp.Columns.FirstOrDefault(x => x.id.EqualsIgnoreCase(_requiredColumn));
                if(col == null)
                {
                    keyvalues.Add(Tuple.Create("columnIds", _requiredColumn));
                }
            }
            if(keyvalues.Any())
            {
                keyvalues.Add(Tuple.Create("fieldId", fieldID));
                keyvalues.Add(Tuple.Create("fieldEntityType", fieldType));
                foreach(var _columns in columnsResp.Columns)
                {
                    keyvalues.Add(Tuple.Create("columnIds", _columns.id));
                }

                //call set grid to set new column
                return await SetColumnOnGrid(client, setOrderURL, keyvalues);
            }
            return true;
        }

        private async Task<bool> SetColumnOnGrid(RestClient client,string url, List<Tuple<string,string>> formData)
        {
            var resp = await client.PostAsync(url, values =>
             {
                 foreach (var _formdata in formData)
                 {
                     values.Add(_formdata.Item1, _formdata.Item2);
                 }
             });
            var respContent = await resp.Content.DeserializeAsync<PhenomeResponse>();
            return respContent.Success;
        }

        private async Task<PhenomeColumnsResponse> PrepareFilterGrid(RestClient client, string setGridURL, string objectID, string gridID, string filterString,string objectType)
        {
            var resp123 = await client.PostAsync(setGridURL, values =>
            {
                values.Add("object_type", objectType);
                values.Add("object_id", objectID);
                values.Add("grid_id", gridID);
                values.Add("simple_filter", $"{filterString}");
            });
            await resp123.EnsureSuccessStatusCodeAsync();
            return JsonConvert.DeserializeObject<PhenomeColumnsResponse>(await resp123.Content.ReadAsStringAsync());
        }

        private async Task<string> MoveDH0ToTargetField(RestClient client, string URL, int targetObjectID, string selectionIDS,int count, string sourceObjectID)
        {
            var resp = await client.PostAsync(URL, values =>
            {
                values.Add("objectId", $"{targetObjectID}~24");
                values.Add("fieldId", targetObjectID.ToText());
                values.Add("selectedIds", $"{selectionIDS}");
                values.Add("selectedIdsCount", $"{count.ToText()}");
                values.Add("sourceGridType", "FieldSelections");
                values.Add("sourceObjectId", $"{sourceObjectID}");
                values.Add("targetDropType", "24");
                values.Add("targetObjectId", $"{targetObjectID}");
                values.Add("fieldEntityType", "1");
                values.Add("targetDropType", "24");
                values.Add("drag_lots_action", "1");
                values.Add("onlyNonExist", "1");
            });
            await resp.EnsureSuccessStatusCodeAsync();
            return await resp.Content.ReadAsStringAsync(); 
        }

        private async Task<CreateSelectionJobResp> CreateDH(RestClient client, string URL, string RowID, string objectID, string proposedName, string fieldEntityType, string methodID)
        {
            var resp = await client.PostAsync(URL, values =>
            {
                values.Add("method", methodID);
                values.Add("selectedRowsIds", "[" + RowID + "]");
                values.Add("objectId", objectID);
                values.Add("number", proposedName);
                values.Add("groupToSingle", "0");
                values.Add("fieldEntityType", fieldEntityType);
            });
            await resp.EnsureSuccessStatusCodeAsync();
            return JsonConvert.DeserializeObject<CreateSelectionJobResp>(await resp.Content.ReadAsStringAsync());
        }

        private async Task<List<CreatedDH>> FetchCreatedSelectionData(RestClient client, string URL, string gridID, string objectID, string objectType, List<string> requiredColumns)
        {           
            XDocument doc;
            var dictiKeyIndex = new Dictionary<string, int>();
            var list = new List<CreatedDH>();
            if (objectType == "28")
            {
                var dataResp = await client.PostAsync(URL, values =>
                {
                    values.Add("object_type", objectType);
                    values.Add("object_id", objectID);
                    values.Add("grid_id", gridID);
                    values.Add("gems_map_id", "0");
                    values.Add("add_header", "1");
                    values.Add("rows_per_page", "999999");
                    values.Add("display_column", "0");
                    values.Add("count", "999999");
                    values.Add("posStart", "0");
                });
                await dataResp.EnsureSuccessStatusCodeAsync();
                doc = XDocument.Load(await dataResp.Content.ReadAsStreamAsync());
            }
            else
            {
                var dataResp = await client.PostAsync(URL, values =>
                {
                    values.Add("object_type", objectType);
                    values.Add("object_id", objectID);
                    values.Add("grid_id", gridID);
                    values.Add("gems_map_id", "0");
                    values.Add("add_header", "1");
                    values.Add("rows_per_page", "999999");
                    values.Add("display_column", "0");
                });
                await dataResp.EnsureSuccessStatusCodeAsync();
                doc = XDocument.Load(await dataResp.Content.ReadAsStreamAsync());
            }


            var columnsList = doc.Descendants("column").Select((x, idx) => new
            {

                ID = x.Attribute("id")?.Value,               
                Index = idx
            }).ToList();


            foreach (var _requiredColumn in requiredColumns)
            {
                var col = columnsList.FirstOrDefault(x => x.ID.EqualsIgnoreCase(_requiredColumn));
                if (col == null)
                {
                    LogError($"Column: {_requiredColumn} not found on field { objectID}");
                    throw new Exception($"Column: {_requiredColumn} not found on field { objectID}");
                }
                //dictiKeyIndex[_requiredColumn] = col.Index;
                dictiKeyIndex.Add(col.ID, col.Index);
            }
            var masterNrCol = requiredColumns.FirstOrDefault(x => x.ToLower().StartsWith("ger"));
            if(string.IsNullOrWhiteSpace(masterNrCol))
            {
                masterNrCol = "TestKey12";
            }
            var rows = doc.Descendants("row");
            foreach (var dr in rows)
            {
                var ID = dr.Attribute("id").Value;
                var celldata = dr.Descendants("cell").ToList();
                list.Add(new CreatedDH
                {
                    DH0RowID = ID,
                    DH0GID = celldata[dictiKeyIndex["gid"]].Value,
                    ProposedName = dictiKeyIndex.ContainsKey("name") ? celldata[dictiKeyIndex["name"]].Value : string.Empty,
                    DH1MasterNr = dictiKeyIndex.ContainsKey(masterNrCol) ? celldata[dictiKeyIndex[masterNrCol]].Value : string.Empty,
                });
            }
            return list;

        }

        private async Task SendEmailAsync(string subject, string msg,string cropCode)
        {
            var config = await _emailConfigService.GetEmailConfigAsync(EmailConfigGroups.SEND_RESULT_MAPPING_MISSING, cropCode);
            var recipients = config?.Recipients;
            if (string.IsNullOrWhiteSpace(recipients))
            {
                //get * email of the same group
                config = await _emailConfigService.GetEmailConfigAsync(EmailConfigGroups.SEND_RESULT_MAPPING_MISSING, "*");
                recipients = config?.Recipients;
                if (string.IsNullOrWhiteSpace(recipients))
                {
                    //get default email
                    config = await _emailConfigService.GetEmailConfigAsync(EmailConfigGroups.DEFAULT_EMAIL_GROUP, "*");
                    recipients = config?.Recipients;
                }
            }

            if (string.IsNullOrWhiteSpace(recipients))
                return;

            var tos = recipients.Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries)
                .Where(o => !string.IsNullOrWhiteSpace(o))
                .Select(o => o.Trim());
            if (tos.Any())
            {
                await _emailService.SendEmailAsync(tos, subject.AddEnv(), msg);
            }
        }

        private async Task<HttpResponseMessage> SignInAsync(RestClient client)
        {
            var ssoEnabled = ConfigurationManager.AppSettings["SSO:Enabled"].ToBoolean();
            if (!ssoEnabled)
            {
                var (UserName, Password) = Credentials.GetCredentials("SyncPhenomeCredentials");
                return await client.PostAsync("/login_do", values =>
                {
                    values.Add("username", UserName);
                    values.Add("password", Password);
                });
            }
            else
            {
                var phenome = new PhenomeSSOClient();
                return await phenome.SignInAsync(client);
            }
        }


        private StringBuilder createCSVFile( DataSet dataset)
        {
            var sb = new StringBuilder();
            var columnsName = dataset.Tables[0].Columns.Cast<DataColumn>().Select(x => x.ColumnName);
            //this is done from service itself. no need to add here
            ////add gen column in last
            //var gencolumn = new DataColumn("Gen");
            //gencolumn.DefaultValue = "DH0";
            //dataset.Tables[0].Columns.Add(gencolumn);
            sb.AppendLine(string.Join(",", columnsName));

            foreach (DataRow row in dataset.Tables[0].Rows)
            {
                var fields = row.ItemArray.Select(x => x.ToString());
                sb.AppendLine(string.Join(",", fields));
            }
            return sb;
        }

        public async Task<List<GermplasmColumn>> GetAllGermplasmColumnsAsync(RestClient client,  int objectID)
        {
            var url = "/api/v1/simplegrid/grid/get_columns_list/Germplasms";
            var response = await client.PostAsync(url, values =>
            {
                values.Add("object_type", "5");
                values.Add("object_id", objectID.ToString());
                values.Add("base_entity_id", objectID.ToString());
            });
            await response.EnsureSuccessStatusCodeAsync();
            //var resp2 = await response.Content.ReadAsStringAsync();
            var resp = await response.Content.DeserializeAsync<GermplmasColumnsAll>();
            if (resp.Status != "1")
            {
                var msg = "Couldn't fetch Germplasm columns information from phenome." + resp.Message.ToText();
                throw new Exception(msg);
            }
            return resp.All_Columns.Where(x => x.id.ToText().ToLower().StartsWith("ger~id") || x.id.ToText().ToLower().StartsWith("ger~name"))
                .Select(o =>
                {
                    var value = Regex.Replace(o.id, "GER~", string.Empty, RegexOptions.IgnoreCase);
                    o.col_num = value;
                    return o;
                }).ToList();
        }

        private void LogInfo(string msg)
        {
            Console.WriteLine(msg);
            _logger.Info(msg);
        }

        private void LogError(Exception msg)
        {
            Console.WriteLine(msg);
            _logger.Error(msg.Message);
        }
        private void LogError(string msg)
        {
            Console.WriteLine(msg);
            _logger.Error(msg);
        }

        public async Task<IEnumerable<S2SGetProgramCodesByCropResult>> GetProjectsAsync(string crop)
        {
            LogInfo("Getting Project codes for crop " + crop);
            var data = await s2SRepository.GetProjectsAsync(crop);
            return data;
        }

        private async Task ExecuteAndWaitFor(int delayInMilliseconds, int noOfRetry, Func<Task<bool>> callback)
        {
            for (var i = 0; i < noOfRetry; i++)
            {
                if (await callback())
                {
                    break;
                }
                await Task.Delay(delayInMilliseconds);
            }
        }

        public Task ManageMarkersAsync(S2SManageMarkersRequestArgs requestArgs)
        {
            return s2SRepository.ManageMarkersAsync(requestArgs);
        }

        public async Task<List<ExecutableError>> StoreGIDinCordysAsync() 
        {
            var errorMessage = new List<ExecutableError>();
            var configs = await s2SRepository.GetSyncConfigAsync(200);
            if (configs.Any())
            {
                var (UserName, Password) = Credentials.GetCredentials();
                using (var svc = new S2SSoapClient
                {
                    Url = ConfigurationManager.AppSettings["S2SCapacitySlotUrl"],
                    Credentials = new NetworkCredential(UserName, Password)
                })
                {
                    var uel = new UELService();
                    foreach (var config in configs)
                    {
                        LogInfo($"Sending DH1 information of Test ID: {config.TestID}.");
                        try
                        {
                            //get DH informaiton based on cropcode from database
                            var data = await s2SRepository.GetDH1DetailsAsync(config.TestID);
                            if (data.Any())
                            {
                                LogInfo($"Calling Cordys service to store DH1 information with total { data.Count() } materials.");

                                var resp = await svc.StoreGIDinCordysAsync(data);
                                if (!resp.Success)
                                {
                                    var msg = $"Error while storing GID on Cordys for Test ID: {config.TestID}, Error: {resp.Error}";
                                    LogError(msg);

                                    errorMessage.Add(new ExecutableError
                                    {
                                        Success = false,
                                        ErrorType = "Exception",
                                        ErrorMessage = msg

                                    });

                                    string logID;
                                    uel.LogError(new Exception(msg), out logID);
                                }
                                else
                                {
                                    //update stattus in database
                                    var proposedName = string.Join(",", data.Select(x => x.PlantNr));
                                    await s2SRepository.UpdateRelationDonorStatusAsync(proposedName, 300);
                                    
                                    LogInfo($"Calling Cordys service to store DH1 information is completed successfully.");
                                }
                            }
                        }
                        catch(Exception ex)
                        {
                            string logID;
                            LogError(ex);
                            errorMessage.Add(new ExecutableError
                            {
                                Success = false,
                                ErrorType = "Exception",
                                ErrorMessage = ex.Message
                            });
                            uel.LogError(ex, out logID);
                        }
                    }                    
                }               
            }
            return errorMessage;
        }

    }

    public class headerFormat
    {
        public string header_name { get; set; }
        public int order { get; set; }
        public string category { get; set; }

    }
}
