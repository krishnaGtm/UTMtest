using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Enza.UTM.Entities.Results
{
    public class UploadObservationResponse: PhenomeResponse
    {
        public UploadObservationResponse()
        {
            headers_json = new HeadersJon();
        }
        public string upload_row_id { get; set; }
        public string before_upload_status { get; set; }
        public HeadersJon headers_json { get; set; }

    }
    public class HeadersJon
    {
        public HeadersJon()
        {
            headers = new List<Header>();
        }
        public string objectURL { get; set; }
        public string uploadMethod { get; set; }
        public string fileFormat { get; set; }
        public string fileEncoding { get; set; }
        public List<Header> headers { get; set; }

    }
    public class Header
    {
        public string header_name { get; set; }
        public string order { get; set; }
        public string category { get; set; }
    }
}
