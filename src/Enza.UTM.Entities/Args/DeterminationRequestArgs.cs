using Enza.UTM.Common.Exceptions;

namespace Enza.UTM.Entities.Args
{
    public class DeterminationRequestArgs
    {
        public string CropCode { get; set; }
        public int TestTypeID { get; set; }
        public int TestID { get; set; }

        public void Validate()
        {
            if(string.IsNullOrWhiteSpace(CropCode)|| TestTypeID <= 0 || TestID <=0)
            {
                throw new ValidationException("Parameter missing");
            }
        }
    }
}
