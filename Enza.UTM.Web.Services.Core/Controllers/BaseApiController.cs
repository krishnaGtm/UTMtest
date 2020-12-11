using System.Net.Http;
using System.Web.Http;
using System.Web.Http.Results;

namespace Enza.UTM.Web.Services.Core.Controllers
{
    //[Authorize]
    public abstract class BaseApiController : ApiController
    {
        protected ResponseMessageResult InvalidRequest(string message)
        {
            return InvalidRequest(message, false);
        }

        protected ResponseMessageResult InvalidRequest(string message, bool showGenericError)
        {
            var error = new HttpError
            {
                {"errorType", showGenericError ? 1 : 2},
                {"code", string.Empty},
                {"message", message}
            };
            var response = Request.CreateErrorResponse(System.Net.HttpStatusCode.BadRequest, error);
            response.ReasonPhrase = "Bad Request";
            return new ResponseMessageResult(response);
        }

        protected ResponseMessageResult UnAuthorized(string message)
        {
            var error = new HttpError
            {
                {"errorType", 2},
                {"code", string.Empty},
                {"message", message}
            };
            var response = Request.CreateErrorResponse(System.Net.HttpStatusCode.Unauthorized, error);
            return new ResponseMessageResult(response);
        }
    }
}
