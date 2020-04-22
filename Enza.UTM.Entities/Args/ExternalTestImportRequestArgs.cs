using System.IO;
using Enza.UTM.Entities.Args.Abstract;
using System;
using Enza.UTM.Common.Attributes;

namespace Enza.UTM.Entities.Args
{
    public class ExternalTestImportRequestArgs
    {        
        public string CropCode { get; set; }
        public string BrStationCode { get; set; }
        public string CountryCode { get; set; }
        public int TestTypeID  { get; set; }
        public int TestID { get; set; }
        public string TestName { get; set; }
        public DateTime? PlannedDate { get; set; }
        public DateTime? ExpectedDate { get; set; }
        public int? MaterialStateID { get; set; }
        public int? MaterialTypeID { get; set; }
        public int? ContainerTypeID { get; set; }
        public bool Isolated { get; set; }
        public string Source { get; set; }
        public bool ExcludeControlPosition { get; set; }
        public int FileID { get; set; }

        [SwaggerExclude]
        public Stream DataStream { get; set; }
        public int PageSize { get; set; }
    }
}
