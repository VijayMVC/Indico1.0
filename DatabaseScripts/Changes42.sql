USE [Indico]
GO

DECLARE @PAGEID AS int

SET @PAGEID = (SELECT [ID] FROM [dbo].[Page] WHERE [Name]='/ViewAccessoryCategories.aspx')

UPDATE [dbo].[Page] SET [Heading] ='Accessories' WHERE [ID] = @PAGEID
GO

DECLARE @PAGEID AS int

SET @PAGEID = (SELECT [ID] FROM [dbo].[Page] WHERE [Name]='/ViewAccessoryColors.aspx')

UPDATE [dbo].[Page] SET [Heading] = 'Accessory Colors' WHERE [ID] = @PAGEID
GO

DECLARE @PAGEID AS int
DECLARE @MENUITEM AS int

SET @PAGEID = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewAccessories.aspx')
SET @MENUITEM = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @PAGEID)

UPDATE [dbo].[MenuItem] SET [Name] = 'Accessory Categories' WHERE [ID] = @MENUITEM
GO

DECLARE @PAGEID AS int
DECLARE @MENUITEM AS int

SET @PAGEID = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewAccessoryCategories.aspx')
SET @MENUITEM = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @PAGEID)

UPDATE [dbo].[MenuItem] SET [Name] = 'Accessories' WHERE [ID] = @MENUITEM
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--** Change the VL Number's last character--**--**--**--**--**--**--**--**--**--**--**--**

DECLARE @ID AS int
DECLARE @NamePrefix AS nvarchar(64)

DECLARE VLCursor CURSOR FAST_FORWARD FOR 
SELECT [ID]      
      ,[NamePrefix]     
FROM [dbo].[Visuallayout]

OPEN VLCursor 
 FETCH NEXT FROM VLCursor INTO @ID, @NamePrefix 
 WHILE @@FETCH_STATUS = 0 
 BEGIN  
  SET @NamePrefix = REPLACE(@NamePrefix, 'VL', '')
  
  IF (LEN(@NamePrefix) > 5)
   SET @NamePrefix = SUBSTRING(@NamePrefix, 0, 5)
   
  UPDATE [dbo].[Visuallayout]
   SET [NamePrefix] = 'VL' + @NamePrefix
  FROM [dbo].[Visuallayout]
  WHERE [ID] = @ID
   
  Print @NamePrefix
  FETCH NEXT FROM VLCursor INTO @ID, @NamePrefix
 END 
 
CLOSE VLCursor 
DEALLOCATE VLCursor
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**