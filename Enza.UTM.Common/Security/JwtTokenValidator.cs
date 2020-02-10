using System;
using System.Configuration;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Security.Claims;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using Microsoft.IdentityModel.Tokens;

namespace Enza.UTM.Common.Security
{
    public class JwtTokenValidator
    {
        private const string AUTH_HEADER_NAME = "enzauth";
        private readonly JwtSecurityTokenHandler _handler;
        private readonly SymmetricSecurityKey _signingKey;
        public JwtTokenValidator()
        {
            _handler = new JwtSecurityTokenHandler();
            var plainTextSecurityKey = ConfigurationManager.AppSettings["signingsecret"];
            _signingKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(plainTextSecurityKey));
        }

        public ClaimsPrincipal Verify(string token)
        {
            var tokenValidationParameters = new TokenValidationParameters()
            {
                ValidAudiences = new string[]
                {
                    $"http://{AUTH_HEADER_NAME}"
                },
                ValidIssuers = new string[]
                {
                    $"http://{AUTH_HEADER_NAME}"
                },
                IssuerSigningKey = _signingKey,
                ValidateLifetime = true
            };
            return _handler.ValidateToken(token, tokenValidationParameters, out _);
        }
    }
}
