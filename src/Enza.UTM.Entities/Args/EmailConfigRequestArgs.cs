using Enza.UTM.Entities.Args.Abstract;

namespace Enza.UTM.Entities.Args
{
    public class EmailConfigRequestArgs : PagedRequest2Args
    {
        public string ConfigGroup { get; set; }
        public string CropCode { get; set; }
    }
}
