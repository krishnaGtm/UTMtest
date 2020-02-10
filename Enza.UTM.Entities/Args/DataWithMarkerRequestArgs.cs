using Enza.UTM.Common.Exceptions;
using Enza.UTM.Entities.Args.Abstract;

namespace Enza.UTM.Entities.Args
{
    public class DataWithMarkerRequestArgs : PagedRequestArgs
    {
        public int TestID { get; set; }
        public void Validate()
        {
            if ( TestID <= 0)
            {
                throw new ValidationException("Missing TestID.");
            }
        }
    }
}
