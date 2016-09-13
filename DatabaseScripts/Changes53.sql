USE [Indico]
GO


DECLARE @Page AS int
DECLARE @Menuitem As int
DECLARE @Role AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewFabricCodes.aspx')
SET @Menuitem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NOT NULL)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Factory Administrator')


INSERT INTO [Indico].[dbo].[MenuItemRole]
           ([MenuItem]
           ,[Role])
     VALUES
           (@Menuitem
           ,@Role)
GO


DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @Parent AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/AddPatternFabricPrice.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPrices.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)


UPDATE [dbo].[MenuItem] SET [IsVisible] = 1 WHERE [Page] = @Page AND [Parent] = @Parent

