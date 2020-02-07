DECLARE @PlateTypeID INT =1, @TestTypeID INT =1,@WellTypeID INT =1;

SELECT @PlateTypeID = PlateTypeID FROM PlateType;

SELECT @WellTypeID = WellTypeID FROM WellType WHERE WellTypeName= 'B';


INSERT INTO TestType([TestTypeID], [TestTypeCode], [TestTypeName], [Status], [DeterminationRequired], [RemarkRequired], [PlateTypeID])
VALUES(3,'CH','Chips','ACT',1,1,@PlateTypeID);

SELECT @TestTypeID =TestTypeID FROM TestType WHERE TestTypeCode = 'CH';

INSERT INTO WellTypePosition([WellTypeID], [TestTypeID], [PositionOnPlate], [PlateInTest])
VALUES (@WellTypeID,@TestTypeID,'H12',1);