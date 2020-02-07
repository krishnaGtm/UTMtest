using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Xml.Linq;
using Enza.UTM.Services.Abstract;
using Enza.UTM.Common;
using Enza.UTM.Common.Exceptions;
using Enza.UTM.Common.Extensions;
using System.Globalization;

namespace Enza.UTM.Services.Proxies
{
    public class ThreeGBSoapClient : SoapClient
    {
        public object Model { get; set; }

        private string GetRequestBodyForGetAvailable3GBProjects()
        {
            var tpl = typeof(ThreeGBSoapClient).Assembly.GetString(
                "Enza.UTM.Services.Requests.GetAvailable3GBProjects.st");
            var body = Template.Render(tpl, Model);
            return body;
        }

        private string GetRequestBodyForUpload3GBMaterials()
        {
            var tpl = typeof(ThreeGBSoapClient).Assembly.GetString(
                "Enza.UTM.Services.Requests.Upload3GBMaterial.st");
            var body = Template.Render(tpl, Model);
            return body;
        }

        public async Task<IEnumerable<ThreeGBSlotData>> GetAvailable3GBProjectAsync()
        {
            var body = GetRequestBodyForGetAvailable3GBProjects();
            var response = await ExecuteAsync("", body);

            var doc = XDocument.Parse(response);
            XNamespace ns = "http://schemas.enzazaden.com/domain/3gb/bpm";
            var status = doc.Descendants(ns + "Status").FirstOrDefault()?.Value;
            if (!status.EqualsIgnoreCase("Success"))
            {
                //var error = doc.Descendants(ns + "ExceptionMessage").FirstOrDefault()?.Value;
                //throw new UTMSoapException(error);
                return Enumerable.Empty<ThreeGBSlotData>();
            }

            //get current system week
            var cullture = CultureInfo.CurrentCulture;
            var dt = DateTime.UtcNow;
            var currentWeekNr = cullture.Calendar.GetWeekOfYear(dt, CalendarWeekRule.FirstDay, DayOfWeek.Monday);
            var weekNr = Convert.ToInt32($"{dt.Year}{currentWeekNr}");

            return doc.Descendants(ns + "Data")
                .Select(o => new ThreeGBSlotData
                {
                    ThreeGBProjectcode = o.Element(ns + "ThreeGBProjectcode")?.Value,
                    Week = Convert.ToInt32(o.Element(ns + "Week")?.Value),
                    ThreeGBTaskID = Convert.ToInt32(o.Element(ns + "ThreeGBTaskID")?.Value),
                    ThreeGBType = o.Element(ns + "ThreeGBType")?.Value,
                    ThreeGBTaskType = o.Element(ns + "ThreeGBTaskType")?.Value
                }).Where(o => o.Week >= weekNr && !string.IsNullOrWhiteSpace(o.ThreeGBProjectcode))
                .OrderBy(o => o.Week)
                .ThenBy(o => o.ThreeGBProjectcode)
                .ToList();
        }

        public async Task<IEnumerable<ThreeGBPlantData>> Upload3GBMaterialsAsync()
        {
            var body = GetRequestBodyForUpload3GBMaterials();
            var response = await ExecuteAsync("", body);
            var doc = XDocument.Parse(response);
            XNamespace ns = "http://schemas.enzazaden.com/domain/3gb/bpm";
            var status = doc.Descendants(ns + "Status").FirstOrDefault()?.Value;
            if (!status.EqualsIgnoreCase("Success"))
            {
                var error = doc.Descendants(ns + "ExceptionMessage").FirstOrDefault()?.Value;
                throw new SoapException(error);
            }

            return doc.Descendants(ns + "PlantList")
                .Select(o => new ThreeGBPlantData
                {
                    ThreeGBPlantID = o.Element(ns + "ThreeGBPlantID")?.Value,
                    BreEZysSource = o.Element(ns + "BreEZysSource")?.Value,
                    PlantID = o.Element(ns + "PlantID")?.Value,
                    ThreeGBTaskID = Convert.ToInt32(o.Element(ns + "ThreeGBTaskID")?.Value)
                }).ToList();
        }

    }
    public class ThreeGBSlotData
    {
        public string ThreeGBProjectcode { get; set; }
        public int Week { get; set; }
        public int ThreeGBTaskID { get; set; }
        public string ThreeGBType { get; set; }
        public string ThreeGBTaskType { get; set; }
    }

    public class ThreeGBPlantData
    {
        public string ThreeGBPlantID { get; set; }
        public string BreEZysSource { get; set; }
        public string PlantID { get; set; }
        public int ThreeGBTaskID { get; set; }
    }

}
