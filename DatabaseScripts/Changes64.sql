USE [Indico]
GO

DECLARE @ID AS int
DECLARE @Pattern AS int
DECLARE @Fabric AS int


DECLARE CostSheetCursor CURSOR FAST_FORWARD FOR
 
SELECT [ID]
      ,[Pattern]
      ,[Fabric]      
  FROM [Indico].[dbo].[CostSheet]
  --where id = 427
  
OPEN CostSheetCursor 
	FETCH NEXT FROM CostSheetCursor INTO @ID, @Pattern, @Fabric
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
	
			IF (NOT EXISTS(SELECT [ID] FROM [dbo].[PatternSupportFabric]  WHERE [CostSheet] = @ID AND [Fabric] = @Fabric))
			BEGIN
				
				INSERT INTO [Indico].[dbo].[PatternSupportFabric]
					   ([Fabric], [FabConstant], [CostSheet]) VALUES(@Fabric ,0.00 ,@ID)
					   PRINT @ID
					   --PRINT @Fabric
					   --PRINT '------------------------'
				
			END
		FETCH NEXT FROM CostSheetCursor INTO  @ID, @Pattern, @Fabric
	END
CLOSE CostSheetCursor 
DEALLOCATE CostSheetCursor
-----/--------
GO