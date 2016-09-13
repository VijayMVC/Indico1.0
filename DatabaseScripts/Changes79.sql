USE [Indico]
GO

DECLARE @Page AS int 
DECLARE @Parent AS int
DECLARE @MenuItem AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewEmbroideries.aspx')

SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)

UPDATE [dbo].[MenuItem] SET [Name] = 'Embroideries', [Description] = 'Embroideries' WHERE [ID] = @Parent

UPDATE [dbo].[MenuItem] SET [Name] = 'Embroideries', [Description] = 'Embroideries' WHERE [ID] = @MenuItem
GO   

--***-***-**--***-***-**--***-***-**--***-***-**--***-***-**--***-***-**--***-***-**--***-***-**--***-***-**--***-***-**--***-***-**--***-***-**--***-***-**
DECLARE @Page AS int 
DECLARE @Position AS int
DECLARE @Parent AS int
DECLARE @RoleIndiman AS int
DECLARE @RoleFactory AS int
DECLARE @MenuItem AS int 
DECLARE @ParentPage AS int

INSERT INTO [Indico].[dbo].[Page]([Name], [Title], [Heading]) VALUES ('/AddEditEmbroidery.aspx', 'Embroidery', 'Embroidery')

SET @Page = SCOPE_IDENTITY()



SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewEmbroideries.aspx')
SET @RoleIndiman = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')
SET @RoleFactory = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Factory Administrator')

SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)

SET @Position = (SELECT Max([Position]) + 1 FROM [dbo].[MenuItem] WHERE [Parent] = @Parent AND [Page] = @ParentPage)


INSERT INTO [Indico].[dbo].[MenuItem]([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible]) VALUES(@Page, 'Embroidery', 'Embroidery', 1, @Parent, 1, 0)

SET @MenuItem = SCOPE_IDENTITY()


INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem , @RoleIndiman)


INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem , @RoleFactory)
GO
