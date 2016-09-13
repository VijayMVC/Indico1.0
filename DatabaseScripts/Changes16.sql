
DELETE SizeChart 
FROM SizeChart sc
	JOIN MeasurementLocation ml
		ON sc.MeasurementLocation = ml.ID
WHERE ml.ID IN 	(169, 170)	

DELETE MeasurementLocation
WHERE ID IN (169, 170)

UPDATE MeasurementLocation
	SET [Key] = 'G'
FROM MeasurementLocation
WHERE ID IN (102, 106) 

UPDATE MeasurementLocation
	SET [Key] = 'F'
FROM MeasurementLocation
WHERE ID = 103

UPDATE MeasurementLocation
	SET [Key] = 'E'
FROM MeasurementLocation
WHERE ID = 98

UPDATE MeasurementLocation
	SET [Key] = 'D'
FROM MeasurementLocation
WHERE ID = 104
GO


DECLARE @ID AS int
DECLARE @Pattern AS int
DECLARE @MeasurementLocation AS INT 
DECLARE @TempPatItemId as int
DECLARE @TempMLItemId as int
DECLARE @TempMLName as nvarchar(255)
DECLARE @TempMLId as int
DECLARE SizeChartCursor CURSOR FAST_FORWARD FOR 
		SELECT ID, Pattern, MeasurementLocation
		FROM SizeChart 
OPEN SizeChartCursor 
	FETCH NEXT FROM SizeChartCursor INTO @ID, @Pattern, @MeasurementLocation 
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		SELECT @TempPatItemId = Item FROM Pattern WHERE ID = @Pattern
		SELECT @TempMLItemId = Item FROM MeasurementLocation WHERE ID = @MeasurementLocation
		SELECT @TempMLName = Name FROM MeasurementLocation WHERE ID = @MeasurementLocation
		BEGIN TRY		
		IF (@TempPatItemId != @TempMLItemId)
			BEGIN
				SELECT @TempMLId = ID FROM MeasurementLocation WHERE Item = @TempPatItemId AND [Name] = @TempMLName
				IF (@TempMLId IS NOT NULL)
				BEGIN
					UPDATE SizeChart 
						SET MeasurementLocation = @TempMLId
					FROM SizeChart 
					WHERE Pattern = @Pattern AND MeasurementLocation = @MeasurementLocation
				END
				ELSE
				BEGIN	
					DELETE SizeChart 
					FROM SizeChart 
					WHERE ID = @ID
				END
			END
		END TRY
		BEGIN CATCH		
			PRINT @TempPatItemId
			PRINT @TempMLItemId
			PRINT @ID
			PRINT @Pattern
			PRINT @MeasurementLocation 
			PRINT @TempMLName
		END	CATCH
		
		FETCH NEXT FROM SizeChartCursor INTO @ID, @Pattern, @MeasurementLocation
	END 

CLOSE SizeChartCursor 
DEALLOCATE SizeChartCursor	

GO



