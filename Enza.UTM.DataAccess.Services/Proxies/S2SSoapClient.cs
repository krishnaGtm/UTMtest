using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Xml.Linq;
using Enza.UTM.Common;
using Enza.UTM.Common.Exceptions;
using Enza.UTM.Common.Extensions;
using Enza.UTM.Entities.Results;
using Enza.UTM.Services.Abstract;

namespace Enza.UTM.Services.Proxies
{
    public class S2SSoapClient : SoapClient
    {        
        public object Model { get; set; }

        protected override string PrepareBody()
        {
            var body = typeof(UELSoapClient).Assembly.GetString("Enza.UTM.Services.Requests.S2SCapacitySlotRequest.st");
            return Template.Render(body, Model);
        }

        //public (string Result, string LogID) GetResult(string response, XNamespace ns)
        //{
        //    var doc = XDocument.Parse(response);
        //    var result = doc.Descendants(ns + "result")?.FirstOrDefault()?.Value;
        //    var logID = doc.Descendants(ns + "logID")?.FirstOrDefault()?.Value;
        //    return (result, logID);
        //}

        public async Task<IEnumerable<S2SCapacitySlotResult>> GetS2SCapacityAsync()
        {            
            var body = GetRequestBodyForS2SCapacity();
            var response = await ExecuteAsync("", body);

            var doc = XDocument.Parse(response);
            XNamespace ns = "http://contract.enzazaden.com/seed2seed";
            return doc.Descendants(ns + "CapacitySlot")
                .Select(o => new S2SCapacitySlotResult
                {
                    CapacitySlotID = o.Element(ns + "CapacitySlotId")?.Value.ToInt32() ?? 0,
                    SowingCode = o.Element(ns + "SowingCode")?.Value,
                    SowingDate = Convert.ToDateTime(o.Element(ns + "SowingDate")?.Value),
                    Status = o.Element(ns + "Status")?.Value,
                    MaxPlants = o.Element(ns + "MaxPlants")?.Value.ToInt32() ?? 0,
                    ExpectedDeliveryDate = Convert.ToDateTime(o.Element(ns + "ExpectedDeliveryDate")?.Value),
                    DH0Location = o.Element(ns + "DH0Location")?.Value,
                    AvailableNrPlants = o.Element(ns + "AvailableNrPlants")?.Value.ToInt32() ?? 0
                }).ToList();
        }

        public async Task<SoapExecutionResult> StoreGIDinCordysAsync(object model)
        {
            var tpl = typeof(S2SSoapClient).Assembly.GetString("Enza.UTM.Services.Requests.S2SStoreGIDinCordys.st");
            var body = Template.Render(tpl, model);
            var response = await ExecuteAsync("", body);

            var result = new SoapExecutionResult
            {
                Success = true
            };
            var doc = XDocument.Parse(response);
            XNamespace ns = "http://contract.enzazaden.com/UTM/v1";
            var resp = doc.Descendants(ns + "StoreGIDinCordysResponse").FirstOrDefault();
            if (resp != null)
            {
                var status = resp.Element(ns + "status")?.Value;
                var msg = resp.Element(ns + "message")?.Value;
                if (status.EqualsIgnoreCase("Failed"))
                {
                    result.Success = false;
                    result.Error = msg;                  
                }
            }
            return result;
        }

        private string GetRequestBodyForS2SCapacity()
        {
            var tpl = typeof(S2SSoapClient).Assembly.GetString(
                "Enza.UTM.Services.Requests.S2SCapacitySlotRequest.st");
            var body = Template.Render(tpl, Model);
            return body;
        }

        public async Task<IEnumerable<S2SCreateSowingListResult>> UploadDonorlistAsync()
        {
            var body = GetRequestBodyForUploadDonorlist();
            var response = await ExecuteAsync("", body);

            var doc = XDocument.Parse(response);
            XNamespace ns = "http://contract.enzazaden.com/seed2seed";
            var resp = doc.Descendants(ns + "createSowingListResponse").FirstOrDefault();
            if (resp != null)
            {
                var result = resp.Element(ns + "Result")?.Value;
                var error = resp.Element(ns + "Errors")?.Value;
                if (!result.EqualsIgnoreCase("Success"))
                {
                    throw new BusinessException("Failure: "+error);
                }
                else
                {
                    var dt = doc.Descendants(ns + "CreatedDonor")
                           .Select(o => new S2SCreateSowingListResult
                           {
                               BreezysPKReference = o.Element(ns + "BreEZysPKReference")?.Value,
                               BreezysID = o.Element(ns + "BreEZysId")?.Value.ToInt32() ?? 0,
                               DonorNumber = o.Element(ns + "DonorNumber")?.Value,
                           }).ToList();

                    return dt;
                }
            }
            else
            {
                throw new BusinessException("Failure: Invalid response");
            }
            
            
        }

        private string GetRequestBodyForUploadDonorlist()
        {
            var tpl = typeof(S2SSoapClient).Assembly.GetString(
                "Enza.UTM.Services.Requests.S2SCreateSowingListRequest.st");
            var body = Template.Render(tpl, Model);
            return body;
        }

        public async Task<IEnumerable<S2SGetProgramCodesByCropResult>> GetProgramCodesByCropAsync()
        {
            var body = GetRequestBodyForGetProgramCodesByCrop();
            var response = await ExecuteAsync("", body);

            var doc = XDocument.Parse(response);
            XNamespace ns = "http://schemas.enzazaden.com/domain/seed2seed";
            var dt = doc.Descendants(ns + "ProgramCodesForDonorNumber")
                .Select(o => new S2SGetProgramCodesByCropResult
                {
                    Crop = o.Element(ns + "crop")?.Value,
                    Program = o.Element(ns + "program")?.Value,
                    Code = o.Element(ns + "code")?.Value,
                }).ToList();

            return dt;
        }

        private string GetRequestBodyForGetProgramCodesByCrop()
        {
            var tpl = typeof(S2SSoapClient).Assembly.GetString(
                "Enza.UTM.Services.Requests.S2SGetProgramCodesByCropRequest.st");
            var body = Template.Render(tpl, Model);
            return body;
        }
    }
}
