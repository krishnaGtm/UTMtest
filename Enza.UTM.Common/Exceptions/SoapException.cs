using System;

namespace Enza.UTM.Common.Exceptions
{
    public class SoapException : Exception
    {
        public SoapException(string faultCode, string faultString, string detail) : base(faultString)
        {
            FaultCode = faultCode;
            Detail = detail;
        }
        public SoapException(string faultString) : base(faultString)
        {
        }

        public string FaultCode { get; set; }
        public string Detail { get; set; }
    }
}
