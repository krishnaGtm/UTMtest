﻿using System.Collections.Generic;
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
using System.Web.UI.WebControls;
using Enza.UTM.Services.EmailTemplates;

namespace Enza.UTM.BusinessAccess.Services
{
    public class RDTService : IRDTService
    {
        private static readonly ILog _logger =
           LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        //private readonly string BASE_SVC_URL = ConfigurationManager.AppSettings["3GBServiceUrl"];
        private readonly string PHENOME_BASE_SVC_URL = ConfigurationManager.AppSettings["BasePhenomeServiceUrl"];
        private readonly IRDTRepository rdtRepository;
        private readonly IExcelDataRepository excelDataRepository;
        private readonly IEmailService _emailService;
        private readonly IEmailConfigService _emailConfigService;
        private readonly ITestService _testService;
        private readonly string BASE_SVC_URL = ConfigurationManager.AppSettings["BasePhenomeServiceUrl"];


        public RDTService(IRDTRepository rdtRepository, IExcelDataRepository excelDataRepository, IEmailService emailService, IEmailConfigService emailConfigService,ITestService testService)
        {
            this.rdtRepository = rdtRepository;
            this.excelDataRepository = excelDataRepository;
            _emailService = emailService;
            _emailConfigService = emailConfigService;
            _testService = testService;
        }


        public async Task<ExcelDataResult> ImportDataFromPhenomeAsync(HttpRequestMessage request, PhenomeImportRequestArgs args)
        {
            var result =  await rdtRepository.ImportDataFromPhenomeAsync(request, args);
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
        public async Task<ExcelDataResult> GetDataAsync(ExcelDataRequestArgs requestArgs)
        {
            return await excelDataRepository.GetDataAsync(requestArgs);
        }

        public async Task<MaterialsWithMarkerResult> GetMaterialWithTestsAsync(MaterialsWithMarkerRequestArgs args)
        {
            return await rdtRepository.GetMaterialWithtTestsAsync(args);
            
        }

        public async Task<Test> AssignTestAsync(AssignDeterminationForRDTRequestArgs args)
        {
            return await rdtRepository.AssignTestAsync(args);
        }

        public async Task<RequestSampleTestResult> RequestSampleTestAsync(TestRequestArgs args)
        {
            return await rdtRepository.RequestSampleTestAsync(args);
        }

        public async Task<List<MaterialState>> GetmaterialStatusAsync()
        {
            return await rdtRepository.GetmaterialStatusAsync();
        }

        public async Task<PlatePlanResult> GetRDTtestsOverviewAsync(PlatePlanRequestArgs args)
        {
            return await rdtRepository.GetRDTtestsOverviewAsync(args);
        }

        public async Task<RequestSampleTestCallbackResult> RequestSampleTestCallbackAsync(RequestSampleTestCallBackRequestArgs args)
        {
            return await rdtRepository.RequestSampleTestCallbackAsync(args);
        }
        public async Task<ReceiveRDTResultsReceiveResult> ReceiveRDTResultsAsync(ReceiveRDTResultsRequestArgs args)
        {
            return await rdtRepository.ReceiveRDTResultsAsync(args);
        }

        public async Task<PrintLabelResult> PrintLabelAsync(PrintLabelForRDTRequestArgs reqArgs)
        {
            return await rdtRepository.PrintLabelAsync(reqArgs);
        }

        public async Task<List<string>> GetMappingColumnsAsync()
        {
            return await rdtRepository.GetMappingColumnsAsync();
        }

        public async Task<bool> SendResult()
        {
            var tests = await rdtRepository.GetTests();
            var success = true;
            if(tests.Any())
            {
                //singin to pheonome
                using (var client = new RestClient(BASE_SVC_URL))
                {
                    var resp = await _testService.SignInAsync(client);

                    await resp.EnsureSuccessStatusCodeAsync();

                    var loginresp = await resp.Content.DeserializeAsync<PhenomeResponse>();
                    if (loginresp.Status != "1")
                        throw new Exception("Invalid user name or password");

                    LogInfo("logged in to Phenome successful.");
                    foreach (var _test in tests)
                    {
                        try
                        {
                            //get data
                            var data = await rdtRepository.GetRDTScores(_test.TestID);
                            if (data.Any())
                            {
                                var traits = new List<string>();
                                var groupedData = data.GroupBy(x => x.FieldID);
                                foreach (var _groupedData in groupedData)
                                {
                                    traits.Clear();
                                    var scoreData = _groupedData.ToList();
                                    var dataToCreate = new List<RDTScore>();

                                    //var dataToCreate = _groupedData.ToList();

                                    var flowType = scoreData.FirstOrDefault()?.FlowType;
                                    //flow type = 1 and flow type = 2
                                    if(flowType == 1 || flowType == 2)
                                    {
                                        dataToCreate = scoreData.Where(x => !string.IsNullOrWhiteSpace(x.ColumnLabel)).ToList();
                                        
                                    }
                                    //flow type = 3
                                    else
                                    {
                                        //exclude data which do not have relation mapping (send only those data which have relation with trait)
                                        dataToCreate = scoreData.Where(x => x.TratiDetResultID > 0).ToList();
                                    }
                                    if(!dataToCreate.Any())
                                    {
                                        LogInfo($"No data to sent to Phenome for fieldID {_groupedData.Key}.");
                                        continue;

                                    }

                                    traits = dataToCreate.GroupBy(x => x.ColumnLabel).Select(y => y.Key).ToList();
                                    var fieldID = _groupedData.Key;
                                    var level = dataToCreate.FirstOrDefault().ImportLevel;

                                    //create observation column when required
                                    var createColumn = await CreateObservationColumns(client, traits, fieldID, level);
                                    if (!createColumn)
                                    {
                                        //failed to create column send email portion need to be implelemted
                                        var list = dataToCreate.GroupBy(o => o.ColumnLabel).Select(x => new { x.Key, x.FirstOrDefault(y => y.ColumnLabel == x.Key).ResultStatus });
                                        if (list.Any(o => o.ResultStatus != 200))
                                        {
                                            //this will update status to 300 so that next time when there is error on adding same trait it will not send email.
                                            var resultIds = string.Join(",", dataToCreate.Select(o => o.TestResultID));
                                            await rdtRepository.ErrorSentResultAsync(_test.TestID, resultIds);
                                            await SendAddColumnErrorEmailAsync(_test.CropCode, _test.BreedingStationCode, _test.TestName);
                                        }
                                        continue;
                                    }

                                    var MaterialKey = dataToCreate.Where(x => x.ObservationID <= 0).GroupBy(x => x.MaterialKey).OrderBy(x => x.Key).Select(x => new
                                    {
                                        x.Key,
                                        x.FirstOrDefault().MaterialID
                                    }).ToList();

                                    if (MaterialKey.Any())
                                    {
                                        //create observation record for FEID
                                        var createObservationURL = "/api/v2/fieldentity/observations/create";
                                        var FEIDS = "[\"" + string.Join("\",\"", MaterialKey.OrderBy(x => x.Key).Select(x => x.Key)) + "\"]";
                                        var creationDate = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds() / 1000;
                                        var respCreateObservation = await client.PostAsync(createObservationURL, values =>
                                        {
                                            values.Add("fieldId", fieldID);
                                            values.Add("fieldEntityIds", FEIDS);
                                            values.Add("nrOfObservations", "1");
                                            values.Add("date", creationDate.ToString());
                                        }, 600);//10 minutes

                                        await respCreateObservation.EnsureSuccessStatusCodeAsync();
                                        var respCreateObs = await respCreateObservation.Content.ReadAsStringAsync();
                                        //we have to take observation id when success is sent 
                                        LogInfo("Deserializing create observation response from Phenome.");

                                        var jsonresp1 = (JObject)JsonConvert.DeserializeObject(respCreateObs);
                                        var status1 = jsonresp1["status"];
                                        //string[] row_ids;
                                        Dictionary<string, List<string>> row_ids = new Dictionary<string, List<string>>();
                                        if (status1.ToText() == "1")
                                        {
                                            LogInfo("Create observation successful.");
                                            row_ids = jsonresp1["rows_ids"].ToObject<Dictionary<string, List<string>>>();
                                            var obsrvationAndMaterialkey = row_ids.SelectMany(x => x.Value.Select(y => new UTMResult
                                            {
                                                Materialkey = x.Key,
                                                Observationkey = y
                                            })).ToList();

                                            foreach (var _observation in obsrvationAndMaterialkey)
                                            {

                                                var updateObservation = dataToCreate.Where(x => x.MaterialKey == _observation.Materialkey);
                                                foreach (var _updateObservationID in updateObservation)
                                                {
                                                    _updateObservationID.ObservationID = _observation.Observationkey.ToInt32();
                                                }
                                            }
                                            var list = MaterialKey.Select(x => new { x.MaterialID, x.Key }).ToList();

                                            var observationIDwithMaterialID = (from x in list
                                                                               join y in obsrvationAndMaterialkey on x.Key equals y.Materialkey
                                                                               select new
                                                                               {
                                                                                   x.MaterialID,
                                                                                   y.Observationkey
                                                                               }).ToList();
                                            //update observationID on UTM table so that if new observation score is available then we can update create or update score on same row for same material 
                                            LogInfo("Updating created observationIDs to UTM");
                                            DataTable dt = new DataTable();
                                            dt.Columns.Add("MaterialID", typeof(int));
                                            dt.Columns.Add("Key");
                                            dt.Columns.Add("Value");
                                            foreach (var obs in observationIDwithMaterialID)
                                            {
                                                var dr = dt.NewRow();
                                                dr["Key"] = "PhenomeObsID";
                                                dr["MaterialID"] = obs.MaterialID;
                                                dr["Value"] = obs.Observationkey;
                                                dt.Rows.Add(dr);
                                            }
                                            await rdtRepository.UpdateObsrvationIDAsync(_test.TestID, dt);
                                        }
                                        else
                                        {
                                            LogError("Unable to crete observation.");
                                            continue;
                                        }
                                    }
                                    //create CSV data
                                    var csvData = CreateCSVForUploadObservationRecord(dataToCreate);

                                    //call upload observation service                                   
                                    var uploadURL = "/api/v1/upload/upload/upload_file/Upload-23";
                                    var streamcontent =
                                        new StreamContent(new MemoryStream(Encoding.ASCII.GetBytes(csvData.ToString())));

                                    var respData = await client.PostAsync(uploadURL, new MultipartFormDataContent
                                        {
                                            { new StringContent(fieldID), "uploadFileEntityId" },
                                            { new StringContent("1"), "uploadType" },
                                            { new StringContent("1"), "fileFormat" },
                                            { new StringContent("Update"), "uploadMethod" },
                                            { new StringContent("5"), "objectType" },
                                            { new StringContent(fieldID), "objectId" },
                                            { new StringContent("UTF-8"), "fileEncoding" },
                                            { streamcontent, "uploadFileInputName", $"{fieldID}_RDTobservation.csv" }
                                        }, 600);

                                    await respData.EnsureSuccessStatusCodeAsync();
                                    var respUploadCsv = await respData.Content.ReadAsStringAsync();

                                    respUploadCsv = respUploadCsv.Replace("<html>", "").Replace("</html>", "").Replace("<body>", "")
                                        .Replace("</body>", "").Replace("<textarea>", "")
                                        .Replace("</textarea>", "");

                                    var uploadResp = new UploadObservationResponse();

                                    uploadResp = JsonConvert.DeserializeObject<UploadObservationResponse>(respUploadCsv);

                                    //if status is 1 then success otherwise failure
                                    //if status is 0 check whether entiry have running job error.
                                    int count = 0;
                                    while (uploadResp.Status != "1" && count <= 20 && uploadResp.Message.Contains("Entity has running job"))
                                    {
                                        LogError($"Upload file to create observation failed. {uploadResp.Message }.");
                                        LogInfo($"Re call service started.");
                                        count++;
                                        streamcontent = new StreamContent(new MemoryStream(Encoding.ASCII.GetBytes(csvData.ToString())));
                                        respData = await client.PostAsync(uploadURL, new MultipartFormDataContent
                                        {
                                            { new StringContent(fieldID), "uploadFileEntityId" },
                                            { new StringContent("1"), "uploadType" },
                                            { new StringContent("1"), "fileFormat" },
                                            { new StringContent("Update"), "uploadMethod" },
                                            { new StringContent("5"), "objectType" },
                                            { new StringContent(fieldID), "objectId" },
                                            { new StringContent("UTF-8"), "fileEncoding" },
                                            { streamcontent, "uploadFileInputName", $"{fieldID}_RDTobservation.csv" }
                                        }, 600);

                                        await respData.EnsureSuccessStatusCodeAsync();
                                        respUploadCsv = await respData.Content.ReadAsStringAsync();

                                        respUploadCsv = respUploadCsv.Replace("<html>", "").Replace("</html>", "").Replace("<body>", "")
                                            .Replace("</body>", "").Replace("<textarea>", "")
                                            .Replace("</textarea>", "");

                                        uploadResp = JsonConvert.DeserializeObject<UploadObservationResponse>(respUploadCsv);

                                        await Task.Delay(1000);
                                    }
                                    if (uploadResp.Status == "1")
                                    {
                                        LogInfo("Upload file successful.");


                                        //this is required because we need to change category of columns for runJob which is not same as returned on previous call
                                        //without changing category it didnot worked (may need to ask service provider).
                                        foreach (var _header in uploadResp.headers_json.headers)
                                        {
                                            if (_header.header_name.EqualsIgnoreCase("FEID"))
                                                _header.category = "17";
                                            else
                                                _header.category = "4";
                                        }
                                        var uploadData = new
                                        {
                                            fileFormat = uploadResp.headers_json.fileFormat,
                                            baseObjectId = new string[] { fieldID },
                                            parentRemoval = 0,
                                            baseObjectType = 23,
                                            useAbbreviationNames = 0,
                                            uploadMethod = uploadResp.headers_json.uploadMethod,
                                            headers = uploadResp.headers_json.headers
                                        };
                                        var mainjsonHeader = JsonConvert.SerializeObject(uploadData);

                                        var URL = "/api/v1/upload/upload/register_job";
                                        var content1 = new MultipartFormDataContent();
                                        content1.Add(new StringContent(fieldID), "objectId");
                                        content1.Add(new StringContent("1"), "jobType");
                                        content1.Add(new StringContent(uploadResp.upload_row_id), "uploadId");
                                        content1.Add(new StringContent(mainjsonHeader), "uploadData");

                                        var responseToUpload = await client.PostAsync(URL, content1);
                                        await responseToUpload.EnsureSuccessStatusCodeAsync();

                                        var runJobRespContent = await responseToUpload.Content.ReadAsStringAsync();
                                        //check response of runJob 
                                        var runJobResp = new PhenomeResponse();
                                        runJobResp = JsonConvert.DeserializeObject<PhenomeResponse>(runJobRespContent);
                                        if (runJobResp.Status != "1")
                                        {
                                            //run job failed
                                            LogInfo("Run job failed. Unable to create observation");
                                            continue;
                                        }
                                        else
                                        {
                                            LogInfo("Job successfully queued on phenome");
                                            //update sent result to true.
                                            LogInfo("Marking result as sent");
                                            var testStatus = await rdtRepository.MarkSentResultAsync(_test.TestID, string.Join(",", scoreData.Select(x => x.TestResultID)));
                                            //check status if it is 700 then send test completed email
                                            if (testStatus == 700)
                                            {
                                                await SendTestCompletionEmailAsync(_test.CropCode, _test.BreedingStationCode, _test.TestName);

                                            }
                                        }

                                    }
                                }

                                var traitsLabel = string.Join(", ", traits);
                                await SendPartiallyResultSentEmailAsync(_test.CropCode, _test.BreedingStationCode, _test.TestName, traitsLabel);
                            }


                        }
                        catch (Exception e)
                        {
                            LogError(e.Message);
                            success = false;
                        }
                    }

                }
            }
            return success;
        }

        private async Task SendAddColumnErrorEmailAsync(string cropCode, string brStationCode, string TestName)
        {
            //get test complete email body template
            var testCompleteBoy = EmailTemplate.GetColumnSetErrorEmailTemplate("RDT");
            var body = Template.Render(testCompleteBoy, new
            {
                TestName
            });

            var config = await _emailConfigService.GetEmailConfigAsync(EmailConfigGroups.TEST_COMPLETE_NOTIFICATION, cropCode, brStationCode);
            var recipients = config?.Recipients;
            if (string.IsNullOrWhiteSpace(recipients))
            {
                //get default email
                config = await _emailConfigService.GetEmailConfigAsync(EmailConfigGroups.TEST_COMPLETE_NOTIFICATION, cropCode);
                recipients = config?.Recipients;
                if (string.IsNullOrWhiteSpace(recipients))
                {
                    //get default email
                    config = await _emailConfigService.GetEmailConfigAsync(EmailConfigGroups.TEST_COMPLETE_NOTIFICATION, "*");
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
                var subject = $" Action needed for RDT Test {TestName}";
                await _emailService.SendEmailAsync(tos, subject, body);
            }
        }
        private async Task SendPartiallyResultSentEmailAsync(string cropCode, string brStationCode, string testName,string traits)
        {
            //get test complete email body template
            var testCompleteBoy = EmailTemplate.GetPartiallyResultSentEmailTemplate();
            if(!string.IsNullOrWhiteSpace(traits))
            {
                traits = "[" + traits + "]";
            }
            var body = Template.Render(testCompleteBoy, new
            {
                TestName = testName,
                Traits = traits
            });

            var config = await _emailConfigService.GetEmailConfigAsync(EmailConfigGroups.TEST_COMPLETE_NOTIFICATION, cropCode, brStationCode);
            var recipients = config?.Recipients;
            if (string.IsNullOrWhiteSpace(recipients))
            {
                //get default email
                config = await _emailConfigService.GetEmailConfigAsync(EmailConfigGroups.TEST_COMPLETE_NOTIFICATION, cropCode);
                recipients = config?.Recipients;
                if (string.IsNullOrWhiteSpace(recipients))
                {
                    //get default email
                    config = await _emailConfigService.GetEmailConfigAsync(EmailConfigGroups.TEST_COMPLETE_NOTIFICATION, "*");
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
                var subject = $" Partial result sent for RDT Test {testName}";
                await _emailService.SendEmailAsync(tos, subject.AddEnv(), body);
            }
        }
        private async Task SendTestCompletionEmailAsync(string cropCode, string brStationCode, string testName)
        {
            //get test complete email body template
            var testCompleteBody = EmailTemplate.GetTestCompleteNotificationEmailTemplate("RDT");
            //send test completion email to respective groups
            var body = Template.Render(testCompleteBody, new
            {
                TestName = testName
            });

            var config = await _emailConfigService.GetEmailConfigAsync(EmailConfigGroups.TEST_COMPLETE_NOTIFICATION, cropCode, brStationCode);
            var recipients = config?.Recipients;
            if (string.IsNullOrWhiteSpace(recipients))
            {
                //get default email
                config = await _emailConfigService.GetEmailConfigAsync(EmailConfigGroups.TEST_COMPLETE_NOTIFICATION, cropCode);
                recipients = config?.Recipients;
                if (string.IsNullOrWhiteSpace(recipients))
                {
                    //get default email
                    config = await _emailConfigService.GetEmailConfigAsync(EmailConfigGroups.TEST_COMPLETE_NOTIFICATION, "*");
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
                LogInfo($"Sending Test completion email of RDT test: {testName} to following recipients: {string.Join(",", tos)}");
                var subject = $"RDT test {testName} changed to completed";
                var sender = ConfigurationManager.AppSettings["RDTTestCompletedEmailSender"];
                await _emailService.SendEmailAsync(sender, tos, subject.AddEnv(), body);
                LogInfo($"Sending Test completion email completed.");
            }
        }

        private async Task<bool> CreateObservationColumns(RestClient client, List<string> distinctTraits, string fieldID, string level)
        {
            if (distinctTraits.Any())
            {
                var Url = $"/api/v1/field/info/{fieldID}";
                var response = await client.PostAsync(Url, new MultipartFormDataContent());
                await response.EnsureSuccessStatusCodeAsync();
                var rgidVariables = await response.Content.DeserializeAsync<PhenomeFolderInfo>();
                if (!rgidVariables.Status.EqualsIgnoreCase("1"))
                {
                    LogError($"Invalid response from phenome for call ../api/v1/field/info/{fieldID}");
                    return false;
                }

                //get defined columns
                Url = "/api/v1/simplegrid/grid/get_columns_list/FieldObservations";
                response = await client.PostAsync(Url, new MultipartFormDataContent
                                        {
                                            { new StringContent("29"), "object_type" },
                                            { new StringContent(fieldID), "object_id" },
                                            { new StringContent(fieldID), "base_entity_id" }
                                        }, 600);
                await response.EnsureSuccessStatusCodeAsync();
                var respdefinedColumns = await response.Content.DeserializeAsync<GermplmasColumnsAll>();

                var definedColumns = (from x in respdefinedColumns?.All_Columns?.Where(x => !x.id.Contains("~"))
                                      join y in distinctTraits on x?.desc?.ToText()?.ToLower() equals y?.ToText()?.ToLower()
                                      select y).ToList();

                var tobeDefined = distinctTraits.Except(definedColumns).ToList();


                var tobeDefinedVariables = (from x in rgidVariables.Info?.RG_Variables
                                            join y in tobeDefined on x?.Name?.ToText()?.ToLower().Trim() equals y?.ToText()?.ToLower().Trim()
                                            select new
                                            {
                                                x.VID,
                                                x.Name
                                            }).GroupBy(x => new { x.VID, x.Name }).Select(x => new { x.Key.VID, x.Key.Name }).ToList();

                //var missing traits
                var missing = tobeDefined.Except((from x in tobeDefined join y in tobeDefinedVariables on x.ToText().ToLower().Trim() equals y?.Name.ToText().ToLower().Trim() select x).ToList());
                if (missing.Any())
                {
                    var missingColumns = string.Join(",", missing);
                    LogError($"Unable to find following column(s) in phenome: {missingColumns}");
                    return false;
                }

                if (tobeDefinedVariables.Any())
                {
                    Url = "/api/v2/fieldentity/columns/set/Existing";

                    var content1 = new MultipartFormDataContent();
                    content1.Add(new StringContent("2"), "addFactorVariablesType");
                    content1.Add(new StringContent("1"), "variableType");
                    content1.Add(new StringContent(fieldID), "objectId");
                    content1.Add(new StringContent("7"), "fieldEntityType");//variableName
                    content1.Add(new StringContent(""), "variableName");

                    LogInfo($"Calling set observation parameter for {fieldID}");
                    var variablesIDs = tobeDefinedVariables.Select(x => x.VID);
                    LogInfo($"Variables IDS {string.Join(",", variablesIDs)}");

                    foreach (var _a in tobeDefinedVariables)
                    {
                        content1.Add(new StringContent(_a.VID), "selectedVariablesIds");
                    }

                    var setColResp = await client.PostAsync(Url, content1, 600);
                    await setColResp.EnsureSuccessStatusCodeAsync();
                    var setColRespDesc = await setColResp.Content.DeserializeAsync<PhenomeResponse>();

                    if (!setColRespDesc.Success || setColRespDesc.Message.Contains("limit exceeded"))
                    {
                        LogError($"Error on adding observation column. Error: {setColRespDesc?.Message}");
                        return false;
                    }
                }
            }
            return true;
        }

        private StringBuilder CreateCSVForUploadObservationRecord(List<RDTScore> dataToCreate)
        {
            var sb = new StringBuilder();
            var columnsList = dataToCreate.GroupBy(x => x.ColumnLabel).OrderBy(x => x.Key).Select(x => x.Key).ToList();

            //add FEID (this is treated as observationID column in Phenome which is used to update data)
            columnsList.Insert(0, "FEID");

            //add Columns in CSV file first row as header
            sb.AppendLine(string.Join(",", columnsList));

            //now prepare data
            var groupedItem = dataToCreate.GroupBy(x => x.ObservationID);
            var valueList = new List<string>();
            foreach (var _groupedItem in groupedItem)
            {
                var groupeditemList = _groupedItem.ToList();
                valueList.Clear();
                


                foreach (var _columnList in columnsList)
                {
                    if (_columnList == "FEID")
                        continue;
                    var data = groupeditemList.FirstOrDefault(x => x.ColumnLabel == _columnList);
                    if (data != null)
                        valueList.Add(data.DeterminationScore);
                    else
                        valueList.Add("");
                }
                //insert FEID value here in first index
                valueList.Insert(0, _groupedItem.Key.ToText());
                sb.AppendLine(string.Join(",", valueList));
            }
            return sb;
        }
        private void LogInfo(string msg)
        {
            Console.WriteLine(msg);
            _logger.Info(msg);
        }

        private void LogError(string msg)
        {
            Console.WriteLine(msg);
            _logger.Error(msg);
        }

        
    }

    
}
