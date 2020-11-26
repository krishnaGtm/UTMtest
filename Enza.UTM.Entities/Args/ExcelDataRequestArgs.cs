using System.IO;
using Enza.UTM.Entities.Args.Abstract;
using System;
using Enza.UTM.Common.Attributes;

namespace Enza.UTM.Entities.Args
{
    public class ExcelDataRequestArgs: PagedRequestArgs
    {        
        public int TestTypeID  { get; set; }
        public int TestID { get; set; }
        [SwaggerExclude]
        public Stream DataStream { get; set; }

    }

    public class ImportDataRequestArgs : ExcelDataRequestArgs
    {
        public int FileID { get; set; }
        public string TestName { get; set; }
        public string FilePath { get; set; }
        public DateTime? PlannedDate { get; set; }
        public DateTime? ExpectedDate { get; set; }
        public int? MaterialStateID { get; set; }
        public int? MaterialTypeID { get; set; }
        public int? ContainerTypeID { get; set; }
        public bool Isolated { get; set; }
        public string Source { get; set; }
        public string ObjectID { get; set; }
        public bool Cumulate { get; set; }
        public string ImportLevel { get; set; }
        public bool ExcludeControlPosition { get; set; }
        public bool BTR { get; set; }
        public string ResearcherName { get; set; }
    }


    public class Sort
    {
        public string Name { get; set; }
        public string Direction { get; set; }
    }
    public class Filter
    {
        public string Name { get; set; }
        public string Expression { get; set; }
        public string Type { get; set; }
        public string Value { get; set; }
        public string Operator { get; set; }
    }
}
