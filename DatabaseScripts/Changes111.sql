USE [Indico]
GO


DECLARE @User AS int
DECLARE @Role AS int

SET @User = (SELECT [ID] FROM [dbo].[User] WHERE [Username] = 'Senanayake')

SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Factory Administrator')


UPDATE [dbo].[UserRole] SET [Role]= @Role WHERE [User] = @User
GO

--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***


DECLARE @Page AS int
DECLARE @MenuItem AS int 
DECLARE @Parent AS int
DECLARE @Role AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewReservations.aspx')

SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Factory Administrator')

SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NULL)

INSERT INTO [dbo].[MenuItemRole]  ([MenuItem], [Role])  VALUES (@MenuItem, @Role)
GO

--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***

DECLARE @Page AS int
DECLARE @MenuItem AS int 
DECLARE @Parent AS int
DECLARE @Role AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewReservations.aspx')

SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Factory Administrator')

SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NULL)

SET @MenuItem  = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Parent] = @Parent)

INSERT INTO [dbo].[MenuItemRole]  ([MenuItem], [Role])  VALUES (@MenuItem, @Role)
GO
--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***
DECLARE @Page AS int
DECLARE @MenuItem AS int 
DECLARE @Parent AS int
DECLARE @Role AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewVisualLayouts.aspx')

SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Factory Administrator')

SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NULL)

INSERT INTO [dbo].[MenuItemRole]  ([MenuItem], [Role])  VALUES (@MenuItem, @Role)
GO

--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***

DECLARE @Page AS int
DECLARE @MenuItem AS int 
DECLARE @Parent AS int
DECLARE @Role AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewVisualLayouts.aspx')

SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Factory Administrator')

SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NULL)

SET @MenuItem  = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Parent] = @Parent)

INSERT INTO [dbo].[MenuItemRole]  ([MenuItem], [Role])  VALUES (@MenuItem, @Role)
GO
--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***--*-**-***
