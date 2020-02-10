using Enza.UTM.Common.Attributes;

namespace Enza.UTM.Entities.Args
{
    public class DeleteTestRequestArgs
    {
        public int TestID { get; set; }
        [SwaggerExclude]
        public int StatusCode { get; set; }
        [SwaggerExclude]
        public string PlatePlanName { get; set; }
    }
}
