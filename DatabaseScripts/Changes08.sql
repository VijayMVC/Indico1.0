USE Indico
GO
--**--**----**--**----**--**----**--**----**--**----**--**----**--**----**--**----**--**--

--Create New Table DefaultValuesPriceList--
CREATE TABLE DefaultValuesPriceList
(
ID INT IDENTITY(1,1) NOT NULL CONSTRAINT pk_defaultvalues_dvid PRIMARY KEY,
CreativeDesign   INT NOT NULL,
StudioDesign     INT NOT NULL,
ThirdPartyDesign INT NOT NULL,
Position1		 INT NOT NULL,
Position2		 INT NOT NULL,
Position3		 INT NOT NULL,
Creator          INT NOT NULL FOREIGN KEY(Creator)REFERENCES [dbo].[User] ([ID]),
CreatedDate      DATETIME2(7) NOT NULL,
Modifier		 INT NOT NULL FOREIGN KEY(Modifier)REFERENCES [dbo].[User] ([ID]),
ModifiedDate	 DATETIME2(7)NOT NULL
)
GO
--**--**----**--**----**--**----**--**----**--**----**--**----**--**----**--**----**--**--

DECLARE @PAGEID INT
DECLARE @MenuItemID INT
DECLARE @RoleID INT

SET @PAGEID = (SELECT ID FROM [dbo].[Page] WHERE [Name] = '/PriceList.aspx')  
UPDATE [dbo].[Page] SET Name ='/AddPriceList.aspx' WHERE [ID] = @PAGEID

INSERT INTO [dbo].[Page] ([Name],[Title],[Heading]) 
VALUES ('/ViewPriceLists.aspx', 'Price Lists', 'Price Lists')
SET @PAGEID = SCOPE_IDENTITY()

SET @MenuItemID = (SELECT ID FROM [dbo].[MenuItem] WHERE [Name] = 'DownLoad To Excel') 
UPDATE [dbo].[MenuItem] SET [Page] = @PAGEID WHERE [ID] = @MenuItemID

SET @PAGEID = (SELECT ID FROM [dbo].[Page] WHERE Name = '/AddPriceList.aspx')

INSERT INTO [dbo].[MenuItem] ([Page],[Name], [Description], [IsActive], [Parent], [Position], [IsVisible])
VALUES(@PAGEID, 'Price List', 'Price List', 1, @MenuItemID, 3, 0)
SET @MenuItemID = SCOPE_IDENTITY()

SET @RoleID = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] ='Indico Administrator')
INSERT INTO [dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItemID, @RoleID)

GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
 
DECLARE @PageID INT
DECLARE @RoleID INT
DECLARE @MenuItemLevel1 INT
DECLARE @MenuItemLevel2 INT
DECLARE @MenuItemLevel3 INT

SET @RoleID = (SELECT [ID]  FROM [dbo].[Role] WHERE [Description] = 'Indico Coordinator')

--Add Orders Tab--
SET @PageID = (SELECT [ID]FROM [dbo].[Page] WHERE [Name] ='/ViewOrders.aspx')

SET @MenuItemLevel1 = (SELECT [ID]  FROM [dbo].[MenuItem]   WHERE [Page] = @PageID  AND [Parent] IS NULL)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem], [Role] ) VALUES(@MenuItemLevel1, @RoleID)

SET @MenuItemLevel2 = (SELECT [ID]  FROM [dbo].[MenuItem]   WHERE [Page] = @PageID  AND [Parent] = @MenuItemLevel1)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem], [Role] ) VALUES(@MenuItemLevel2, @RoleID)

SET @PageID = (SELECT [ID]FROM [dbo].[Page] WHERE [Name] ='/AddEditOrder.aspx')

SET @MenuItemLevel3 = (SELECT [ID]  FROM [dbo].[MenuItem]   WHERE [Page] = @PageID  AND [Parent] = @MenuItemLevel2)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem], [Role] ) VALUES(@MenuItemLevel3, @RoleID)
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--Add Pattern Tab--
SET @PageID = (SELECT ID FROM [dbo].[Page] WHERE [Name] = '/EditIndicoPrice.aspx')

SET @MenuItemLevel1 = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @PageID AND [Parent] IS NULL)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem], [Role] ) VALUES(@MenuItemLevel1, @RoleID)

SET @MenuItemLevel2 = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @PageID AND [Parent] = @MenuItemLevel1)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem], [Role] ) VALUES(@MenuItemLevel2, @RoleID)

SET @PageID = (SELECT ID FROM [dbo].[Page] WHERE [Name] = '/ViewPriceMarckups.aspx')

SET @MenuItemLevel2 = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @PageID AND [Parent] = @MenuItemLevel1)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem], [Role] ) VALUES(@MenuItemLevel2, @RoleID)

SET @PageID = (SELECT ID FROM [dbo].[Page] WHERE [Name] = '/ViewPriceLists.aspx')

SET @MenuItemLevel2 = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @PageID AND [Parent] = @MenuItemLevel1)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem], [Role] ) VALUES(@MenuItemLevel2, @RoleID)
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--Remove Maser Data Tab--
SET @PageID = (SELECT [ID]FROM [dbo].[Page] WHERE [Name] ='/ViewAgeGroups.aspx')

SET @MenuItemLevel1 = (SELECT [ID]  FROM [dbo].[MenuItem]   WHERE [Page] = @PageID  AND [Parent] IS NULL)
DELETE FROM [dbo].[MenuItemRole]	WHERE [MenuItem] = @MenuItemLevel1 AND [Role] = @RoleID

SET @MenuItemLevel2 = (SELECT [ID]  FROM [dbo].[MenuItem]   WHERE [Page] = @PageID  AND [Parent] = @MenuItemLevel1)
DELETE FROM [dbo].[MenuItemRole]	WHERE [MenuItem] = @MenuItemLevel2 AND [Role] = @RoleID

SET @PageID = (SELECT [ID]FROM [dbo].[Page] WHERE [Name] ='/ViewColorProfiles.aspx')

SET @MenuItemLevel2 = (SELECT [ID]  FROM [dbo].[MenuItem]   WHERE [Page] = @PageID  AND [Parent] = @MenuItemLevel1)
DELETE FROM [dbo].[MenuItemRole]	WHERE [MenuItem] = @MenuItemLevel2 AND [Role] = @RoleID

SET @PageID = (SELECT [ID]FROM [dbo].[Page] WHERE [Name] ='/ViewGender.aspx')

SET @MenuItemLevel2 = (SELECT [ID]  FROM [dbo].[MenuItem]   WHERE [Page] = @PageID  AND [Parent] = @MenuItemLevel1)
DELETE FROM [dbo].[MenuItemRole]	WHERE [MenuItem] = @MenuItemLevel2 AND [Role] = @RoleID

SET @PageID = (SELECT [ID]FROM [dbo].[Page] WHERE [Name] ='/ViewPrinters.aspx')

SET @MenuItemLevel2 = (SELECT [ID]  FROM [dbo].[MenuItem]   WHERE [Page] = @PageID  AND [Parent] = @MenuItemLevel1)
DELETE FROM [dbo].[MenuItemRole]	WHERE [MenuItem] = @MenuItemLevel2 AND [Role] = @RoleID

SET @PageID = (SELECT [ID]FROM [dbo].[Page] WHERE [Name] ='/ViewPrinterTypes.aspx')

SET @MenuItemLevel2 = (SELECT [ID]  FROM [dbo].[MenuItem]   WHERE [Page] = @PageID  AND [Parent] = @MenuItemLevel1)
DELETE FROM [dbo].[MenuItemRole]	WHERE [MenuItem] = @MenuItemLevel2 AND [Role] = @RoleID

SET @PageID = (SELECT [ID]FROM [dbo].[Page] WHERE [Name] ='/ViewProductionLines.aspx')

SET @MenuItemLevel2 = (SELECT [ID]  FROM [dbo].[MenuItem]   WHERE [Page] = @PageID  AND [Parent] = @MenuItemLevel1)
DELETE FROM [dbo].[MenuItemRole]	WHERE [MenuItem] = @MenuItemLevel2 AND [Role] = @RoleID

SET @PageID = (SELECT [ID]FROM [dbo].[Page] WHERE [Name] ='/ViewResolutionProfiles.aspx')

SET @MenuItemLevel2 = (SELECT [ID]  FROM [dbo].[MenuItem]   WHERE [Page] = @PageID  AND [Parent] = @MenuItemLevel1)
DELETE FROM [dbo].[MenuItemRole]	WHERE [MenuItem] = @MenuItemLevel2 AND [Role] = @RoleID

SET @PageID = (SELECT [ID]FROM [dbo].[Page] WHERE [Name] ='/ViewSizes.aspx')

SET @MenuItemLevel2 = (SELECT [ID]  FROM [dbo].[MenuItem]   WHERE [Page] = @PageID  AND [Parent] = @MenuItemLevel1)
DELETE FROM [dbo].[MenuItemRole]	WHERE [MenuItem] = @MenuItemLevel2 AND [Role] = @RoleID

SET @PageID = (SELECT [ID]FROM [dbo].[Page] WHERE [Name] ='/ViewSizeSets.aspx')

SET @MenuItemLevel2 = (SELECT [ID]  FROM [dbo].[MenuItem]   WHERE [Page] = @PageID  AND [Parent] = @MenuItemLevel1)
DELETE FROM [dbo].[MenuItemRole]	WHERE [MenuItem] = @MenuItemLevel2 AND [Role] = @RoleID
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
GO
