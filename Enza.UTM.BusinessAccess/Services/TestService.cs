using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Drawing;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.Common;
using Enza.UTM.Common.Exceptions;
using Enza.UTM.Common.Extensions;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using Enza.UTM.Services;
using Enza.UTM.Services.Abstract;
using Enza.UTM.Services.EmailTemplates;
using Enza.UTM.Services.Proxies;
using log4net;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using NPOI.SS.UserModel;
using NPOI.SS.Util;
using NPOI.XSSF.UserModel;

namespace Enza.UTM.BusinessAccess.Services
{
    public class TestService : ITestService
    {
        private static readonly ILog _logger =
           LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        private readonly string BASE_SVC_URL = ConfigurationManager.AppSettings["BasePhenomeServiceUrl"];


        private readonly ITestRepository repository;
        private readonly IUserContext userContext;
        readonly IDataValidationService validationService; 

        private readonly IEmailConfigService emailConfigService;
        private readonly IEmailService emailService;

        public TestService(IUserContext userContext,
            ITestRepository repository,
            IDataValidationService validationService,
            IEmailConfigService emailConfigService,
            IEmailService emailService)
        {
            this.repository = repository;
            this.userContext = userContext;
            this.validationService = validationService;
            this.emailConfigService = emailConfigService;
            this.emailService = emailService;
        }
        public async Task<IEnumerable<TestLookup>> GetLookupAsync(string cropCode, string breedingStationCode)
        {
            return await repository.GetLookupAsync(cropCode, breedingStationCode);
        }

        public async Task<bool> UpdateTestStatusAsync(UpdateTestStatusRequestArgs request)
        {
            return await repository.UpdateTestStatusAsync(request);
        }

        public async  Task<bool> SaveRemarkAsync(SaveRemarkRequestArgs request)
        {
            return await repository.SaveRemarkAsync(request);
        }

        public async Task<PrintLabelResult> PrintPlateLabelsAsync(int testID)
        {
            var labels = await repository.GetPlateLabelsAsync(testID);
            return await ExecutePrintPlateLabelsAsync(labels);
        }

        public async Task<SoapExecutionResult> FillPlatesInLimsAsync(int testID)
        {
            var plates = await repository.GetPlatesForLimsAsync(testID);
            return await ExecuteFillPlateInLimsServiceAsync(plates);
        }

        public async Task<SoapExecutionResult> ReservePlatesInLIMSAsync(int testID)
        {
            var data = await repository.ReservePlatesInLimsAsync(testID);
            return await ExecuteReservePlatesServiceAsync(data, testID);
        }

        public async Task<Test> GetTestDetailAsync(GetTestDetailRequestArgs request)
        {
            return await repository.GetTestDetailAsync(request);
        }

        public async Task<bool> ReservePlateplansInLIMSCallbackAsync(ReservePlateplansInLIMSCallbackRequestArgs args)
        {
            return await repository.ReservePlateplansInLIMSCallbackAsync(args);
        }

        public Task<IEnumerable<ContainerType>> GetContainerTypeLookupAsync()
        {
            return repository.GetContainerTypeLookupAsync();
        }

        public async Task<bool> SavePlannedDateAsync(SavePlannedDateRequestArgs request)
        {
            return await repository.SavePlannedDateAsync(request);
        }

        public async Task<bool> ReserveScoreResult(ReceiveScoreArgs receiveScoreArgs)
        {
            return await repository.ReserveScoreResult(receiveScoreArgs);
        }

        public async Task<bool> UpdateTest(UpdateTestArgs args)
        {
            return await repository.UpdateTest(args);
        }
        public async Task<IEnumerable<SlotForTestResult>> GetSlotForTest(int testID)
        {
            return await repository.GetSlotForTest(testID);
        }

        public async Task<Test> LinkSlotToTest(SaveSlotTestRequestArgs args)
        {
            return await repository.LinkSlotToTest(args);
        }

        private async Task<bool> MarkSentResult(string wellIDS,int TestID)
        {
            return await repository.MarkSentResult(wellIDS,TestID);

        }
        public Task SaveNrOfSamplesAsync(SaveNrOfSamplesRequestArgs args)
        {
            return repository.SaveNrOfSamplesAsync(args);
        }

        public async Task<bool> ValidateAndSendTraitDeterminationResultAsync(string source)
        {
            //first verify that mapping between trait and determination and it's value is present on table and update status of test accordingly.
            //change status if not validated or validated. send mail if mapping relation is missing

            var success = true;
            var missingConversionList = new List<MissingConversion>();
            var invalidTests = new List<int>();
            LogInfo("Validate test for mapping relation.");
            //get list of valid tests which contains results.
            var tests = await repository.GetTestsForTraitDeterminationResultsAsync(source);
            if (!tests.Any())
            {
                LogInfo("There are no any test results to process.");
                return success;
            }

            LogInfo($"Total tests to process on Phenome = {tests.Count()}.");

            //sign in to phenome before processing data
            using (var client = new RestClient(BASE_SVC_URL))
            {
                var resp = await SignInAsync(client);

                await resp.EnsureSuccessStatusCodeAsync();

                var loginresp = await resp.Content.DeserializeAsync<PhenomeResponse>();
                if (loginresp.Status != "1")
                    throw new Exception("Invalid user name or password");

                LogInfo("logged in to Phenome successful.");

                

                foreach (var test in tests)
                {
                    try
                    {
                        LogInfo($"Validating data for the TestID: {test.TestID}");

                        //validate and get results based on a test at a time.
                        //var traitDeterminationValues = await validationService.ValidateTraitDeterminationResultAndSendEmailAsync(test.TestID, true, source);
                        var traitDeterminationValues = (await validationService.ValidateTraitDeterminationResultAsync(test.TestID, true, source)).ToList();
                        if (!traitDeterminationValues.Any())
                        {
                            LogInfo($"There is no any result data to process for TestID: {test.TestID}.");
                            continue;
                        }

                        //var invalidTests = traitDeterminationValues.Where(x => !x.IsValid).GroupBy(x=>x.TestID).Select(x => x.Key).ToList();
                        //var finalDetTraitVal = traitDeterminationValues.Where(x => !invalidTests.Contains(x.TestID));

                        var dataPerTests = traitDeterminationValues
                            //.Where(x => !string.IsNullOrWhiteSpace(x.TraitValue))
                            .GroupBy(x => new { x.InvalidPer, x.FieldID, x.TestID })
                            .ToList();
                        var level = "";

                        foreach (var dataPerTest in dataPerTests)
                        {
                            try
                            {
                                level = "Plant";
                                //var dataPerTest1 = dataPerTest.ToList();
                                missingConversionList.Clear();
                                //var result = dataPerTest.Where(x => !string.IsNullOrWhiteSpace(x.TraitValue)).ToList();
                                var result = dataPerTest.ToList();
                                var statusCode = result.FirstOrDefault().StatusCode;
                                var testId = dataPerTest.FirstOrDefault().TestID;
                                var testName = dataPerTest.FirstOrDefault().TestName;
                                var cropCode = dataPerTest.FirstOrDefault().CropCode;

                                var firstResult = result.FirstOrDefault();
                                if(firstResult.ListID.ToText() == firstResult.Materialkey)
                                {
                                    level = "List";
                                }

                                #region Cummulate result
                                var data = result.Where(x => x.Cummulate || x.ListID.ToText() == x.Materialkey).Select(x => new TestResultCumulate
                                {
                                    DeterminationID = x.DeterminationID,
                                    ListID = x.ListID.ToText(),
                                    Score = x.TraitValue,
                                    DetScore = x.DeterminationValue,
                                    InvalidPer = x.InvalidPer,
                                    ColumnLabel = x.ColumnLabel,
                                    MaterialKey = x.Materialkey,
                          
                                }).ToList();
                                if (data.Any())
                                {
                                    
                                    //cummulate and send cummulate result on response
                                    LogInfo("Cummulation process started for test " + test.TestID);
                                    var cummulatedData = await CumulateAsync(data, cropCode, testId, testName, missingConversionList, result);
                                    
                                    if (data.FirstOrDefault().ListID == data.FirstOrDefault().MaterialKey)//this means material is list not plant
                                    {
                                        //remove all material which are list material and then after add cummulated result.
                                        result.Clear();
                                    }
                                    result.AddRange(cummulatedData);
                                }
                                #endregion

                                //get setting for selected test whether score 9999 is required or not
                                var cropSettings = await repository.GetSettingToExcludeScoreAsync(testId);
                                if(cropSettings)
                                {
                                    //exclude list with value 9999 or blank (this means if 9999 is missing and conversion is not found then cumulative value trait is blank.
                                    var excludeList = result.Where(x => x.DeterminationValue == "9999" || string.IsNullOrWhiteSpace(x.TraitValue)).ToList();
                                    result = result.Except(excludeList).ToList();
                                }

                                //send email for missing conversion and break current loop
                                var data1 = result.Where(x => !x.IsValid).Select(x=>new MissingConversion
                                {
                                    ColumnLabel = x.ColumnLabel,
                                    CropCode = x.CropCode,
                                    DeterminationName = x.DeterminationName,
                                    DeterminationValue = x.DeterminationValue,
                                    TestID = testId,
                                    TestName = testName
                                });
                                
                                missingConversionList.AddRange(data1);
                                if(missingConversionList.Any())
                                {
                                    invalidTests.Add(missingConversionList.FirstOrDefault().TestID);
                                    //if statusCode is 625 then do not send email and break loop
                                    if (statusCode != 625)
                                    {
                                        //send email and update test status to 625
                                        var distinctDeterminations1 = missingConversionList.GroupBy(g => new
                                        {
                                            g.DeterminationName,
                                            g.ColumnLabel,
                                            g.DeterminationValue
                                        }).Select(x => new
                                        {
                                            x.Key.DeterminationName,
                                            x.Key.ColumnLabel,
                                            x.Key.DeterminationValue,
                                        }).ToList();

                                        var tpl = EmailTemplate.GetMissingConversionMail();
                                        var model = new
                                        {
                                            CropCode = cropCode,
                                            TestName = testName,
                                            Determinations = distinctDeterminations1,
                                        };
                                        var body = Template.Render(tpl, model);
                                        //send email to mapped recipients fo this crop
                                        await validationService.SendEmailAsync(cropCode, body);

                                        //update test status
                                        await repository.UpdateTestStatusAsync(new UpdateTestStatusRequestArgs
                                        {
                                            TestId = testId,
                                            StatusCode = 625
                                        });
                                    }
                                    continue;
                                }

                                //if test is in invalid list break loop for current test.
                                //send mail if conversion is missing for different field then break loop.
                                if (invalidTests.Contains(dataPerTest.Key.TestID))
                                    continue;

                                var distinctTraits = result.OrderBy(x => x.ColumnLabel).GroupBy(x => x.ColumnLabel).Select(x => x.Key).ToList();
                                var distinctMaterialWithCount = result.OrderBy(x => x.Materialkey).GroupBy(x => new
                                {
                                    x.Materialkey,
                                    x.ColumnLabel
                                }).Select(y => new
                                {
                                    y.Key.Materialkey,
                                    Count1 = y.Count()
                                }).GroupBy(x => new { x.Materialkey }).Select(x => new
                                {
                                    Count = x.Max(o => o.Count1),
                                    x.Key.Materialkey
                                });

                                //set colummn before creating observation record
                                var setColResp = await CreateObservationColumns(client, distinctTraits, dataPerTest.Key.FieldID, level);
                                if (!setColResp)
                                {
                                    invalidTests.Add(dataPerTest.Key.TestID);
                                    LogError($"Unable to set column for field: {dataPerTest.Key.FieldID}");
                                    throw new Exception($"Unable to set column for field: {dataPerTest.Key.FieldID}");
                                }

                                var discinctCount = distinctMaterialWithCount.GroupBy(x => x.Count).Select(x => x.Key);
                                foreach (var materialcount in discinctCount)
                                {
                                    var MaterialKey = distinctMaterialWithCount.Where(x => x.Count == materialcount).OrderBy(x => x.Materialkey).Select(x => x.Materialkey).ToList();
                                    var dt = CreateDataTableWithData(result, distinctTraits, MaterialKey);

                                    //create observation record for FEID
                                    var createObservationURL = "/api/v2/fieldentity/observations/create";
                                    var FEIDS = "[\"" + string.Join("\",\"", MaterialKey) + "\"]";
                                    var date1 = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds() / 1000; //(int)(DateTime.UtcNow.Subtract(new DateTime(1970, 1, 1))).TotalMilliseconds;
                                    var respCreateObservation = await client.PostAsync(createObservationURL, values =>
                                    {
                                        values.Add("fieldId", dataPerTest.Key.FieldID);
                                        values.Add("fieldEntityIds", FEIDS);
                                        values.Add("nrOfObservations", materialcount.ToText());
                                        values.Add("date", date1.ToString());
                                    }, 600);//10 minutes
                                    await respCreateObservation.EnsureSuccessStatusCodeAsync();
                                    var respCreateObs = await respCreateObservation.Content.ReadAsStringAsync();
                                    //we have to take observation id when success is sent 
                                    LogInfo("Deserializing create observation response from Phenome.");

                                    var jsonresp = (JObject)JsonConvert.DeserializeObject(respCreateObs);
                                    var status = jsonresp["status"];
                                    //string[] row_ids;
                                    Dictionary<string, List<string>> row_ids = new Dictionary<string, List<string>>();
                                    if (status.ToText() == "1")
                                    {
                                        LogInfo("Create observation successful.");
                                        row_ids = jsonresp["rows_ids"].ToObject<Dictionary<string, List<string>>>();
                                        //create csv file to send result to Phenome.
                                        LogInfo($"Creation of CSV file to update observation data started for test field {dataPerTest.Key.FieldID} for testID { test.TestID }.");
                                        //Create CSV FROM Datatable
                                        var csv = CreateCSV(dt, row_ids);
                                        //upload observation csv file to server.                                    
                                        var uploadURL = "/api/v1/upload/upload/upload_file";
                                        var streamcontent =
                                            new StreamContent(new MemoryStream(Encoding.ASCII.GetBytes(csv.ToString())));

                                        var respData = await client.PostAsync(uploadURL, new MultipartFormDataContent
                                        {
                                            { new StringContent(dataPerTest.Key.FieldID), "uploadFileEntityId" },
                                            { new StringContent("1"), "uploadType" },
                                            { new StringContent("1"), "fileFormat" },
                                            { new StringContent("Update"), "uploadMethod" },
                                            { new StringContent("23"), "objectType" },
                                            { new StringContent(dataPerTest.Key.FieldID), "objectId" },
                                            { new StringContent("UTF-8"), "fileEncoding" },
                                            { streamcontent, "uploadFileInputName", $"{dataPerTest.Key.FieldID}_observation.csv" }
                                        }, 600);

                                        await respData.EnsureSuccessStatusCodeAsync();
                                        var respUploadCsv = await respData.Content.ReadAsStringAsync();

                                        respUploadCsv = respUploadCsv.Replace("<html>", "").Replace("</html>", "").Replace("<body>", "")
                                            .Replace("</body>", "").Replace("<textarea>", "")
                                            .Replace("</textarea>", "");

                                        jsonresp = (JObject)JsonConvert.DeserializeObject(respUploadCsv);
                                        status = jsonresp["status"];
                                        string upload_row_id = "";
                                        var message = jsonresp["message"];
                                        //string header = "";
                                        //JArray header = new JArray();
                                        //if status is 1 then success otherwise failure
                                        //if status is 0 check whether entiry have running job error.
                                        int count = 0;
                                        while (status.ToText() != "1" && count <= 20 && message.ToText().Contains("Entity has running job"))
                                        {
                                            LogError($"Upload file to create observation failed. {message.ToText() }.");
                                            LogInfo($"Re call service started.");
                                            count++;
                                            streamcontent = new StreamContent(new MemoryStream(Encoding.ASCII.GetBytes(csv.ToString())));
                                            respData = await client.PostAsync(uploadURL, new MultipartFormDataContent
                                            {
                                                { new StringContent(dataPerTest.Key.FieldID), "uploadFileEntityId" },
                                                { new StringContent("1"), "uploadType" },
                                                { new StringContent("1"), "fileFormat" },
                                                { new StringContent("Update"), "uploadMethod" },
                                                { new StringContent("23"), "objectType" },
                                                { new StringContent(dataPerTest.Key.FieldID), "objectId" },
                                                { new StringContent("UTF-8"), "fileEncoding" },
                                                { streamcontent, "uploadFileInputName", $"{dataPerTest.Key.FieldID}_observation.csv" }
                                            }, 600);

                                            await respData.EnsureSuccessStatusCodeAsync();
                                            respUploadCsv = await respData.Content.ReadAsStringAsync();

                                            respUploadCsv = respUploadCsv.Replace("<html>", "").Replace("</html>", "").Replace("<body>", "")
                                                .Replace("</body>", "").Replace("<textarea>", "")
                                                .Replace("</textarea>", "");

                                            jsonresp = (JObject)JsonConvert.DeserializeObject(respUploadCsv);
                                            status = jsonresp["status"];

                                            await Task.Delay(1000);


                                        }
                                        if (status.ToText() == "1")
                                        {
                                            LogInfo("Upload file successful.");
                                            upload_row_id = jsonresp["upload_row_id"].ToText();
                                            var headerJson = (JObject)JsonConvert.DeserializeObject(jsonresp["headers_json"].ToText());

                                            //create header and add static columns that is added on datatable manually to update data on phenome
                                            //columns to add: FEID (with Category 17), Well(category 4), Plate Name (category 4)
                                            var header = result.OrderBy(x => x.ColumnLabel).Select(x => x.ColumnLabel).Distinct()
                                                .Select((y, i) => new
                                                {
                                                    header_name = y,
                                                    order = (i + 3).ToString(),
                                                    category = "4"
                                                }).Concat(new[]
                                                {
                                                    new
                                                    {
                                                        header_name = "FEID",
                                                        order = "0",
                                                        category = "17"

                                                    },
                                                    new
                                                    {
                                                        header_name = "WellId",
                                                        order = "1",
                                                        category = "4"

                                                    },
                                                    new
                                                    {
                                                        header_name = "PlatId",
                                                        order = "2",
                                                        category = "4"

                                                    }
                                                }).OrderBy(x => x.order).ToList();

                                            var uploadData = new
                                            {
                                                fileFormat = 1,
                                                baseObjectId = new string[] { dataPerTest.Key.FieldID },
                                                parentRemoval = 0,
                                                baseObjectType = 23,
                                                useAbbreviationNames = 0,
                                                uploadMethod = "Update",
                                                headers = header
                                            };
                                            var mainjsonHeader = JsonConvert.SerializeObject(uploadData);

                                            var URL = "/api/v1/upload/upload/register_job";
                                            var content1 = new MultipartFormDataContent();
                                            content1.Add(new StringContent(dataPerTest.Key.FieldID), "objectId");
                                            content1.Add(new StringContent("1"), "jobType");
                                            content1.Add(new StringContent(upload_row_id), "uploadId");
                                            content1.Add(new StringContent(mainjsonHeader), "uploadData");

                                            var responseToUpload = await client.PostAsync(URL, content1);
                                            await responseToUpload.EnsureSuccessStatusCodeAsync();

                                            var runJobResp = await responseToUpload.Content.ReadAsStringAsync();
                                                                                   
                                            //we need a job status to know whether job is successfully queued on phenome.
                                            LogInfo("run job for upload file successful.");

                                            //var materialIds = from t1 in dataPerTest
                                            //                  join t2 in MaterialKey on t1.Materialkey equals t2
                                            //                  select t1.WellID;

                                            var materialIds = dataPerTest.ToList().Select(x => x.WellID);
                                            var wells = string.Join(",", materialIds.Distinct());
                                            //var wells = string.Join(",", dataPerTest.Select(x => x.WellID)):
                                            await MarkSentResult(wells, test.TestID);
                                            LogInfo("Sent result are marked as sent and test will be updated to 700 if all result are sent");

                                            //only send test completing email for completed status (statusCode = 700)
                                            //if test is imported from more than 1 field then there test status will not change to 700 after sending result
                                            // test status will only change to 700 (completed) if all result is sent to Phenome
                                            var testDetail = await GetTestDetailAsync(new GetTestDetailRequestArgs
                                            {
                                                TestID = test.TestID
                                            });                                            
                                            if(testDetail.StatusCode == 700)
                                            {
                                                await SendTestCompletionEmailAsync(cropCode, test.BrStationCode, test.PlatePlanName);
                                            }
                                            
                                        }
                                    }

                                }

                            }
                            catch(BusinessException ex)
                            {
                                LogError(ex.Message);
                                success = false;
                            }
                            catch (Exception ex2)
                            {
                                LogError(ex2);
                                success = false;
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        success = false;
                        LogError(ex);
                    }
                }
            }
            LogInfo("Sending result process is completed.");
            return success;
        }

        private async Task<bool> CreateObservationColumns(RestClient client, List<string> distinctTraits, string fieldID, string level)
        {
            if (distinctTraits.Any())
            {
                var Url = "/api/v1/simplegrid/grid/get_columns_list/FieldPlants";
                LogInfo($"Set observation columns on field {fieldID}");
                if (level == "List")
                    Url = "/api/v1/simplegrid/grid/get_columns_list/FieldNursery";
               
                var response = await client.PostAsync(Url, new MultipartFormDataContent
                                        {
                                            { new StringContent("24"), "object_type" },
                                            { new StringContent(fieldID), "object_id" },
                                            { new StringContent(fieldID), "base_entity_id" }
                                        }, 600);
                await response.EnsureSuccessStatusCodeAsync();
                var respCreateCol = await response.Content.DeserializeAsync<GermplmasColumnsAll>();


                var a = (from x in respCreateCol?.All_Columns
                         join y in distinctTraits on x?.desc?.ToText()?.ToLower() equals y?.ToText()?.ToLower()
                         select new
                         {
                             x.variable_id
                         }).ToList();
                if (!a.Any())
                {
                    LogError("No columns found to add observation column");
                    return false;
                }

                Url = "/api/v2/fieldentity/columns/set/Existing";

                var content1 = new MultipartFormDataContent();
                content1.Add(new StringContent("2"), "addFactorVariablesType");
                content1.Add(new StringContent("1"), "variableType");
                content1.Add(new StringContent(fieldID), "objectId");
                content1.Add(new StringContent("7"), "fieldEntityType");//variableName
                content1.Add(new StringContent(""), "variableName");

                LogInfo($"Calling set observation parameter for {fieldID}");

                foreach (var _a in a)
                {
                    LogInfo($"selectedVariablesIds: {_a.variable_id.ToText()}");
                    content1.Add(new StringContent(_a.variable_id.ToText()), "selectedVariablesIds");
                }

                var setColResp = await client.PostAsync(Url, content1, 600);
                await setColResp.EnsureSuccessStatusCodeAsync();
                var setColRespDesc = await setColResp.Content.DeserializeAsync<PhenomeResponse>();

                if (!setColRespDesc.Success)
                {
                    return false;
                }
                return true;
            }
            return true;
        }

        public async Task<string> DeleteTestAsync(DeleteTestRequestArgs args)
        {
            string message = "Test Successfully deleted.";
            await repository.DeleteTestAsync(args);
            //if previous status is greater than 200 then we have to send email and update response accordingly 
            if (args.StatusCode > 200 && !args.IsLabUser)
            {
                //send email
                string messageBody = $"Plate plan: { args.PlatePlanName }  is deleted by user.";
                await SendEmailAsync(messageBody);
                message = "Test successfully deleted and email notification is sent to lab people.";
            }
            return message;
        }

        public async Task<PlatePlanResult> getPlatePlanOverviewAsync(PlatePlanRequestArgs args)
        {
            return await repository.getPlatePlanOverviewAsync(args);

        }

        public async Task<byte[]> PlatePlanResultToExcelAsync(int testID)
        {
            //get data
            var data = await repository.PlatePlanResultAsync(testID);
            //create excel
            var createExcel = CreateExcelFile(data);
            //apply formating 
            CreateFormatting(createExcel,data.Tables[0].Columns.Count);

            //return created excel
            byte[] result = null;
            using (var ms = new MemoryStream())
            {
                createExcel.Write(ms);
                //ms.Seek(0, SeekOrigin.Begin);
                result = ms.ToArray();
            }
            return result;

        }
        public async Task<byte[]> TestToExcelAsync(int testID)
        {
            //get data
            var data = await repository.TestToExcelAsync(testID);
            //create excel
            var createExcel = CreateExcelFile(data);

            //return created excel
            byte[] result = null;
            using (var ms = new MemoryStream())
            {
                createExcel.Write(ms);
                //ms.Seek(0, SeekOrigin.Begin);
                result = ms.ToArray();
            }
            return result;
        }

        public async Task SendTestCompletionEmailAsync(string cropCode, string brStationCode, string platePlanName)
        {
            //get test complete email body template
            var testCompleteBoy = EmailTemplate.GetTestCompleteNotificationEmailTemplate();

            //send test completion email to respective groups
            var body = Template.Render(testCompleteBoy, new
            {
                platePlanName
            });

            var config = await emailConfigService.GetEmailConfigAsync(EmailConfigGroups.TEST_COMPLETE_NOTIFICATION, cropCode, brStationCode);
            var recipients = config?.Recipients;
            if (string.IsNullOrWhiteSpace(recipients))
            {
                //get default email
                config = await emailConfigService.GetEmailConfigAsync(EmailConfigGroups.TEST_COMPLETE_NOTIFICATION, cropCode);
                recipients = config?.Recipients;
                if (string.IsNullOrWhiteSpace(recipients))
                {
                    //get default email
                    config = await emailConfigService.GetEmailConfigAsync(EmailConfigGroups.TEST_COMPLETE_NOTIFICATION, "*");
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
                LogInfo($"Sending Test completion email of plate plan: {platePlanName} to following recipients: {string.Join(",", tos)}");
                var subject = $"Plate plan {platePlanName} changed to completed";
                await emailService.SendEmailAsync(tos, subject.AddEnv(), body);
                LogInfo($"Sending Test completion email completed.");
            }
        }

        public async Task<int> GetTotalMarkerAsync(int testID)
        {
            return await repository.GetTotalMarkerAsync(testID);
        }


        #region Private Methods

        private XSSFWorkbook CreateExcelFile(DataSet data)
        {
            //create workbook 
            var wb = new NPOI.XSSF.UserModel.XSSFWorkbook();
            //create sheet
            var sheet1 = wb.CreateSheet("Sheet1");

            var header = sheet1.CreateRow(0);
            foreach (DataColumn dc in data.Tables[0].Columns)
            {
                var cell = header.CreateCell(dc.Ordinal);
                cell.SetCellValue(dc.ColumnName);
            }
            //create data
            var rowNr = 1;
            foreach (DataRow dr in data.Tables[0].Rows)
            {
                var row = sheet1.CreateRow(rowNr);
                foreach (DataColumn dc in data.Tables[0].Columns)
                {
                    var cell = row.CreateCell(dc.Ordinal);
                    cell.SetCellType(CellType.String);
                    cell.SetCellValue(dr[dc.ColumnName].ToText());
                }
                rowNr++;
            }
            return wb;
        }

        private void CreateFormatting(XSSFWorkbook wb,int columnCount)
        {
            var sheet1 = wb.GetSheetAt(0);

            //add formating
            XSSFSheetConditionalFormatting sCF = (XSSFSheetConditionalFormatting)sheet1.SheetConditionalFormatting;

            var dict = ColorForValue();
            foreach(var _dict in dict)
            {
                var a = "\""+_dict.Key + "\"";
                XSSFConditionalFormattingRule  cf1=
                (XSSFConditionalFormattingRule)sCF.CreateConditionalFormattingRule(ComparisonOperator.Equal, a);

                XSSFPatternFormatting fill = (XSSFPatternFormatting)cf1.CreatePatternFormatting();
                fill.FillBackgroundColor = _dict.Value;
                fill.FillPattern = FillPattern.SolidForeground;
                CellRangeAddress[] cfRange1 = { new CellRangeAddress(0, sheet1.LastRowNum, 0, columnCount - 1) };
                sCF.AddConditionalFormatting(cfRange1, cf1);
            }
        }
        private Dictionary<string,short> ColorForValue()
        {
            var dict = new Dictionary<string,short>();
            dict.Add("0202", IndexedColors.Grey50Percent.Index);
            dict.Add("0101", IndexedColors.Red.Index);
            dict.Add("0102", IndexedColors.LightBlue.Index);
            dict.Add("0303", IndexedColors.Yellow.Index);
            dict.Add("0404", IndexedColors.Green.Index);
            dict.Add("0103", IndexedColors.SkyBlue.Index);
            dict.Add("0104", IndexedColors.LightOrange.Index);
            dict.Add("0203", IndexedColors.Pink.Index);
            dict.Add("0204", IndexedColors.LightBlue.Index);
            dict.Add("0304", IndexedColors.LightGreen.Index);
            dict.Add("0505", IndexedColors.SeaGreen.Index);
            dict.Add("0105", IndexedColors.SkyBlue.Index);
            dict.Add("0205", IndexedColors.LightCornflowerBlue.Index);
            dict.Add("0305", IndexedColors.LightYellow.Index);
            dict.Add("0405", IndexedColors.Orange.Index);
            dict.Add("0606", IndexedColors.Teal.Index);
            dict.Add("0001", IndexedColors.OliveGreen.Index);
            dict.Add("0002", IndexedColors.Violet.Index);
            dict.Add("9999", IndexedColors.Brown.Index);
            dict.Add("0707", IndexedColors.Brown.Index);
            dict.Add("0106", IndexedColors.Pink.Index);
            dict.Add("0107", IndexedColors.Orange.Index);
            dict.Add("0206", IndexedColors.LightYellow.Index);
            dict.Add("0207", IndexedColors.SeaGreen.Index);
            dict.Add("0306", IndexedColors.Grey80Percent.Index);
            dict.Add("0307", IndexedColors.LightBlue.Index);
            dict.Add("0406", IndexedColors.Maroon.Index);
            dict.Add("0407", IndexedColors.DarkBlue.Index);
            dict.Add("0506", IndexedColors.CornflowerBlue.Index);
            dict.Add("0507", IndexedColors.Orange.Index);
            dict.Add("0607", IndexedColors.DarkBlue.Index);

            return dict;

        }

        private async Task SendEmailAsync(string body)
        {
            var config = await emailConfigService.GetEmailConfigAsync(EmailConfigGroups.MOLECULAR_LAB_GROUP,"*");
            var recipients = config?.Recipients;
            if (string.IsNullOrWhiteSpace(recipients))
            {
                if (string.IsNullOrWhiteSpace(recipients))
                {
                    //get default email
                    config = await emailConfigService.GetEmailConfigAsync(EmailConfigGroups.DEFAULT_EMAIL_GROUP, "*");
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
                await emailService.SendEmailAsync(tos, "Plate Plan deleted".AddEnv(), body);
            }
        }

        

        private void LogInfo(string msg)
        {
            Console.WriteLine(msg);
            _logger.Info(msg);
        }

        private void LogError(Exception msg)
        {
            Console.WriteLine(msg);
            _logger.Error(msg);
        }

        private void LogError(string msg)
        {
            Console.WriteLine(msg);
            _logger.Error(msg);
        }

        private StringBuilder CreateCSV(DataTable dt, Dictionary<string, List<string>> list)
        {
            var sb = new StringBuilder();

            //add header first
            IEnumerable<string> columnNames = dt.Columns.Cast<DataColumn>().
                                  Select(column => column.ColumnName);
            sb.AppendLine(string.Join(",", columnNames));


            var list1 = list.SelectMany(x => x.Value.Select(y => new UTMResult
            {
                Materialkey= x.Key,
                Observationkey = y
            })).ToList();
            //replace FEID material key with list value of observation id 
            int index = dt.Rows.Count;
            for (int i = 0; i < index; i++)
            {
                var row = dt.Rows[i];
                var observation = list1.FirstOrDefault(x => x.Materialkey == row["FEID"].ToText() && x.Added == false);
                if (observation != null)
                {
                    observation.Added = true;
                    row["FEID"] = observation.Observationkey;
                    IEnumerable<string> fields = row.ItemArray.Select(field => field.ToString());
                    sb.AppendLine(string.Join(",", fields));

                }
            }            
            return sb;

        }
        private DataTable CreateDataTableWithData(List<MigrationDataResult> result, List<string> distinctTraits, List<string> distinctMaterial)
        {
            var dt = new DataTable();
            //var distinctTraits = result.OrderBy(x => x.ColumnLabel).GroupBy(x => x.ColumnLabel).Select(x => x.Key).ToList();
            int distinctTraitsCount = distinctTraits.Count;
            if (distinctTraitsCount == 0)
                return dt;
            //create datatable with some extra column: FEID, well, and Plate Name (this is fixed columns)
            //FEID is material key value and should be replaced by ID provided by create observation API
            //and need to pass by replacing on Upload file method
            dt.Columns.Add("FEID");
            dt.Columns.Add("WellId");
            dt.Columns.Add("PlatId");
            //now add trait column
            for (int i = 0; i < distinctTraitsCount; i++)
            {
                var colName = distinctTraits[i];
                dt.Columns.Add(colName);
            }

            var materialCount = distinctMaterial.Count;
            var material = "";
            var plateName = "";
            var position = "";
            for (int i = 0; i < materialCount; i++)
            {
                var dr = dt.NewRow();
                material = distinctMaterial[i];
                dr["FEID"] = material;
                var materialData = result.Where(x => x.Materialkey == material && x.Added == false);
                if(materialData.Any())
                {
                    plateName = materialData.FirstOrDefault(x => x.Materialkey == material && x.Added == false && !string.IsNullOrWhiteSpace(x.PlateName) && !string.IsNullOrWhiteSpace(x.Position))?.PlateName;
                    position = materialData.FirstOrDefault(x => x.Materialkey == material && x.Added == false && !string.IsNullOrWhiteSpace(x.PlateName) && !string.IsNullOrWhiteSpace(x.Position))?.Position;
                    dr["WellId"] = position;
                    dr["PlatId"] = plateName;
                    foreach (var _distinctTraits in distinctTraits)
                    {
                        var value = materialData.FirstOrDefault(x => x.ColumnLabel == _distinctTraits && x.Added == false && x.PlateName == plateName && x.Position == position);
                        if (value != null)
                        {
                            dr[_distinctTraits] = value.TraitValue.ToText();
                            value.Added = true;
                        }
                    }

                }
                dt.Rows.Add(dr);
                //check again if all result added otherwise just continue the loop to execute
                //if not all material added then there is a result that sould be added for already existing material
                //materialData = result.Where(x => x.Materialkey == material && x.Added == false && x.PlateName == plateName && x.Position == position);
                materialData = result.Where(x => x.Materialkey == material && !x.Added);
                if (materialData.Any())
                    i--;
            }
            return dt;
        }
        private async Task<List<MigrationDataResult>> CumulateAsync(List<TestResultCumulate> result, string cropCode, int testId, string testName, List<MissingConversion> missingConversions, List<MigrationDataResult> migrationdata)
        {
            //var test = await repository.CumulateAsync();
            //var result = data;
            var traitValue = new List<TraitDeterminationValue>();
            var result1 = result.GroupBy(x => new { x.ListID, x.ColumnLabel })
                .Select(y => new TestResultToCreate
                {
                    ListID = y.Key.ListID,
                    ColumnLabel = y.FirstOrDefault().ColumnLabel,
                    Materialkey = y.FirstOrDefault().MaterialKey,                    
                    Count = y.Count(),
                    Same = true,
                    UndefinedCount = 0,
                    AcceptablePercentage = y.FirstOrDefault().InvalidPer,
                    Score = y.Select(z => new Scores
                    {
                        Score = z.Score.Trim(),
                        DetScore = z.DetScore.Trim()
                    }).ToList()
                }).ToList();

            foreach (var _result in result1)
            {
                //_result.FinalScore = _result.Score[0]?.Score.ToString();
                _result.FinalScore = _result.Score[0]?.DetScore.ToString();
                foreach (var _val in _result.Score)
                {
                    if (_val.DetScore.ToString() == "9999")
                        _result.UndefinedCount++;

                    if (_result.FinalScore != _val.DetScore.ToString() && _val.DetScore.ToString() != "9999" && _result.FinalScore != "9999")
                        _result.Same = false;

                    if (_val.DetScore.ToString() != "9999" && _result.FinalScore != _val.DetScore.ToString())
                        _result.FinalScore = _val.DetScore.ToString();
                }
                decimal Undefinedpercentage = 0;
                //do calculation of invalid percentage based on undefined count and accepted percentage per crop from table
                if (_result.UndefinedCount > 0)
                {
                    //do calculation and assign it to percentage
                    Undefinedpercentage = ((decimal)_result.UndefinedCount / (decimal)_result.Count) * 100;
                }
                if (Undefinedpercentage > _result.AcceptablePercentage && _result.AcceptablePercentage >=0)
                {
                    _result.FinalScore = "9999";
                }
                else if( _result.Same == false)
                    _result.FinalScore = "5555";

                if(_result.FinalScore == "5555")
                {
                    var convertedValue = traitValue.FirstOrDefault(x => x.CropCode == cropCode && x.ColumnLabel == _result.ColumnLabel && x.DeterminationValue == "5555");
                    if(convertedValue == null)
                    {
                        var fetchFromDatabase = await repository.GetTraitValue(cropCode, _result.ColumnLabel);
                        if(fetchFromDatabase == null)
                        {
                            LogInfo($"Conversion not found for Cumulation result of 5555 for Determination {_result.ColumnLabel}");
                            //send email based on templete for missing conversion
                            var determinationName = "";
                            var statusCode = 0;
                            var migrationResult = migrationdata.Where(x => x.ColumnLabel == _result.ColumnLabel).FirstOrDefault();
                            if (migrationResult != null)
                            {
                                //migrationResult.IsValid = false;
                                statusCode = migrationResult.StatusCode;
                                determinationName = migrationResult.DeterminationName;
                            }
                            
                            missingConversions.Add(new MissingConversion
                            {
                                TestID = testId,
                                TestName = testName,
                                ColumnLabel = _result.ColumnLabel,
                                DeterminationName = determinationName,
                                CropCode = cropCode,                                    
                                DeterminationValue = "5555"

                            });
                           
                        }
                        else
                        {
                            traitValue.Add(fetchFromDatabase);
                            _result.FinalScore = fetchFromDatabase.TraitValue;
                            traitValue.Add(new TraitDeterminationValue
                            {
                                ColumnLabel = _result.ColumnLabel,
                                CropCode = cropCode,
                                DeterminationValue = "5555",
                                TraitValue = fetchFromDatabase.TraitValue
                            });
                        }
                    }
                    else
                    {
                        _result.FinalScore = convertedValue.TraitValue;
                    }
                }
                else
                {
                    var finalScore = _result.Score.FirstOrDefault(x => x.DetScore == _result.FinalScore)?.Score;
                    //if (!string.IsNullOrWhiteSpace(finalScore))
                    //{
                    //    _result.FinalScore = finalScore;
                    //}
                    //this could be null so set this value
                    _result.FinalScore = finalScore;

                }
            }
            var rs = result1.Select(x => new MigrationDataResult
            {
                Materialkey = x.ListID,
                TraitValue = x.FinalScore,
                ColumnLabel = x.ColumnLabel,
                IsValid = string.IsNullOrWhiteSpace(x.FinalScore)?false:true
            }).ToList();

            return await Task.FromResult(rs);
        }
        private async Task<PrintLabelResult> ExecutePrintPlateLabelsAsync(IEnumerable<PlateLabel> data)
        {
            var labelType = ConfigurationManager.AppSettings["PrinterLabelType"];
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
                    Labels = data.Select(o => new
                    {
                        LabelData = new Dictionary<string, string>
                        {
                            {"Crop", o.CropCode},
                            {"Country", o.BreedingStationCode},
                            {"PlateName", o.PlateName},
                            {"PlateNr", o.PlateNumber.ToString()}
                        }
                    }).ToList()
                };
                var result =  await svc.PrintToBarTenderAsync();
                return new PrintLabelResult
                {
                    Success = result.Success,
                    Error = result.Error,
                    PrinterName = labelType
                };
            }
        }
        private async Task<SoapExecutionResult> ExecuteReservePlatesServiceAsync(TestForLIMS data, int testID)
        {
            var credentials = Credentials.GetCredentials();
            using (var svc = new LimsServiceSoapClient
            {
                Url = ConfigurationManager.AppSettings["LimsServiceUrl"],
                Credentials = new NetworkCredential(credentials.UserName, credentials.Password)
            })
            {
                svc.Model = new
                {
                    data.CropCode,
                    data.PlannedWeek,
                    data.PlannedYear,
                    TestID = testID,
                    RequestingUserID = userContext.GetContext().Name,
                    RequestingUserName = userContext.GetContext().FullName,
                    data.TotalPlates,
                    data.TotalTests,
                    SynCode = data.SynCode.ToUpper(),
                    data.Remark,
                    data.Isolated,
                    data.MaterialState,
                    data.MaterialType,
                    data.ContainerType,
                    data.ExpectedWeek,
                    data.ExpectedYear,
                    data.CountryCode,
                    data.PlannedDate,
                    data.ExpectedDate
                };
                return await svc.ReservePlatesInLIMSAsync();
            }
        }
        private async Task<SoapExecutionResult> ExecuteFillPlateInLimsServiceAsync(PlateForLimsResult data)
        {
            var credentials = Credentials.GetCredentials();
            using (var svc = new LimsServiceSoapClient
            {
                Url = ConfigurationManager.AppSettings["LimsServiceUrl"],
                Credentials = new NetworkCredential(credentials.UserName, credentials.Password)
            })
            {
                svc.Model = data;
                return await svc.FillPlatesInLimsAsync();
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


        #endregion

    }
    public static class LinqExtenions
    {

        public static Dictionary<TFirstKey, Dictionary<TSecondKey, TValue>> Pivot<TSource, TFirstKey, TSecondKey, TValue>(this IEnumerable<TSource> source, Func<TSource, TFirstKey> firstKeySelector, Func<TSource, TSecondKey> secondKeySelector, Func<IEnumerable<TSource>, TValue> aggregate)
        {
            var retVal = new Dictionary<TFirstKey, Dictionary<TSecondKey, TValue>>();

            var l = source.ToLookup(firstKeySelector);
            foreach (var item in l)
            {
                var dict = new Dictionary<TSecondKey, TValue>();
                retVal.Add(item.Key, dict);
                var subdict = item.ToLookup(secondKeySelector);
                foreach (var subitem in subdict)
                {
                    dict.Add(subitem.Key, aggregate(subitem));
                }
            }

            return retVal;
        }
    }
}
