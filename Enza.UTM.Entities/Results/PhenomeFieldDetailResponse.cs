using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Enza.UTM.Entities.Results
{
    public class PhenomeFieldDetailResponse : PhenomeResponse
    {
        public PhenomeFieldDetailResponse()
        {
            Info = new PhenomeFieldInfo();
        }
        public PhenomeFieldInfo Info { get; set; }

    }
    public class PhenomeFieldInfo
    {
        public string Code { get; set; }
        public string Description { get; set; }
        public string Name { get; set; }
    }

    public class PhenomeFolderInfo
    {
        public PhenomeFolderInfo()
        {
            Info = new FolderInfo();
        }
        public string Status { get; set; }
        public string Message { get; set; }
        public FolderInfo Info { get; set; }
    }

    public class FolderInfo
    {
        public FolderInfo()
        {
            BO_Variables = new List<BOVariable>();
            RG_Variables = new List<RGVariable>();
        }
        public List<BOVariable> BO_Variables { get; set; }
        public List<RGVariable> RG_Variables { get; set; }
    }

    public class BOVariable
    {
        public string VID { get; set; }
        public string Value { get; set; }
    }

    public class RGVariable
    {
        public string VID { get; set; }
        public string Name { get; set; }
    }
}
