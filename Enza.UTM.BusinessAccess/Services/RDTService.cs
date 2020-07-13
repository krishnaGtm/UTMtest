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

        public RDTService(IRDTRepository rdtRepository, IExcelDataRepository excelDataRepository, IEmailService emailService, IEmailConfigService emailConfigService)
        {
            this.rdtRepository = rdtRepository;
            this.excelDataRepository = excelDataRepository;
            _emailService = emailService;
            _emailConfigService = emailConfigService;
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
    }

    
}
