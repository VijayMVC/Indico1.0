USE [Indico]
GO

DECLARE @ID AS int
DECLARE @Name AS nvarchar(255) 
DECLARE @UserID AS int
SET @UserID = 0
DECLARE DistributorUser CURSOR FAST_FORWARD FOR 
SELECT [ID]
	   ,[Name]
FROM [dbo].[Company]
WHERE [IsDistributor] = 1
ORDER BY [Name]
OPEN DistributorUser 
	FETCH NEXT FROM DistributorUser INTO @ID, @Name
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
			IF(NOT EXISTS(SELECT [ID] FROM [dbo].[User] WHERE [Company] = @ID AND [IsActive] = 1 AND [IsDeleted] = 0))
				BEGIN
					BEGIN TRY
							INSERT INTO [Indico].[dbo].[User]
							   ([Company]
							   ,[IsDistributor]
							   ,[Status]
							   ,[Username]
							   ,[Password]
							   ,[GivenName]
							   ,[FamilyName]
							   ,[EmailAddress]
							   ,[PhotoPath]
							   ,[Creator]
							   ,[CreatedDate]
							   ,[Modifier]
							   ,[ModifiedDate]
							   ,[IsActive]
							   ,[IsDeleted]
							   ,[Guid]
							   ,[OfficeTelephoneNumber]
							   ,[MobileTelephoneNumber]
							   ,[HomeTelephoneNumber]
							   ,[DateLastLogin]
							   ,[HaveAccessForHTTPPost])
						 VALUES
							   (@ID
							   ,1
							   ,1
							   ,'admin_'+ CONVERT(NVARCHAR(255),@ID)
							   ,CONVERT(varchar(255), HashBytes('SHA1', 'password'))
							   ,'Test'
							   ,'User'
							   ,'noreply@indico.com'
							   ,NULL
							   ,1
							   ,GETDATE()
							   ,1
							   ,GETDATE()
							   ,1
							   ,0
							   , NEWID()
							   ,''
							   ,'+61 111 1112'
							   ,NULL
							   ,GETDATE()
							   ,0)
							   
						SET @UserID = SCOPE_IDENTITY()
							   
						INSERT INTO [Indico].[dbo].[UserRole]
							   ([User]
							   ,[Role])
						VALUES
							   (@UserID
							   ,10)
							   							  							   
						UPDATE [dbo].[Company] SET [Owner] = @UserID WHERE [ID] = @ID
						
						PRINT @Name
						
					END TRY
					BEGIN CATCH
						PRINT @@ERROR + 'Error occured while inserting distributor user to to User Table'
						PRINT @Name
						PRINT @ID
					END CATCH
				END
	
		FETCH NEXT FROM DistributorUser INTO @ID, @Name
	END 
CLOSE DistributorUser 
DEALLOCATE DistributorUser		
GO
--**-**--**----**-**--**----**-**--**-- Update SizeChart Where Pattern Number = 1113 --**-**--**----**-**--**----**-**--**----**-**--**--
DECLARE @ID AS int
DECLARE @MeasurementLocation AS int
DECLARE @Pattern AS int
DECLARE @SizeSet AS int
DECLARE @Size AS int
DECLARE @SizeID AS int
SET @SizeID = 0;

SET @Pattern = (SELECT [ID] FROM [dbo].[Pattern] WHERE [Number] = '1113')
SET @SizeSet = (SELECT [SizeSet] FROM [dbo].[Pattern] WHERE [Number] = '1113')

DECLARE MeasurementLocationCursor CURSOR FAST_FORWARD FOR 
SELECT DISTINCT sc.[MeasurementLocation]     
FROM [dbo].[SizeChart] sc
WHERE [Pattern] = @Pattern
OPEN MeasurementLocationCursor 
	FETCH NEXT FROM MeasurementLocationCursor INTO @MeasurementLocation 
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		BEGIN TRY
		
			DECLARE @NewSize TABLE (
			[SizeChart] [int] NULL,
			[Size] [int] NULL)
		
				DECLARE SizeChartCursor CURSOR FAST_FORWARD FOR 
				SELECT ssc.[ID], 					  
					   ssc.[Size]     
				FROM [dbo].[SizeChart] ssc
				WHERE [Pattern] = @Pattern 
				AND ssc.[MeasurementLocation] = @MeasurementLocation
				
				OPEN SizeChartCursor 
				
					FETCH NEXT FROM SizeChartCursor INTO @ID, @Size
					WHILE @@FETCH_STATUS = 0 
					BEGIN 
					
					SET @SizeID = (SELECT [ID] FROM [dbo].[Size] WHERE [SizeSet] = @SizeSet AND [SizeName] = (SELECT [SizeName] FROM [dbo].[Size] WHERE [ID] = @Size ) )
					
					INSERT INTO @NewSize ([SizeChart], [Size]) VALUES (@ID, @SizeID)
					
						FETCH NEXT FROM SizeChartCursor INTO @ID, @Size
					END 

				CLOSE SizeChartCursor 
				DEALLOCATE SizeChartCursor
				
				DECLARE @SCID AS int
				DECLARE @SID AS int
				
				DECLARE NewCursor CURSOR FAST_FORWARD FOR 
				SELECT [SizeChart], 
					   [Size]					   
				FROM @NewSize			
				OPEN NewCursor 
				
					FETCH NEXT FROM NewCursor INTO @SCID, @SID
					WHILE @@FETCH_STATUS = 0 
					BEGIN 
					
						UPDATE [dbo].[SizeChart] SET [Size] = @SID WHERE [ID] = @SCID
					
					
						FETCH NEXT FROM NewCursor INTO  @SCID, @SID
					END 

				CLOSE NewCursor 
				DEALLOCATE NewCursor
		
		END TRY
		BEGIN CATCH
		
			PRINT CONVERT(NVARCHAR(255),@@ERROR) + 'Error'
		
		END CATCH
		

		FETCH NEXT FROM MeasurementLocationCursor INTO @MeasurementLocation 
	END 

CLOSE MeasurementLocationCursor 
DEALLOCATE MeasurementLocationCursor		
-----/--------
GO