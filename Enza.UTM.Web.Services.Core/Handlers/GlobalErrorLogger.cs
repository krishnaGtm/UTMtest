using System;
using System.Configuration;
using System.Web.Http.ExceptionHandling;
using Enza.UTM.BusinessAccess.Services;
using Enza.UTM.Common.Extensions;
using log4net;

namespace Enza.UTM.Web.Services.Core.Handlers
{
    public class GlobalErrorLogger : ExceptionLogger
    {
        private readonly ILog logger;
        public GlobalErrorLogger()
        {
            logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        }
        public override void Log(ExceptionLoggerContext context)
        {
            if (logger.IsErrorEnabled)
            {
                var exception = context.Exception.GetException();
                logger.Error(exception);
                //Log error in cordys
                CreateUELLog(exception, out var logID);
                if (!string.IsNullOrWhiteSpace(logID))
                {
                    //set logID to request object to pass it to exception handling
                    context.Request.Properties["uel:error_code"] = logID;
                }
            }
        }

        private void CreateUELLog(Exception ex, out string logID)
        {
            logID = string.Empty;
            bool.TryParse(ConfigurationManager.AppSettings["UEL:Enabled"], out var uelEnabled);
            if (uelEnabled)
            {
                try
                {
                    var uelService = new UELService();
                    uelService.LogError(ex, out logID);
                }
                catch (Exception ex2)
                {
                    //log if there is problem with UEL access problem
                    logger.Error(ex2);
                }
            }
        }
    }
}
