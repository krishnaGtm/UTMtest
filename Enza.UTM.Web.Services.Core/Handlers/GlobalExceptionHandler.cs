using System.Data.SqlClient;
using System.Net.Http;
using System.Web.Http;
using System.Web.Http.ExceptionHandling;
using System.Web.Http.Results;
using Enza.UTM.Common.Exceptions;
using Enza.UTM.Common.Extensions;

namespace Enza.UTM.Web.Services.Core.Handlers
{
    public class GlobalExceptionHandler : ExceptionHandler
    {
        public override bool ShouldHandle(ExceptionHandlerContext context)
        {
            return true;
        }
        public override void Handle(ExceptionHandlerContext context)
        {
            var exception = context.ExceptionContext.Exception.GetException();
            var errorType = 1;
            switch (exception)
            {
                case SqlException _:
                    var ex = exception as SqlException;
                    //this is custom validation message thrown from sql server
                    if (ex?.Number == 60000)
                    {
                        errorType = 2;
                    }
                    break;
                case BusinessException _:
                    errorType = 2;
                    break;
                case UnAuthorizedException _:
                    errorType = 3;
                    break;
            }
            context.Request.Properties.TryGetValue("uel:error_code", out var logID);
            var error = new HttpError
            {
                {"errorType", errorType},
                {"code", logID},
                {"message", exception.Message}
            };
            var response = context.Request.CreateErrorResponse(System.Net.HttpStatusCode.InternalServerError, error);
            response.ReasonPhrase = exception.GetType().FullName;
            context.Result = new ResponseMessageResult(response);
        }
    }
}
