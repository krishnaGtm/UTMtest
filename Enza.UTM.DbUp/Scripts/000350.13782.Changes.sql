ALTER TABLE Material
ADD MaterialState NVARCHAR(100)
GO


CREATE TYPE [dbo].[TVP_PropertyValue] AS TABLE(
	[MaterialID] [int] NOT NULL,
	[key] NVARCHAR(MAX),
	[Value] NVARCHAR(MAX)
)
GO






ALTER PROCEDURE [dbo].[PR_SaveTestMaterialDeterminationWithTVP_ForRDT]
(	
	@CropCode							NVARCHAR(15),
	@TestID								INT,	
	@TVP_TMD_WithDate TVP_TMD_WithDate	READONLY,
	@TVPProperty TVP_PropertyValue		READONLY
) AS BEGIN
	SET NOCOUNT ON;	
	
	--insert or delete statement for merge
	MERGE INTO TestMaterialDetermination T 
	USING @TVP_TMD_WithDate S	
	ON T.MaterialID = S.MaterialID  AND T.DeterminationID = S.DeterminationID AND T.TestID = @TestID
	--This is done because front end may send null for selected value if no change is done on checkbox for determination 
	WHEN MATCHED AND ISNULL(S.Selected,1) = 1 AND ISNULL(T.ExpectedDate,'') != ISNULL(S.ExpectedDate,'')
		THEN UPDATE SET T.ExpectedDate = S.ExpectedDate		
	WHEN MATCHED AND ISNULL(S.Selected,1) = 0 
	THEN DELETE
	WHEN NOT MATCHED AND ISNULL(S.Selected,0) = 1 THEN 
	INSERT(TestID,MaterialID,DeterminationID,ExpectedDate) VALUES (@TestID,S.MaterialID,s.DeterminationID,S.ExpectedDate);


	MERGE INTO Material T 
	USING @TVPProperty S ON T.MaterialID = S.MaterialID AND S.[Key] = 'MaterialState'
	WHEN MATCHED AND ISNULL(T.MaterialState,'') <> ISNULL(S.[Value],'') THEN UPDATE
	SET T.MaterialState = S.[Value];

			
END

GO





ALTER PROCEDURE [dbo].[PR_SaveTestMaterialDetermination_ForRDT]
(
	@TestTypeID								INT,
	@TestID									INT,
	@Columns								NVARCHAR(MAX) = NULL,
	@Filter									NVARCHAR(MAX) = NULL,
	@TVPTestWithExpDate TVP_TMD_WithDate	READONLY,
	@Determinations TVP_Determinations		READONLY,
	@TVPProperty TVP_PropertyValue			READONLY
) AS BEGIN
	SET NOCOUNT ON;
	DECLARE @FileName NVARCHAR(100);
	DECLARE @Tbl TABLE (MaterialID INT, MaterialKey NVARCHAR(50));
	DECLARE @CropCode	NVARCHAR(10),@TestType1 INT,@StatusCode INT;
	DECLARE @FileID		INT;


	BEGIN TRY
		BEGIN TRANSACTION;
		SELECT 
			@FileID = F.FileID,
			@FileName = F.FileTitle,
			@CropCode = CropCode,
			@TestType1 = T.TestTypeID,
			@StatusCode = T.StatusCode
		FROM [File] F
		JOIN Test T ON T.FileID = F.FileID AND T.RequestingUser = F.UserID 
		WHERE T.TestID = @TestID --AND F.UserID = @UserID;

		IF(ISNULL(@FileName, '') = '') BEGIN
			EXEC PR_ThrowError 'Specified file not found';
			RETURN;
		END
		IF(ISNULL(@CropCode,'')='')
		BEGIN
			EXEC PR_ThrowError 'Specified crop not found';
			RETURN;
		END
		--Prevent changing testType when user choose different type of test after creating test.
		IF(ISNULL(@TestTypeID,0) <> ISNULL(@TestType1,0)) BEGIN
			EXEC PR_ThrowError 'Cannot assign different test type for already created test.';
			RETURN;
		END
		--Prevent asigning determination when status is changed to point of no return
		IF(ISNULL(@StatusCode,0) >=400) BEGIN
			EXEC PR_ThrowError 'Cannot assign determination for confirmed test.';
			RETURN;
		END

		IF EXISTS (SELECT 1 FROM @Determinations) BEGIN	
			EXEC  PR_SaveTestMaterialDeterminationWithQuery_ForRDT @FileID, @CropCode, @TestID, @Columns, @Filter, @Determinations
		END
		ELSE BEGIN
			EXEC PR_SaveTestMaterialDeterminationWithTVP_ForRDT @CropCode, @TestID, @TVPTestWithExpDate, @TVPProperty
		END

		--IF EXISTS(SELECT TestID FROM Test WHERE StatusCode = 300 AND TestID = @TestID) BEGIN
		--	EXEC PR_Update_TestStatus @TestID, 350;
		--END
		SELECT TestID, StatusCode 
		FROM Test WHERE TestID = @TestID;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		THROW;
	END CATCH	
END

GO