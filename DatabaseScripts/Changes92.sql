USE [Indico]
GO

DECLARE @Page AS int
DECLARE @Parent AS int
DECLARE @ParentPage AS int 
DECLARE @Position AS int
DECLARE @MenuItem AS int
DECLARE @Role AS int


INSERT INTO [Indico].[dbo].[Page] ([Name], [Title], [Heading]) VALUES ('/ViewCompareGramentSpec.aspx', 'Compare Garment Specifications', 'Compare Garment Specifications')


SET @page = SCOPE_IDENTITY()

SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPatterns.aspx')  
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @Position = (SELECT MAX([Position])+1 FROM [dbo].[MenuItem] WHERE [Parent] = @Parent)

INSERT INTO [Indico].[dbo].[MenuItem] ([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible])
     VALUES
           (@page, 'Compare Garment Specifications', 'Compare Garment Specifications', 1, @Parent, @Position, 0)


SET @MenuItem = SCOPE_IDENTITY()

SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')


INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @Role)
GO


