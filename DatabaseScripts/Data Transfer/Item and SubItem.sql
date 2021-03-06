USE [Indico] 
GO
--**----**----**----**----**----**----** INSERT ITEM --**----**----**----**----**----**----**

DECLARE @ItemID AS NVARCHAR(255)

DECLARE InsertItem CURSOR FAST_FORWARD FOR 
SELECT pii.[ItemID]       
FROM [Product].[dbo].[Item] pii
WHERE NOT EXISTS (
				  SELECT ii.[Name] 
				  FROM [dbo].[Item] ii 
				  WHERE ii.[Name] = pii.[ItemID]  AND ii.[Parent] IS NULL
				  )
				  
OPEN InsertItem 
	FETCH NEXT FROM InsertItem INTO @ItemID
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		
		INSERT INTO [dbo].[Item] ([Name], [Description], [Parent] )
		VALUES (
				@ItemID,
				@ItemID,
				NULL
			   )	
		FETCH NEXT FROM InsertItem INTO @ItemID
	END 

CLOSE InsertItem 
DEALLOCATE InsertItem	

GO

--**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**--

--**----**----**----**----**----**----** INSERT ITEMATTRIBUTE --**----**----**----**----**----**----**

DECLARE @Itemsubcat AS NVARCHAR(255)
DECLARE @ItemID AS NVARCHAR(255)
DECLARE @Parent AS int

DECLARE InsertItemAttribute CURSOR FAST_FORWARD FOR 
SELECT pii.[Itemsubcat], 
	   pii.[ItemID ]   
FROM [Product].[dbo].[Itemsubcat] pii 
WHERE NOT EXISTS (
				  SELECT ii.[Name] 
				  FROM [dbo].[Item] ii 
				  WHERE ii.[Name] = pii.[Itemsubcat]  AND ii.[Parent] IS NOT NULL
				  )
		
OPEN InsertItemAttribute 
	FETCH NEXT FROM InsertItemAttribute INTO @Itemsubcat, @ItemID
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		BEGIN TRY 
			SET @Parent = (SELECT [ID] FROM [dbo].[Item]  WHERE [Name] = @ItemID AND [Parent] IS NULL)
			 
			INSERT INTO [dbo].[Item] ([Name], [Description], [Parent])
			VALUES (
					@Itemsubcat,
					@Itemsubcat,
					@Parent
				   )	
		END TRY
		BEGIN CATCH
		
		PRINT @ItemID
		
		END CATCH
		FETCH NEXT FROM InsertItemAttribute INTO @Itemsubcat, @ItemID
	END 

CLOSE InsertItemAttribute 
DEALLOCATE InsertItemAttribute	

GO
--**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**--	

--**----**----**----**----**----**----** UPDATE ITEMATTRIBUTE --**----**----**----**----**----**----**


DECLARE @Itemsubcat AS NVARCHAR(255)
DECLARE @ItemID AS NVARCHAR(255)
DECLARE @Parent AS int

DECLARE UpdateItemAttribute CURSOR FAST_FORWARD FOR 
SELECT pii.[Itemsubcat], 
	   pii.[ItemID ]     
FROM [Product].[dbo].[Itemsubcat] pii 
WHERE NOT EXISTS (
				  SELECT ii.[Name] 
				  FROM [dbo].[Item] ii 
				  WHERE ii.[Name] = pii.[ItemID]  AND ii.[Parent] IS NOT NULL
				  )
				  
OPEN UpdateItemAttribute 
	FETCH NEXT FROM UpdateItemAttribute INTO @Itemsubcat, @ItemID
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		BEGIN TRY 
			SET @Parent = (SELECT [ID] FROM [dbo].[Item]  WHERE [Name] = @ItemID AND [Parent] IS NULL)
			 
			UPDATE [dbo].[Item] SET [Parent] = @Parent WHERE [Parent] IS NOT NULL AND [Name] = @Itemsubcat 
			
		END TRY
		BEGIN CATCH
		
		PRINT @ItemID
		
		END CATCH
		FETCH NEXT FROM UpdateItemAttribute INTO @Itemsubcat, @ItemID
	END 

CLOSE UpdateItemAttribute 
DEALLOCATE UpdateItemAttribute	

GO
--**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**--	