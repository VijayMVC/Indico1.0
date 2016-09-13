USE [Indico]
GO

--- Indico Administrator
DECLARE @Role AS int
DECLARE @Page AS int
DECLARE @MenuItem AS int
DECLARE @ParentMenuItem AS int

SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')
SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewQuotes.aspx')
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NULL) 

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
VALUES(
		@MenuItem,
		@Role
	  )
GO

DECLARE @Role AS int
DECLARE @Page AS int
DECLARE @MenuItem AS int
DECLARE @ParentMenuItem AS int

SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')
SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewQuotes.aspx')
SET @ParentMenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NULL) 
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @ParentMenuItem)

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
VALUES(
		@MenuItem,
		@Role
	  )
GO

DECLARE @Role AS int
DECLARE @MainPage AS int
DECLARE @Page AS int
DECLARE @MenuItem AS int
DECLARE @ParentMenuItem AS int


SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')
SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/AddEditQuote.aspx')
SET @MainPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewQuotes.aspx')
SET @ParentMenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @MainPage AND [Parent] IS NOT NULL) 
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @ParentMenuItem)

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
VALUES(
		@MenuItem,
		@Role
	  )
GO
