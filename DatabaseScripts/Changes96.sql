USE [Indico]
GO

DECLARE @Page AS int
DECLARE @Parent AS int
DECLARE @MenuItem AS int
DECLARE @Role AS int


SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewReservations.aspx')

SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NULL)

SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')

INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @Role)
GO


DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @Parent AS int
DECLARE @MenuItem AS int
DECLARE @ParentMenuItem AS int 
DECLARE @Role AS int


SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewReservations.aspx')

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/AddEditReservation.aspx')

SET @ParentMenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)

SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @ParentMenuItem)

SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')

INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @Role)
GO

