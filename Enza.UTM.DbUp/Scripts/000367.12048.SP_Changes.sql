
/*
=========Changes====================
Changed By			DATE				Description

Krishna Gautam		2020-07-29			#12048:Stored procedure created.	

========Example=============
DECLARE @TVP_TMD TVP_TMD;
INSERT INTO @TVP_TMD(MaterialID,DeterminationID,Selected)
VALUES
(59419,88221,1),
(59419,88227,1),
(59419,88222,1)
EXEC PR_RDT_GetMaterialToPrint 10628,'', @TVP_TMD;
*/


ALTER PROCEDURE [dbo].[PR_RDT_GetMaterialToPrint]
(
	@TestID INT,
	@MaterialStatus NVARCHAR(MAX),
	@TVP_TMD TVP_TMD READONLY
)
AS BEGIN
	
	DECLARE @ImportLevel NVARCHAR(MAX);
	DECLARE @TBLMaterialStatus TABLE(MaterialStatus NVARCHAR(MAX));


	SELECT @ImportLevel = ImportLevel FROM Test WHERE TestID = @TestID

	IF(@ImportLevel = 'LIST' AND ISNULL(@MaterialStatus,'') = '')
	BEGIN
		INSERT INTO @TBLMaterialStatus(MaterialStatus)
			SELECT 
				MaterialStatus 
			FROM TestMaterial 
			WHERE TestID = @TestID AND ISNULL(MaterialStatus,'') <> '' 
			GROUP BY MaterialStatus;
	END
	ELSE
	BEGIN
		INSERT INTO @TBLMaterialStatus(MaterialStatus)
			SELECT 
				[Value]
			FROM string_split(@MaterialStatus,',') 
			GROUP BY [Value]
	END

	IF EXISTS(SELECT TOP 1 * FROM @TVP_TMD)
	BEGIN

		SELECT TMD.InterfaceRefID AS LimsID, TM.MaterialStatus, TMD.NrPlants, D.DeterminationName, M.MaterialKey, GID, [Plant Name], lotNr, [E-number], MasterNr , T.ImportLevel
		FROM Test T 
		JOIN TestMaterial TM ON Tm.TestID = T.TestID
		JOIN TestMaterialDetermination TMD ON TMD.TestID = TM.TestID AND TMD.MaterialID = TM.MaterialID
		JOIN @TVP_TMD TVP ON TVP.MaterialID = TMD.MaterialID AND TVP.DeterminationID = TMD.DeterminationID --join tvp here
		JOIN Material M ON M.MaterialID = TM.MaterialID
		JOIN Determination D ON D.DeterminationID = TMD.DeterminationID
		JOIN 
		(
			SELECT T2.MaterialKey, T2.[Plant name], T2.[GID], T2.lotNr, T2.[E-number],T2.MasterNr
			FROM
			(
				SELECT 
					R.MaterialKey,
					C2.ColumLabel,
					CellValue = C.[Value]
				FROM [Cell] C
				JOIN [Column] C2 ON C2.ColumnID = C.ColumnID
				JOIN [Row] R ON R.RowID = C.RowID
				JOIN [File] F ON F.FileID = R.FileID
				JOIN Test T ON T.FileID = F.FileID
				WHERE C2.ColumLabel IN('Plant name','GID', 'lotNr', 'E-number', 'MasterNr')
				AND T.TestID = @TestID
			) T1
			PIVOT
			(
				Max(CellValue)
				FOR [ColumLabel] IN ([Plant name], [GID], [lotNr],[E-number],[MasterNr])
			) T2

		) PT ON PT.MaterialKey = M.MaterialKey 
		
		WHERE T.TestID = @TestID AND TMD.TestID = @TestID AND TM.TestID = @TestID
	END

	ELSE IF EXISTS (SELECT TOP 1 * FROM @TBLMaterialStatus)
	BEGIN
		SELECT TMD.InterfaceRefID AS LimsID, TM.MaterialStatus, TMD.NrPlants, D.DeterminationName, M.MaterialKey, GID, [Plant Name], lotNr, [E-number], MasterNr, T.ImportLevel
		FROM Test T 
		JOIN TestMaterial TM ON Tm.TestID = T.TestID
		JOIN @TBLMaterialStatus MS ON MS.MaterialStatus = TM.MaterialStatus --join material status here
		JOIN TestMaterialDetermination TMD ON TMD.TestID = TM.TestID AND TMD.MaterialID = TM.MaterialID
		JOIN Material M ON M.MaterialID = TM.MaterialID
		JOIN Determination D ON D.DeterminationID = TMD.DeterminationID
		JOIN 
		(
			SELECT T2.MaterialKey, T2.[Plant name], T2.[GID], T2.lotNr, T2.[E-number],T2.MasterNr
			FROM
			(
				SELECT 
					R.MaterialKey,
					C2.ColumLabel,
					CellValue = C.[Value]
				FROM [Cell] C
				JOIN [Column] C2 ON C2.ColumnID = C.ColumnID
				JOIN [Row] R ON R.RowID = C.RowID
				JOIN [File] F ON F.FileID = R.FileID
				JOIN Test T ON T.FileID = F.FileID
				WHERE C2.ColumLabel IN('Plant name','GID', 'lotNr', 'E-number', 'MasterNr')
				AND T.TestID = @TestID
			) T1
			PIVOT
			(
				Max(CellValue)
				FOR [ColumLabel] IN ([Plant name], [GID], [lotNr],[E-number],[MasterNr])
			) T2

		) PT ON PT.MaterialKey = M.MaterialKey 
		
		WHERE T.TestID = @TestID AND TMD.TestID = @TestID AND TM.TestID = @TestID
		
	END

	ELSE
	BEGIN
		SELECT TMD.InterfaceRefID AS LimsID, TM.MaterialStatus, TMD.NrPlants, D.DeterminationName, M.MaterialKey, GID, [Plant Name], lotNr, [E-number], MasterNr, T.ImportLevel 
			FROM Test T 
			JOIN TestMaterial TM ON Tm.TestID = T.TestID
			JOIN TestMaterialDetermination TMD ON TMD.TestID = TM.TestID AND TMD.MaterialID = TM.MaterialID
			JOIN Material M ON M.MaterialID = TM.MaterialID
			JOIN Determination D ON D.DeterminationID = TMD.DeterminationID
			JOIN 
			(
				SELECT T2.MaterialKey, T2.[Plant name], T2.[GID], T2.lotNr, T2.[E-number],T2.MasterNr
				FROM
				(
					SELECT 
						R.MaterialKey,
						C2.ColumLabel,
						CellValue = C.[Value]
					FROM [Cell] C
					JOIN [Column] C2 ON C2.ColumnID = C.ColumnID
					JOIN [Row] R ON R.RowID = C.RowID
					JOIN [File] F ON F.FileID = R.FileID
					JOIN Test T ON T.FileID = F.FileID
					WHERE C2.ColumLabel IN('Plant name','GID', 'lotNr', 'E-number', 'MasterNr')
					AND T.TestID = @TestID
				) T1
				PIVOT
				(
					Max(CellValue)
					FOR [ColumLabel] IN ([Plant name], [GID], [lotNr],[E-number],[MasterNr])
				) T2

			) PT ON PT.MaterialKey = M.MaterialKey 
		
			WHERE T.TestID = @TestID AND TMD.TestID = @TestID AND TM.TestID = @TestID
	END
END