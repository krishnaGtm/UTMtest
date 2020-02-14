DECLARE @TBL TABLE(grp NVARCHAR(MAX),CropCode NVARCHAR(MAX),Recipients NVARCHAR(MAX));

INSERT INTO @TBL(grp,CropCode,Recipients)
VALUES
('CREATE_DH0_DH1_DATA_ERROR','*','')

  MERGE INTO EmailConfig T
  USING
  @TBL S
  ON T.ConfigGroup = S.grp
  WHEN NOT MATCHED
  THEN INSERT (ConfigGroup,CropCode,Recipients)
  VALUES(S.grp,S.CropCode,S.Recipients);