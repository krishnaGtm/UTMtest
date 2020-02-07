DROP PROCEDURE [dbo].[PR_PLAN_Get_ReserveCapacity_LookUp]
GO

CREATE PROCEDURE [dbo].[PR_PLAN_Get_ReserveCapacity_LookUp]
(
	@AccessibleCropCodes	NVARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT BreedingStationCode, BreedingStationName FROM BreedingStation;

	SELECT DISTINCT C.CropCode, CropName 
	FROM CropRD C
	JOIN MaterialTypeTestProtocol MTP ON MTP.CropCode = C.CropCode
	JOIN string_split(@AccessibleCropCodes, ',') C2 ON C2.[value] = C.CropCode
	ORDER BY CropCode;

	SELECT TestTypeID, TestTypeCode, TestTypeName, DeterminationRequired FROM TestType;

	--SELECT MaterialTypeID, MaterialTypeCode, MaterialTypeDescription FROM MaterialType;
	SELECT MaterialStateID,MaterialStateCode, MaterialStateDescription FROM MaterialState;

	EXEC PR_PLAN_GetCurrentPeriod 1;
END


GO