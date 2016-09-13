USE [Indico]
GO

---**--**--**---**--**--**---**--**--** ADD NEW MENUITEM DASHBOARD ---**--**--**---**--**--**---**--**--**---**--**--**
DECLARE @Page AS int
DECLARE @Role AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewProductionCapacities.aspx')
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')

INSERT INTO [Indico].[dbo].[MenuItem]
           ([Page]
           ,[Name]
           ,[Description]
           ,[IsActive]
           ,[Parent]
           ,[Position]
           ,[IsVisible])
     VALUES
           (@Page
           ,'Dashboard'
           ,'Dashboard'
           ,1
           ,NULL
           ,1
           ,1)
GO
---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**

---**--**--**---**--**--**---**--**--** GIVE PERMISION FOR INDIMAN ADMINISTRATORS ---**--**--**---**--**--**---**--**--**
DECLARE @MenuItem AS int 
DECLARE @Role AS int 
DECLARE @Page AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewProductionCapacities.aspx')
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NULL)

INSERT INTO [Indico].[dbo].[MenuItemRole]
           ([MenuItem]
           ,[Role])
     VALUES
           (@MenuItem
           ,@Role)
GO           
---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**  

---**--**--**---**--**--**---**--**--** GIVE SUB MENUITEM  FOR PRODUCTION CAPACITIES ---**--**--**---**--**--**          
DECLARE @Parent AS int 
DECLARE @Role AS int 
DECLARE @Page AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewProductionCapacities.aspx')
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NULL)         
           

INSERT INTO [Indico].[dbo].[MenuItem]
           ([Page]
           ,[Name]
           ,[Description]
           ,[IsActive]
           ,[Parent]
           ,[Position]
           ,[IsVisible])
     VALUES
           (@Page
           ,'Production Capacity'
           ,'Production Capacities'
           ,1
           ,@Parent
           ,1
           ,1)         
GO 

---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**

---**--**--**---**--**--**---**--**--** GIVE PERMISION FOR INDIMAN ADMINISTRTORS ---**--**--**---**--**--**---**--**--**

DECLARE @Parent AS int 
DECLARE @Role AS int 
DECLARE @Page AS int
DECLARE @MenuItem AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewProductionCapacities.aspx')
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NULL) 
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)  
 
INSERT INTO [Indico].[dbo].[MenuItemRole]
           ([MenuItem]
           ,[Role])
     VALUES
           (@MenuItem
           ,@Role)     
GO

---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**

---**--**--**---**--**--**---**--**--** ADD SUB MENUITEM FOR WEEKLY CAPACITIES ---**--**--**---**--**--**---**--**--**---**--**--**

DECLARE @Parent AS int 
DECLARE @Role AS int 
DECLARE @Page AS int
DECLARE @ParentPage AS int 

SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewProductionCapacities.aspx')
SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewWeeklyCapacities.aspx')
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)         
           

INSERT INTO [Indico].[dbo].[MenuItem]
           ([Page]
           ,[Name]
           ,[Description]
           ,[IsActive]
           ,[Parent]
           ,[Position]
           ,[IsVisible])
     VALUES
           (@Page
           ,'Weekly Capacities'
           ,'Weekly Capacities'
           ,1
           ,@Parent
           ,2
           ,1)         
GO 
---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**

---**--**--**---**--**--**---**--**--** GIVE PERMISION FOR INDIMAN ADMINISTRTORS ---**--**--**---**--**--**---**--**--**

DECLARE @Parent AS int 
DECLARE @Role AS int 
DECLARE @Page AS int
DECLARE @MenuItem AS int
DECLARE @ParentPage AS int 

SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewProductionCapacities.aspx')
SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewWeeklyCapacities.aspx')
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL) 
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)  
 
INSERT INTO [Indico].[dbo].[MenuItemRole]
           ([MenuItem]
           ,[Role])
     VALUES
           (@MenuItem
           ,@Role)     
  
  
GO
---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**

---**--**--**---**--**--**---**--**--** REMOVE PERMISION FOR INDIMAN ADMINISTRTORS PRODUCTIONCAPACITIES---**--**--**---**--**--**---**--**--**

DECLARE @Page AS int
DECLARE @Role AS int
DECLARE @ParentPage AS int
DECLARE @ParentMenuItem AS int 
DECLARE @MenuItem AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewProductionCapacities.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewOrders.aspx')
SET @ParentMenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @ParentMenuItem)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')

DELETE FROM [dbo].[MenuItemRole] WHERE [MenuItem] = @MenuItem AND [Role] = @Role
GO

---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**

---**--**--**---**--**--**---**--**--** REMOVE PERMISION FOR INDIMAN COORDINATOR PRODUCTIONCAPACITIES---**--**--**---**--**--**---**--**--**

DECLARE @Page AS int
DECLARE @Role AS int
DECLARE @ParentPage AS int
DECLARE @ParentMenuItem AS int 
DECLARE @MenuItem AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewProductionCapacities.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewOrders.aspx')
SET @ParentMenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @ParentMenuItem)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Coordinator')

DELETE FROM [dbo].[MenuItemRole] WHERE [MenuItem] = @MenuItem AND [Role] = @Role
GO

---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**

---**--**--**---**--**--**---**--**--** REMOVE MENUITEM PRODUCTIONCAPACITIES FROM ORDERS---**--**--**---**--**--**---**--**--**

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @ParentMenuItem AS int 
DECLARE @MenuItem AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewProductionCapacities.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewOrders.aspx')
SET @ParentMenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @ParentMenuItem)

DELETE FROM [dbo].[MEnuItem] WHERE [ID] = @MenuItem
GO
---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**

---**--**--**---**--**--**---**--**--** REMOVE PERMISION FOR INDIMAN ADMINISTRTORS WEEKLYCAPACITIES---**--**--**---**--**--**---**--**--**

DECLARE @Page AS int
DECLARE @Role AS int
DECLARE @ParentPage AS int
DECLARE @ParentMenuItem AS int 
DECLARE @MenuItem AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewWeeklyCapacities.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewOrders.aspx')
SET @ParentMenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @ParentMenuItem)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')

DELETE FROM [dbo].[MenuItemRole] WHERE [MenuItem] = @MenuItem AND [Role] = @Role
GO
---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**

---**--**--**---**--**--**---**--**--** REMOVE PERMISION FOR INDIMAN COORDINATOR WEEKLYCAPACITIES---**--**--**---**--**--**---**--**--**

DECLARE @Page AS int
DECLARE @Role AS int
DECLARE @ParentPage AS int
DECLARE @ParentMenuItem AS int 
DECLARE @MenuItem AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewWeeklyCapacities.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewOrders.aspx')
SET @ParentMenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @ParentMenuItem)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Coordinator')

DELETE FROM [dbo].[MenuItemRole] WHERE [MenuItem] = @MenuItem AND [Role] = @Role
GO
---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**

---**--**--**---**--**--**---**--**--** REMOVE MENUITEM WEEKLYCAPACITIES FROM ORDERS---**--**--**---**--**--**---**--**--**

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @ParentMenuItem AS int 
DECLARE @MenuItem AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewWeeklyCapacities.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewOrders.aspx')
SET @ParentMenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @ParentMenuItem)

DELETE FROM [dbo].[MEnuItem] WHERE [ID] = @MenuItem
GO
---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**

---**--**--**---**--**--**---**--**--** CHANGE DASHBOARD NAME AND DESCRIPTION  ---**--**--**---**--**--**---**--**--**

DECLARE @Page AS int
DECLARE @MenuItem AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/Dashboard.aspx')
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] IS NULL) 

UPDATE [dbo].[MenuItem] SET [Name] = 'Dashboard', [Description] = 'Dashboard' WHERE [ID] = @MenuItem
GO

---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**

---**--**--**---**--**--**---**--**--** CHANGE DASHBOARD TITLE AND HEADING  ---**--**--**---**--**--**---**--**--**
DECLARE @Page AS int

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/Dashboard.aspx')


UPDATE [dbo].[Page] SET [Title] = 'Dashboard', [Heading] = 'Dashboard' WHERE [ID] = @Page
GO
---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**

---**--**--**---**--**--**---**--**--** ADD NEW COLUMN TO THE USER TABLE  ---**--**--**---**--**--**---**--**--**

ALTER TABLE [dbo].[User]
ADD [Designation] NVARCHAR(255) NULL
GO
---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**

---**--**--**---**--**--**---**--**--** ALTER RETURN USER LOGN STORED PROCEDURE ---**--**--**---**--**--**---**--**--**
/****** Object:  StoredProcedure [dbo].[SPC_ReturnUserLogin]    Script Date: 07/09/2013 13:19:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ReturnUserLogin]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_ReturnUserLogin]
GO

/****** Object:  StoredProcedure [dbo].[SPC_ReturnUserLogin]    Script Date: 07/09/2013 13:19:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SPC_ReturnUserLogin] (	
	@P_Username varchar(255),
	@P_Password varchar(255)
)
AS
BEGIN
	SELECT	DISTINCT
			u.[ID],
			u.[Company],
			u.[IsDistributor],
			u.[Status],
			u.[Username],
			u.[Password],
			u.[GivenName],
			u.[FamilyName],
			u.[EmailAddress],
			u.[PhotoPath],
			u.[Creator],
			u.[CreatedDate],
			u.[Modifier],
			u.[ModifiedDate],
			u.[IsActive],
			u.[IsDeleted],
			u.[Guid],
			u.[MobileTelephoneNumber],
			u.[HomeTelephoneNumber],
			u.[OfficeTelephoneNumber],
			u.[DateLastLogin],
			u.[HaveAccessForHTTPPost],
			u.[Designation]
			--u.[Credits]--, 
			--u.[DistributorLabel]
	FROM	[dbo].[User] u
	WHERE 	u.Username = @P_Username 
			AND u.[Password] = CONVERT(varchar(255), HashBytes('SHA1', @P_Password))
			AND u.IsDeleted != 1
END


GO
---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**---**--**--**


