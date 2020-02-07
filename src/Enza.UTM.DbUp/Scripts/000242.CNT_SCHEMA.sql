INSERT TestType(TestTypeID, TestTypeCode, TestTypeName, [Status], DeterminationRequired, RemarkRequired)
VALUES(7, 'C&T', 'C&T', 'ACT', 1, 0);
GO

CREATE TABLE CnTProcess
(
    ProcessID	 INT PRIMARY KEY NOT NULL IDENTITY(1, 1),
    ProcessName NVARCHAR(100) NOT NULL,
    StatusCode	 INT NOT NULL
)
GO
CREATE TABLE CnTLABLocation
(
    LabLocationID	 INT PRIMARY KEY NOT NULL IDENTITY(1, 1),
    LabLocationName NVARCHAR(100) NOT NULL,
    StatusCode	 INT NOT NULL
)
GO
CREATE TABLE CnTStartMaterial
(
    StartMaterialID	 INT PRIMARY KEY NOT NULL IDENTITY(1, 1),
    StartMaterialName NVARCHAR(100) NOT NULL,
    StatusCode	 INT NOT NULL
)
GO
CREATE TABLE CnTType
(
    TypeID	 INT PRIMARY KEY NOT NULL IDENTITY(1, 1),
    TypeName	 NVARCHAR(100) NOT NULL,
    StatusCode	 INT NOT NULL
)
GO

INSERT [Status](StatusID, StatusTable, StatusCode, StatusName, StatusDescription)
VALUES(26, 'CnTProcess', 100, 'Active', 'Active'), (27, 'CnTProcess', 200, 'Inactive', 'Inactive')
GO
INSERT [Status](StatusID, StatusTable, StatusCode, StatusName, StatusDescription)
VALUES(28, 'CnTLABLocation', 100, 'Active', 'Active'), (29, 'CnTLABLocation', 200, 'Inactive', 'Inactive')
GO
INSERT [Status](StatusID, StatusTable, StatusCode, StatusName, StatusDescription)
VALUES(30, 'CnTStartMaterial', 100, 'Active', 'Active'), (31, 'CnTStartMaterial', 200, 'Inactive', 'Inactive')
GO
INSERT [Status](StatusID, StatusTable, StatusCode, StatusName, StatusDescription)
VALUES(32, 'CnTType', 100, 'Active', 'Active'), (33, 'CnTType', 200, 'Inactive', 'Inactive')
GO

DROP TABLE IF EXISTS CnTInfo
GO

CREATE TABLE [dbo].[CnTInfo](
	[CnTInfoID] [int] IDENTITY(1,1) NOT NULL,
	[RowID] [int] NOT NULL,
	[ProcessID]   INT NULL,
	[LabLocationID]	INT NULL,
	[StartMaterialID]    INT NULL,
	[TypeID]		INT NULL,
	[Requested] [int] NULL,
	[Transplant] [int] NULL,
	[Net] [int] NULL,
	[DH1ReturnDate] [DATETIME] NULL,
	[Remarks] [nvarchar](MAX) NULL,
PRIMARY KEY CLUSTERED 
(
	[CnTInfoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CnTInfo]  WITH CHECK ADD FOREIGN KEY([RowID])
REFERENCES [dbo].[Row] ([RowID])
GO

DROP PROCEDURE IF EXISTS PR_GetCntProcesses
GO

CREATE PROCEDURE PR_GetCntProcesses
AS BEGIN
    SET NOCOUNT ON;
    SELECT 
        P.ProcessID,
        P.ProcessName,
	   S.StatusName,
	   Active = CAST(CASE WHEN P.StatusCode = 100 THEN 1 ELSE 0 END AS BIT)
    FROM CnTProcess P
    JOIN [Status] S ON S.StatusCode = P.StatusCode AND S.StatusTable = 'CnTProcess'
    ORDER BY P.ProcessName;
END
GO

DROP PROCEDURE IF EXISTS PR_SaveCnTProcess
GO

/*
    --DECLARE @DataAsJson NVARCHAR(MAX) = N'[{"ProcessID":null,"ProcessName":"Doubled Haploid","Active":true,"Action":"I"}]';
    --DECLARE @DataAsJson NVARCHAR(MAX) = N'[{"ProcessID":5,"ProcessName":"Doubled Haploid1","Active":true,"Action":"U"}]';
    --DECLARE @DataAsJson NVARCHAR(MAX) = N'[{"ProcessID":5,"ProcessName":"Doubled Haploid1","Active":true,"Action":"D"}]';
    DECLARE @DataAsJson NVARCHAR(MAX) = N'[{"ProcessID":null,"ProcessName":"Doubled Haploid2","Active":true,"Action":"I"}]';
    EXEC PR_SaveCnTProcess @DataAsJson;
*/
CREATE PROCEDURE PR_SaveCnTProcess
(
    @DataAsJson NVARCHAR(MAX)
) AS BEGIN
    SET NOCOUNT ON;

    DECLARE @ProcessNames   NVARCHAR(MAX);
    DECLARE @Tbl TABLE(ProcessID INT, ProcessName NVARCHAR(100), Active BIT, [Action] CHAR(1));

    INSERT @Tbl(ProcessID, ProcessName, Active, [Action])
    SELECT ProcessID, ProcessName, Active, [Action] 
    FROM OPENJSON(@DataAsJson) WITH
    (
	   ProcessID   INT,
	   ProcessName NVARCHAR(100),
	   Active		BIT,
	   [Action]	CHAR(1)
    );

    BEGIN TRY
	   BEGIN TRAN;
    
	   --INSERT ONLY UNIQUE Names
	   INSERT CnTProcess(ProcessName, StatusCode)
	   SELECT 
		  T.ProcessName, 
		  CASE WHEN T.Active = 1 THEN 100 ELSE 200 END
	   FROM @Tbl T
	   LEFT JOIN CntProcess P ON P.ProcessName = T.ProcessName
	   WHERE T.[Action] = 'I'
	   AND P.ProcessName IS NULL;

	   ----New item added but it was already exists but in delete state, make is active
	   --UPDATE T SET 
		  --T.StatusCode = 100
	   --FROM CnTProcess T
	   --JOIN @Tbl S ON S.ProcessName = T.ProcessName
	   --WHERE T.StatusCode = 200 
	   --AND S.Act = 'I';	 
    
	   --Add validation for duplicate names while updating
	   SELECT
		  @ProcessNames = COALESCE(@ProcessNames + N',', N'') + S.ProcessName
	   FROM CnTProcess T
	   JOIN @Tbl S ON S.ProcessName = T.ProcessName
	   WHERE S.ProcessID <> T.ProcessID;

	   IF(ISNULL(@ProcessNames, '') <> '') BEGIN
		  SET @ProcessNames = N'Duplicate records found for the following: ' + @ProcessNames;
		  EXEC PR_ThrowError @ProcessNames;
	   END

	   --UPDATE/DELETE
	   UPDATE T 
	   SET 
		  T.ProcessName = S.ProcessName,
		  T.StatusCode = CASE WHEN S.Active = 1 THEN 100 ELSE 200 END 
	   FROM CnTProcess T
	   JOIN @Tbl S ON S.ProcessID = T.ProcessID
	   WHERE S.[Action]  = 'U'

	   COMMIT;
    END TRY
    BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH 
END
GO

DROP PROCEDURE IF EXISTS PR_GetCnTLABLocations
GO

CREATE PROCEDURE PR_GetCnTLABLocations
AS BEGIN
    SET NOCOUNT ON;
    SELECT 
        L.LabLocationID,
        L.LabLocationName,
	   S.StatusName,
	   Active = CAST(CASE WHEN L.StatusCode = 100 THEN 1 ELSE 0 END AS BIT)
    FROM CnTLABLocation L
    JOIN [Status] S ON S.StatusCode = L.StatusCode AND S.StatusTable = 'CnTLABLocation'
    ORDER BY L.LabLocationName;
END
GO

DROP PROCEDURE IF EXISTS PR_SaveCnTLABLocations
GO

/*
    --DECLARE @DataAsJson NVARCHAR(MAX) = N'[{"LabLocationID":null,"LabLocationName":"NL","Active":true,"Action":"I"}]';
    --DECLARE @DataAsJson NVARCHAR(MAX) = N'[{"LabLocationID":5,"LabLocationName":"NL","Active":true,"Action":"U"}]';
    --DECLARE @DataAsJson NVARCHAR(MAX) = N'[{"LabLocationID":5,"LabLocationName":"NL","Active":true,"Action":"D"}]';
    DECLARE @DataAsJson NVARCHAR(MAX) = N'[{"LabLocationID":null,"LabLocationName":"NL","Active":true,"Action":"I"}]';
    EXEC PR_SaveCnTLABLocations @DataAsJson;
*/
CREATE PROCEDURE PR_SaveCnTLABLocations
(
    @DataAsJson NVARCHAR(MAX)
) AS BEGIN
    SET NOCOUNT ON;

    DECLARE @LabLocationNames   NVARCHAR(MAX);
    DECLARE @Tbl TABLE(LabLocationID INT, LabLocationName NVARCHAR(100), Active BIT, [Action] CHAR(1));

    INSERT @Tbl(LabLocationID, LabLocationName, Active, [Action])
    SELECT LabLocationID, LabLocationName, Active, [Action] 
    FROM OPENJSON(@DataAsJson) WITH
    (
	   LabLocationID   INT,
	   LabLocationName NVARCHAR(100),
	   Active		BIT,
	   [Action]	CHAR(1)
    );

    BEGIN TRY
	   BEGIN TRAN;
    
	   --INSERT ONLY UNIQUE Names
	   INSERT CnTLABLocation(LabLocationName, StatusCode)
	   SELECT 
		  T.LabLocationName, 
		  CASE WHEN T.Active = 1 THEN 100 ELSE 200 END
	   FROM @Tbl T
	   LEFT JOIN CnTLABLocation L ON L.LabLocationName = T.LabLocationName
	   WHERE T.[Action] = 'I'
	   AND L.LabLocationName IS NULL;
    
	   --Add validation for duplicate names while updating
	   SELECT
		  @LabLocationNames = COALESCE(@LabLocationNames + N',', N'') + S.LabLocationName
	   FROM CnTLABLocation T
	   JOIN @Tbl S ON S.LabLocationName = T.LabLocationName
	   WHERE S.LabLocationID <> T.LabLocationID;

	   IF(ISNULL(@LabLocationNames, '') <> '') BEGIN
		  SET @LabLocationNames = N'Duplicate records found for the following: ' + @LabLocationNames;
		  EXEC PR_ThrowError @LabLocationNames;
	   END

	   --UPDATE/DELETE
	   UPDATE T 
	   SET 
		  T.LabLocationName = S.LabLocationName,
		  T.StatusCode = CASE WHEN S.Active = 1 THEN 100 ELSE 200 END 
	   FROM CnTLABLocation T
	   JOIN @Tbl S ON S.LabLocationID = T.LabLocationID
	   WHERE S.[Action]  = 'U'

	   COMMIT;
    END TRY
    BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH 
END
GO

DROP PROCEDURE IF EXISTS PR_GetCnTStartMaterials
GO

CREATE PROCEDURE PR_GetCnTStartMaterials
AS BEGIN
    SET NOCOUNT ON;
    SELECT 
        SM.StartMaterialID,
        SM.StartMaterialName,
	   S.StatusName,
	   Active = CAST(CASE WHEN SM.StatusCode = 100 THEN 1 ELSE 0 END AS BIT)
    FROM CnTStartMaterial SM
    JOIN [Status] S ON S.StatusCode = SM.StatusCode AND S.StatusTable = 'CnTStartMaterial'
    ORDER BY SM.StartMaterialName;
END
GO

DROP PROCEDURE IF EXISTS PR_SaveCnTStartMaterials
GO

/*
    DECLARE @DataAsJson NVARCHAR(MAX) = N'[{"StartMaterialID":null,"StartMaterialName":"NL","Active":true,"Action":"I"}]';
    EXEC PR_SaveCnTStartMaterials @DataAsJson;
*/
CREATE PROCEDURE PR_SaveCnTStartMaterials
(
    @DataAsJson NVARCHAR(MAX)
) AS BEGIN
    SET NOCOUNT ON;

    DECLARE @StartMaterials   NVARCHAR(MAX);
    DECLARE @Tbl TABLE(StartMaterialID INT, StartMaterialName NVARCHAR(100), Active BIT, [Action] CHAR(1));

    INSERT @Tbl(StartMaterialID, StartMaterialName, Active, [Action])
    SELECT StartMaterialID, StartMaterialName, Active, [Action] 
    FROM OPENJSON(@DataAsJson) WITH
    (
	   StartMaterialID   INT,
	   StartMaterialName NVARCHAR(100),
	   Active		BIT,
	   [Action]	CHAR(1)
    );

    BEGIN TRY
	   BEGIN TRAN;
    
	   --INSERT ONLY UNIQUE Names
	   INSERT CnTStartMaterial(StartMaterialName, StatusCode)
	   SELECT 
		  T.StartMaterialName, 
		  CASE WHEN T.Active = 1 THEN 100 ELSE 200 END
	   FROM @Tbl T
	   LEFT JOIN CnTStartMaterial SM ON SM.StartMaterialName = T.StartMaterialName
	   WHERE T.[Action] = 'I'
	   AND SM.StartMaterialName IS NULL;
    
	   --Add validation for duplicate names while updating
	   SELECT
		  @StartMaterials = COALESCE(@StartMaterials + N',', N'') + S.StartMaterialName
	   FROM CnTStartMaterial SM
	   JOIN @Tbl S ON S.StartMaterialName = SM.StartMaterialName
	   WHERE S.StartMaterialID <> SM.StartMaterialID;

	   IF(ISNULL(@StartMaterials, '') <> '') BEGIN
		  SET @StartMaterials = N'Duplicate records found for the following: ' + @StartMaterials;
		  EXEC PR_ThrowError @StartMaterials;
	   END

	   --UPDATE/DELETE
	   UPDATE T 
	   SET 
		  T.StartMaterialName = S.StartMaterialName,
		  T.StatusCode = CASE WHEN S.Active = 1 THEN 100 ELSE 200 END 
	   FROM CnTStartMaterial T
	   JOIN @Tbl S ON S.StartMaterialID = T.StartMaterialID
	   WHERE S.[Action]  = 'U';

	   COMMIT;
    END TRY
    BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH 
END
GO

DROP PROCEDURE IF EXISTS PR_GetCnTTypes
GO

CREATE PROCEDURE PR_GetCnTTypes
AS BEGIN
    SET NOCOUNT ON;
    SELECT 
        T.TypeID,
        T.TypeName,
	   S.StatusName,
	   Active = CAST(CASE WHEN T.StatusCode = 100 THEN 1 ELSE 0 END AS BIT)
    FROM CnTType T
    JOIN [Status] S ON S.StatusCode = T.StatusCode AND S.StatusTable = 'CnTType'
    ORDER BY T.TypeName;
END
GO

DROP PROCEDURE IF EXISTS PR_SaveCnTTypes
GO

/*
    DECLARE @DataAsJson NVARCHAR(MAX) = N'[{"TypeID":null,"TypeName":"NL","Active":true,"Action":"I"}]';
    EXEC PR_SaveCnTStartMaterials @DataAsJson;
*/
CREATE PROCEDURE PR_SaveCnTTypes
(
    @DataAsJson NVARCHAR(MAX)
) AS BEGIN
    SET NOCOUNT ON;

    DECLARE @Types   NVARCHAR(MAX);
    DECLARE @Tbl TABLE(TypeID INT, TypeName NVARCHAR(100), Active BIT, [Action] CHAR(1));

    INSERT @Tbl(TypeID, TypeName, Active, [Action])
    SELECT TypeID, TypeName, Active, [Action] 
    FROM OPENJSON(@DataAsJson) WITH
    (
	   TypeID   INT,
	   TypeName NVARCHAR(100),
	   Active		BIT,
	   [Action]	CHAR(1)
    );

    BEGIN TRY
	   BEGIN TRAN;
    
	   --INSERT ONLY UNIQUE Names
	   INSERT CnTType(TypeName, StatusCode)
	   SELECT 
		  T.TypeName, 
		  CASE WHEN T.Active = 1 THEN 100 ELSE 200 END
	   FROM @Tbl T
	   LEFT JOIN CnTType SM ON SM.TypeName = T.TypeName
	   WHERE T.[Action] = 'I'
	   AND SM.TypeName IS NULL;
    
	   --Add validation for duplicate names while updating
	   SELECT
		  @Types = COALESCE(@Types + N',', N'') + S.TypeName
	   FROM CnTType SM
	   JOIN @Tbl S ON S.TypeName = SM.TypeName
	   WHERE S.TypeID <> SM.TypeID;

	   IF(ISNULL(@Types, '') <> '') BEGIN
		  SET @Types = N'Duplicate records found for the following: ' + @Types;
		  EXEC PR_ThrowError @Types;
	   END

	   --UPDATE/DELETE
	   UPDATE T 
	   SET 
		  T.TypeName = S.TypeName,
		  T.StatusCode = CASE WHEN S.Active = 1 THEN 100 ELSE 200 END 
	   FROM CnTType T
	   JOIN @Tbl S ON S.TypeID = T.TypeID
	   WHERE S.[Action]  = 'U';

	   COMMIT;
    END TRY
    BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH 
END
GO