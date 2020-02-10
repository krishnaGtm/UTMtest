using Enza.UTM.Common.Exceptions;

namespace Enza.UTM.Entities.Args
{
    public class ExternalDeterminationRequestArgs
    {
        public string CropCode { get; set; }
        public int TestTypeID { get; set; }

        public void Validate()
        {
            if (string.IsNullOrWhiteSpace(CropCode) || TestTypeID <= 0 )
            {
                throw new ValidationException("Parameter missing");
            }
        }
    }
}
