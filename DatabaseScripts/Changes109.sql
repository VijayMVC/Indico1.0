USE [Indico]
GO

--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

ALTER TABLE [dbo].[Pattern]
ADD [SMV] decimal(8,2) NULL
GO

--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**


DECLARE @Pattern AS int
DECLARE @SMV AS decimal(8,2)
DECLARE ChangeCostSheetCursor CURSOR FAST_FORWARD FOR 
SELECT cs.[Pattern]      
      ,ISNULL(cs.[SMV], 0.00) AS SMV      
 FROM [dbo].[CostSheet] cs
	JOIN [dbo].[Pattern] p
		ON cs.[Pattern] = p.[ID]
  
OPEN ChangeCostSheetCursor 
	FETCH NEXT FROM ChangeCostSheetCursor INTO @Pattern, @SMV
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
		UPDATE [dbo].[Pattern] SET [SMV] = @SMV WHERE [ID] = @Pattern
	
		FETCH NEXT FROM ChangeCostSheetCursor INTO @Pattern, @SMV
	END 

CLOSE ChangeCostSheetCursor 
DEALLOCATE ChangeCostSheetCursor		
GO
--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**
ALTER TABLE [dbo].[CostSheet]
DROP COLUMN [SMV]
GO
--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

ALTER TABLE [dbo].[Size]
ADD [IsDefault] [bit] NULL
GO

UPDATE [dbo].[Size] SET [IsDefault] = 1
GO

ALTER TABLE [dbo].[Size] 
ALTER COLUMN [IsDefault] [bit] NOT NULL
GO

--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**
ALTER TABLE [dbo].[MeasurementLocation]
ADD [IsSend] [bit] NULL
GO

UPDATE [dbo].[MeasurementLocation] SET [IsSend] = 1
GO

--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**

UPDATE [dbo].[Order] SET [DespatchToExistingClient] = 22 WHERE [ID] = 12749
GO

--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**--**-**-**
