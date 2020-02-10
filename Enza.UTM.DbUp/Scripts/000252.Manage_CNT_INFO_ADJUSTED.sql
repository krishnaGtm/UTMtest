/*
    DECLARE @DataAsJson NVARCHAR(MAX) = N'{
	 "Materials": [
	   {
		"MaterialID": 0,
		"Selected": true
	   }
	 ],
	 "Details": [
	   {
		"MaterialID": 10,
		"DonorNumber": null,
		"ProcessID": 0,
		"LabLocationID": 0,
		"StartMaterialID": 0,
		"TypeID": 0,
		"Requested": 0,
		"Transplant": 0,
		"Net": 0,
		"RequestedDate": null,
		"DH1ReturnDate": "2019-09-18T12:09:03.577Z",
		"Remarks": "string"
	   }
	 ]
    }';
    EXEC PR_CNT_ManageInfo 4582, @DataAsJson;
*/
ALTER   PROCEDURE [dbo].[PR_CNT_ManageInfo]
(
    @TestID	 INT,
    @DataAsJson NVARCHAR(MAX)
) AS BEGIN
    SET NOCOUNT ON;

    MERGE INTO CnTInfo T
    USING 
    ( 
	   SELECT 
		  V.MaterialID,
		  V.DonorNumber,
		  V.ProcessID,
		  V.LabLocationID,
		  V.StartMaterialID,
		  V.TypeID,
		  V.Requested,
		  V.Transplant,
		  V.Net,
		  V.RequestedDate,
		  V.DH1ReturnDate,
		  V.Remarks,
		  R.RowID
	   FROM OPENJSON(@DataAsJson) WITH
	   (
		  Details	 NVARCHAR(MAX) AS JSON
	   )
	   CROSS APPLY OPENJSON(Details) WITH
	   (
		  MaterialID		  INT,
		  DonorNumber		  NVARCHAR(50),
		  ProcessID		  INT,
		  LabLocationID	  INT,
		  StartMaterialID	  INT,
		  TypeID			  INT,
		  Requested		  INT,
		  Transplant		  INT,
		  Net			  INT,
		  RequestedDate	  DATETIME,
		  DH1ReturnDate	  DATETIME,
		  Remarks			  NVARCHAR(MAX)
	   ) V
	   JOIN Material M ON M.MaterialID = V.MaterialID
	   JOIN [Row] R ON R.MaterialKey = M.MaterialKey
	   JOIN Test T ON T.FileID = R.FileID
	   WHERE T.TestID = @TestID
    ) S
    ON T.RowID = S.RowID
    WHEN NOT MATCHED THEN 
	   INSERT(RowID, ProcessID, LabLocationID, StartMaterialID, TypeID, Requested, Transplant, Net, RequestedDate, DH1ReturnDate, Remarks, DonorNumber) 
	   VALUES(S.RowID, S.ProcessID, S.LabLocationID, S.StartMaterialID, S.TypeID, S.Requested, S.Transplant, S.Net, S.RequestedDate, S.DH1ReturnDate, S.Remarks, S.DonorNumber)
    WHEN MATCHED THEN
	   UPDATE SET 
		  ProcessID	   = S.ProcessID, 
		  LabLocationID   = S.LabLocationID, 
		  StartMaterialID = S.StartMaterialID, 
		  TypeID		   = S.TypeID, 
		  Requested	   = S.Requested, 
		  Transplant	   = S.Transplant, 
		  Net		   = S.Net, 
		  RequestedDate   = S.RequestedDate,
		  DH1ReturnDate   = S.DH1ReturnDate, 
		  Remarks		   = S.Remarks,
		  DonorNumber	   = S.DonorNumber;

    --Now update state of selected rows
    UPDATE R SET 
	   R.Selected = S.Selected
    FROM [Row] R
    JOIN
    (
	   SELECT 
		  R.RowID,
		  V.Selected
	   FROM OPENJSON(@DataAsJson) WITH
	   (
		  Materials NVARCHAR(MAX) AS JSON
	   )
	   CROSS APPLY OPENJSON(Materials) WITH
	   (
		  MaterialID	INT,
		  Selected	BIT
	   ) V
	   JOIN Material M ON M.MaterialID = V.MaterialID
	   JOIN [Row] R ON R.MaterialKey = M.MaterialKey
	   JOIN Test T ON T.FileID = R.FileID
	   WHERE T.TestID = @TestID
    ) S ON S.RowID = R.RowID;
END
GO