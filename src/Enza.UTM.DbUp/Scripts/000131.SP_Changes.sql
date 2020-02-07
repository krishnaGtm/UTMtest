

DECLARE @StatusID INT;
IF NOT EXISTS(SELECT * FROM [Status] WHERE StatusTable = 'Test' AND StatusCode = 625) BEGIN

	SELECT @StatusID = MAX(StatusID) +1 FROM [Status];
	INSERT INTO [Status](StatusID,StatusTable,StatusCode,StatusName,StatusDescription)
	VALUES(@StatusID,'Test',625,'InvalidConversion','Conversion is missing to sync data')

END


IF NOT EXISTS(SELECT * FROM [Status] WHERE StatusTable = 'Test' AND StatusCode = 650) BEGIN

	SELECT @StatusID = MAX(StatusID) +1 FROM [Status];
	INSERT INTO [Status](StatusID,StatusTable,StatusCode,StatusName,StatusDescription)
	VALUES(@StatusID,'Test',650,'ReadyToSync','Ready to syncronize data to source')

END

GO