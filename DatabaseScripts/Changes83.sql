USE [Indico]
GO


--**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-** Add New Page and menuItem Role for ViewEmbroideryStatus  --**-**-**-**--**-**-**-**--**-**-**-**--**-**-**-**

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @Parent AS int
DECLARE @Position AS int
DECLARE @MenuItem AS int
DECLARE @Role AS int 

INSERT INTO [Indico].[dbo].[Page] ([Name], [Title], [Heading]) VALUES ('/ViewEmbroideryStatus.aspx' ,'Ebroidery Status', 'Ebroidery Status')

SET @Page = (SCOPE_IDENTITY())

SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewAgeGroups.aspx')

SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)

SET @Position = (SELECT MAX([Position])+1 FROM [dbo].[MenuItem] WHERE [Parent] = @Parent)

INSERT INTO [Indico].[dbo].[MenuItem] ([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible])
   VALUES (@Page ,'Ebroidery Status' ,'Ebroidery Status', 1, @Parent, @Position, 1)

SET @MenuItem = (SCOPE_IDENTITY())


SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')

INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @Role)
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
