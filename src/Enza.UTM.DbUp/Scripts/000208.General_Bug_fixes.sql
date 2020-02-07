ALTER PROCEDURE [dbo].[PR_PLAN_GetMaterialTypePerCrop_Lookup]
(
	@CropCode NVARCHAR(10)
) 
AS BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT
		MT.MaterialTypeID,
		MT.MaterialTypeCode,
		MT.MaterialTypeDescription
	 FROM MaterialType MT
	 JOIN MaterialTypeTestProtocol MTTP ON MTTP.MaterialTypeID = MT.MaterialTypeID
	 WHERE MTTP.CropCode = @CropCode
	
END