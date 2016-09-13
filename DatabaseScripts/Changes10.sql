DECLARE @MPageID int
DECLARE @PageID int
DECLARE @MenuItem int
DECLARE @RoleID int
DECLARE @ParentID int

SET @MPageID = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/EditIndimanPrice.aspx')
SET @ParentID = (SELECT [ID] FROM [dbo].[MenuItem] WHERE  [Page] = @MPageID AND [Parent] IS NULL)
SET @PageID = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPriceLists.aspx')  
INSERT INTO [dbo].[MenuItem] ([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible])
VALUES(@PageID,'Download To Excel', 'Download To Excel', 1, @ParentID, 8, 1)

SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @PageID AND [Parent] = @ParentID)
SET @RoleID = (SELECT [ID] FROM [dbo].[Role] WHERE [Description]  = 'Indiman Administrator') 
INSERT INTO [dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @RoleID)  
GO