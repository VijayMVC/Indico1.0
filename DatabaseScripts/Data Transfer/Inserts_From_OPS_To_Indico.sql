------Update CONTACT TABLE ----------
--UPDATE OPS.dbo.tbl_Contact SET ContactTypeID = 4 WHERE CompanyName = 'CAPTIVATIONS'

--INSERT INTO OPS.dbo.tbl_Contact (ID, CompanyName, Title , FirstName ,LastName ,AddressLine1 ,AddressLine2 ,City ,[State],								 PostalCode , Country , ContactTel1 , ContactTel2 ,Mobile ,Fax ,Email , Web ,											 ContactTypeID ,NickName ,CoordinatorID ,EmailSent)
--VALUES (3000,'PERM-A-PLEAT', '','' ,'' , '' ,'' , '' ,'' , '' ,'Australia' , '' , '' , '' , '' , '' , '' , 5 ,
--		'PERM-A-PLEAT' , NULL , 0)

--INSERT INTO OPS.dbo.tbl_Contact (ID, CompanyName, Title , FirstName ,LastName ,AddressLine1 ,AddressLine2 ,City ,[State],								 PostalCode , Country , ContactTel1 , ContactTel2 ,Mobile ,Fax ,Email , Web ,											 ContactTypeID ,NickName ,CoordinatorID ,EmailSent)
--VALUES (3001,'FIFTH ELEMENT', '','' ,'' , '' ,'' , '' ,'' , '' ,'Australia' , '' , '' , '' , '' , '' , '' , 5 ,
--		'FIFTH ELEMENT' , NULL , 0)
		
--INSERT INTO OPS.dbo.tbl_Contact (ID, CompanyName, Title , FirstName ,LastName ,AddressLine1 ,AddressLine2 ,City ,[State],								 PostalCode , Country , ContactTel1 , ContactTel2 ,Mobile ,Fax ,Email , Web ,											 ContactTypeID ,NickName ,CoordinatorID ,EmailSent)
--VALUES (3002,'QUEENSLAND TSHIRT COMPANY', '','' ,'' , '' ,'' , '' ,'' ,'' ,'Australia' , '' , '' , '' , '' , '' , '' ,
--		5 ,'QUEENSLAND TSHIRT COMPANY' , NULL , 0)
		
--INSERT INTO OPS.dbo.tbl_Contact (ID, CompanyName, Title , FirstName ,LastName ,AddressLine1 ,AddressLine2 ,City ,[State],								 PostalCode , Country , ContactTel1 , ContactTel2 ,Mobile ,Fax ,Email , Web ,											 ContactTypeID ,NickName ,CoordinatorID ,EmailSent)
--VALUES (3003,'PRO SPORT', '','' ,'' , '' ,'' , '' ,'' ,'' ,'Australia' , '' , '' , '' , '' , '' , '' ,
--		5 ,'PRO SPORT' , NULL , 0)
		
--INSERT INTO OPS.dbo.tbl_Contact (ID, CompanyName, Title , FirstName ,LastName ,AddressLine1 ,AddressLine2 ,City ,[State],								 PostalCode , Country , ContactTel1 , ContactTel2 ,Mobile ,Fax ,Email , Web ,											 ContactTypeID ,NickName ,CoordinatorID ,EmailSent)
--VALUES (3004,'HUNTER BOWL', '','' ,'' , '' ,'' , '' ,'' ,'' ,'Australia' , '' , '' , '' , '' , '' , '' ,
--		5 ,'HUNTER BOWL' , NULL , 0)

--INSERT INTO OPS.dbo.tbl_Contact (ID, CompanyName, Title , FirstName ,LastName ,AddressLine1 ,AddressLine2 ,City ,[State],								 PostalCode , Country , ContactTel1 , ContactTel2 ,Mobile ,Fax ,Email , Web ,											 ContactTypeID ,NickName ,CoordinatorID ,EmailSent)
--VALUES (3005,'UNI GEAR', '','' ,'' , ' ' ,'' , '' ,'' ,'' ,'Australia' , '' , '' , '' , '' , '' , '' ,
--		5 ,'UNI GEAR' , NULL , 0)

--INSERT INTO OPS.dbo.tbl_Contact (ID, CompanyName, Title , FirstName ,LastName ,AddressLine1 ,AddressLine2 ,City ,[State],								 PostalCode , Country , ContactTel1 , ContactTel2 ,Mobile ,Fax ,Email , Web ,											 ContactTypeID ,NickName ,CoordinatorID ,EmailSent)
--VALUES (3006,'SAM PARKINSON MARKETING', '','' ,'' , '' ,'' , '' ,'' ,'' ,'Australia' , '' , '' , '' , '' , '' , '' ,
--		5 ,'SAM PARKINSON MARKETING' , NULL , 0)

--INSERT INTO OPS.dbo.tbl_Contact (ID, CompanyName, Title , FirstName ,LastName ,AddressLine1 ,AddressLine2 ,City ,[State],								 PostalCode , Country , ContactTel1 , ContactTel2 ,Mobile ,Fax ,Email , Web ,											 ContactTypeID ,NickName ,CoordinatorID ,EmailSent)
--VALUES (3007,'CAPTIVATIONS', '','' ,'' , '' ,'' , '' ,'' ,'' ,'Australia' , '' , '' , '' , '' , '' , '' ,
--	    5 ,'CAPTIVATIONS' , NULL , 0)

--INSERT INTO OPS.dbo.tbl_SpecialPrice (ID,Name) VALUES (41,'DRS')

--DELETE FROM OPS.dbo.tbl_ItemAttribute WHERE ID = 1

--DELETE FROM OPS.dbo.tbl_ItemAttribute WHERE ID = 2

--DELETE FROM OPS.dbo.tbl_ItemAttribute WHERE ID = 3

--DELETE FROM OPS1.dbo.tbl_ItemAttribute WHERE ID = 1

--DELETE FROM OPS1.dbo.tbl_ItemAttribute WHERE ID = 2

--DELETE FROM OPS1.dbo.tbl_ItemAttribute WHERE ID = 3
-------//---------------

-- Create two m apping tables to identify the new id's for correcsponding old ids of
-- Pattern and Fabric code tables
/****** Object:  Table [dbo].[FabricMapping]    Script Date: 07/10/2012 13:32:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FabricMapping]') AND type in (N'U'))
DROP TABLE [dbo].[FabricMapping]
GO

CREATE TABLE [Indico].[dbo].[FabricMapping](
	[NewId] [int] NOT NULL,
	[OldId] [int] NOT NULL,
 CONSTRAINT [PK_FabricMapping] PRIMARY KEY CLUSTERED 
(
	[NewId] ASC,
	[OldId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[PatternMapping]    Script Date: 07/10/2012 13:33:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PatternMapping]') AND type in (N'U'))
DROP TABLE [dbo].[PatternMapping]
GO


CREATE TABLE [Indico].[dbo].[PatternMapping](
	[NewId] [int] NOT NULL,
	[OldId] [int] NOT NULL,
 CONSTRAINT [PK_PatternMapping] PRIMARY KEY CLUSTERED 
(
	[NewId] ASC,
	[OldId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[ItemAttributeMapping]    Script Date: 07/12/2012 17:13:25 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ItemAttributeMapping]') AND type in (N'U'))
DROP TABLE [dbo].[ItemAttributeMapping]
GO

---------//***-----------

-----Create ItemAttribute Mapping --------------
CREATE TABLE [Indico].[dbo].[ItemAttributeMapping](
	[NewId] [int] NOT NULL,
	[OldId] [int] NOT NULL,
 CONSTRAINT [PK_ItemAttributeMapping] PRIMARY KEY CLUSTERED 
(
	[NewId] ASC,
	[OldId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO


/****** Object:  Table [dbo].[VisualLayoutMapping]    Script Date: 07/13/2012 17:11:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[VisualLayoutMapping]') AND type in (N'U'))
DROP TABLE [dbo].[VisualLayoutMapping]
GO

------///*****--------

-----Create VisualLayoutMapping------------
CREATE TABLE [Indico].[dbo].[VisualLayoutMapping](
	[NewId] [int] NOT NULL,
	[OldId] [int] NOT NULL,
 CONSTRAINT [PK_VisualLayoutMapping] PRIMARY KEY CLUSTERED 
(
	[NewId] ASC,
	[OldId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
------/---------------

/****** Object:  Table [dbo].[SizeMapping]    Script Date: 07/16/2012 10:32:20 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SizeMapping]') AND type in (N'U'))
DROP TABLE [dbo].[SizeMapping]
GO
-----Create SizeMapping Table--------
CREATE TABLE [Indico].[dbo].[SizeMapping](
	[NewId] [int] NOT NULL,
	[OldId] [int] NOT NULL,
 CONSTRAINT [PK_SizeMapping] PRIMARY KEY CLUSTERED 
(
	[NewId] ASC,
	[OldId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
-----////------------------
-----Create TEMPDistributorPriceLevelCost------
/****** Object:  Table [dbo].[TEMPDistributorPriceLevelCost]    Script Date: 07/18/2012 09:10:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TEMPDistributorPriceLevelCost]') AND type in (N'U'))
DROP TABLE [dbo].[TEMPDistributorPriceLevelCost]
GO

CREATE TABLE [Indico].[dbo].[TEMPDistributorPriceLevelCost]
(
	[ID] [int] NULL,
)
---/******\--------------
---AgeGroup---
	INSERT INTO Indico.dbo.AgeGroup(Name)
	SELECT Name FROM OPS.dbo.tbl_AgeGroup
----/-----
GO

---Gender----
	INSERT INTO Indico.dbo.Gender(Name)
	SELECT Name FROM OPS.dbo.tbl_Gender
-----/------
GO

---Item-----
	INSERT INTO Indico.dbo.Item(Name,[Description])
	SELECT Name , Name FROM OPS.dbo.tbl_Item WHERE Name != '' OR Name != null
		
----/-----
GO
-- New OPS1 Item-----
INSERT INTO Indico.dbo.Item(Name,[Description])
 SELECT  i1.Name, i1.Name
FROM OPS1.dbo.tbl_Item i1   
	LEFT OUTER JOIN OPS.dbo.tbl_Item i2
		 ON i1.Name COLLATE DATABASE_DEFAULT = i2.Name COLLATE DATABASE_DEFAULT
WHERE i2.Name  IS NULL		

----///\\\------
------item[Parent]-------
	 DECLARE @itemCount INT	 	 
	 SET @itemCount =(SELECT COUNT(*) AS [COUNT] FROM OPS.dbo.tbl_Item)
	 
		 WHILE 0<= @itemCount
		 			BEGIN 
				DECLARE @indicoItemID INT
				DECLARE @opsItemID INT
				DECLARE @indicoItemName varchar (255)
				
				SET @indicoItemID =(SELECT TOP 1 ID FROM Indico.dbo.Item ii 
													WHERE ii.ID =@itemCount 
													AND  Name != '' OR	Name != null)
				SET @indicoItemName = (SELECT TOP 1 Name FROM Indico.dbo.Item ii 
														 WHERE ii.ID =@itemCount)
				SET @opsItemID = (SELECT TOP 1 oi.ID FROM OPS.dbo.tbl_Item oi
								WHERE oi.Name = @indicoItemName)
		
				INSERT INTO Indico.dbo.Item (Name,[Description],Parent )
								SELECT Name ,
									   Name , 
									   @indicoItemID 
								FROM OPS.dbo.tbl_SubItem osi 
								WHERE osi.ItemID = @opsItemID 
													AND   Name != '' OR	Name != null
				
				SET @itemCount =@itemCount-1
		END
		GO	 		  
------/--------

----OPS1 Item Parent ------

DECLARE @ID AS int
DECLARE @ItemID AS int
DECLARE @Name AS nvarchar(255) 

DECLARE NewItemParentCursor CURSOR FAST_FORWARD FOR 
SELECT si1.[ID]
      ,si1.[ItemID]
      ,si1.[Name]
FROM OPS1.dbo.tbl_SubItem si1  
	LEFT OUTER JOIN OPS.dbo.tbl_SubItem si2
		 ON si1.Name COLLATE DATABASE_DEFAULT = si2.Name COLLATE DATABASE_DEFAULT
WHERE si2.Name  IS NULL	 
OPEN NewItemParentCursor 
	FETCH NEXT FROM NewItemParentCursor INTO @ID, @ItemID , @Name
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
		INSERT INTO Indico.dbo.Item(Name, [Description], Parent)
	VALUES (
			@Name,
			@Name,
			(SELECT ID FROM Indico.dbo.Item i WHERE i.Name COLLATE DATABASE_DEFAULT = 
														(SELECT ii.Name FROM OPS1.dbo.tbl_Item ii 
																WHERE ii.ID = @ItemID ) )
		   )
	
		FETCH NEXT FROM NewItemParentCursor INTO @ID, @ItemID , @Name
	END 

CLOSE NewItemParentCursor 
DEALLOCATE NewItemParentCursor		
-----/--------
GO

---Item Attribute----
DECLARE @ID AS int
DECLARE @ItemID AS int
DECLARE @Name AS nvarchar(255) 
DECLARE @NewItemAttributeID AS int

DECLARE ItemAttributeCursor CURSOR FAST_FORWARD FOR 
SELECT [ID]
      ,[ItemID]
      ,[Name]
FROM [OPS].[dbo].[tbl_ItemAttribute]  
OPEN ItemAttributeCursor 
	FETCH NEXT FROM ItemAttributeCursor INTO @ID, @ItemID , @Name
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
		INSERT INTO Indico.dbo.ItemAttribute (Parent,Item,Name,[Description] )
		VALUES (
						NULL,
				  (		SELECT TOP 1 ID FROM Indico.dbo.Item ii 
												WHERE ii.Name = (SELECT TOP 1 Name 
												FROM OPS.dbo.tbl_Item oi
												WHERE oi.ID = @ItemID)),
						@Name,
						@Name
			   )
			  
			   SET @NewItemAttributeID = SCOPE_IDENTITY()
			   
			INSERT INTO Indico.dbo.ItemAttributeMapping ([NewId],[OldId])
			VALUES(@NewItemAttributeID,@ID)

		FETCH NEXT FROM ItemAttributeCursor INTO @ID, @ItemID , @Name
	END 

CLOSE ItemAttributeCursor 
DEALLOCATE ItemAttributeCursor		
-----/--------
GO

----New Item Attribute --------
DECLARE @ID AS int
DECLARE @ItemID AS int
DECLARE @Name AS nvarchar(255) 
DECLARE @NewItemAttributeID AS int
DECLARE OPS1NewItemAttributeCursor CURSOR FAST_FORWARD FOR 

SELECT  ia1.ID,
		ia1.ItemID,
	    ia1.Name
FROM OPS1.dbo.tbl_ItemAttribute ia1   
		 LEFT OUTER JOIN OPS.dbo.tbl_ItemAttribute ia2
		 ON ia1.Name  COLLATE DATABASE_DEFAULT = ia2.Name COLLATE DATABASE_DEFAULT
WHERE ia2.Name IS NULL		
  
OPEN OPS1NewItemAttributeCursor 
	FETCH NEXT FROM OPS1NewItemAttributeCursor INTO @ID, @ItemID , @Name
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
		INSERT INTO Indico.dbo.ItemAttribute (Parent,Item,Name,[Description] )
		VALUES (
						NULL,
				  (		SELECT TOP 1 ID FROM Indico.dbo.Item ii 
												WHERE ii.Name COLLATE DATABASE_DEFAULT = (SELECT TOP 1 Name 
												FROM OPS1.dbo.tbl_Item oi
												WHERE oi.ID = @ItemID)),
						@Name,
						@Name
			   )
			  
			   SET @NewItemAttributeID = SCOPE_IDENTITY()
			   
			INSERT INTO Indico.dbo.ItemAttributeMapping ([NewId],[OldId])
			VALUES(@NewItemAttributeID,@ID)

		FETCH NEXT FROM OPS1NewItemAttributeCursor INTO @ID, @ItemID , @Name
	END 

CLOSE OPS1NewItemAttributeCursor 
DEALLOCATE OPS1NewItemAttributeCursor		
-----/--------
GO

---Item AttributeSub----
DECLARE @itemSub TABLE (
[Parent] [int] NULL,
[Item] [int] NULL,
[Name] [nvarchar](64) NULL,
[Description] [nvarchar](255) NULL)
	
DECLARE @ID AS int
DECLARE @ItemAttributeID AS int
DECLARE @Name AS nvarchar(255) 
DECLARE @parentID AS int
DECLARE @itemID AS int

DECLARE ItemAttributeCursor CURSOR FAST_FORWARD FOR 
	SELECT [ID]
      ,[ItemAttributeID]
      ,[Name]
  FROM [OPS].[dbo].[tbl_ItemAttributeSub]
OPEN ItemAttributeCursor 
	FETCH NEXT FROM ItemAttributeCursor INTO @ID, @ItemAttributeID , @Name
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		
		SET @parentID =(SELECT TOP 1 iam.[NewId] FROM Indico.dbo.ItemAttributeMapping iam 
													WHERE iam.[OldId] = @ItemAttributeID)
														
		SET @itemID = (SELECT TOP 1 ID FROM Indico.dbo.Item ii
														WHERE ii.Name =(SELECT TOP 1 oi.Name 
														FROM OPS.dbo.tbl_Item oi
														JOIN  OPS.dbo.tbl_ItemAttribute oia
														ON oia.ItemID =  oi.ID
														WHERE oia.ID =(SELECT TOP 1oias.ItemAttributeID 
														FROM OPS.dbo.tbl_ItemAttributeSub oias
														WHERE oias.ItemAttributeID =@ItemAttributeID ) ))
														
		
			 INSERT INTO @itemSub (Parent, Item , Name , [Description])
			 VALUES (@parentID,
					 @itemID,
					 @Name, 
					 @Name)
		
		FETCH NEXT FROM ItemAttributeCursor INTO @ID, @ItemAttributeID , @Name
	END 

CLOSE ItemAttributeCursor 
DEALLOCATE ItemAttributeCursor		
INSERT INTO Indico.dbo.ItemAttribute 
SELECT * FROM @itemSub
-----/--------
GO

---New Item Attribute Sub---
DECLARE @itemSub TABLE (
[Parent] [int] NULL,
[Item] [int] NULL,
[Name] [nvarchar](64) NULL,
[Description] [nvarchar](255) NULL)
	
DECLARE @ID AS int
DECLARE @ItemAttributeID AS int
DECLARE @Name AS nvarchar(255) 
DECLARE @parentID AS int
DECLARE @itemID AS int

DECLARE NewItemAttributeSubCursor CURSOR FAST_FORWARD FOR 
SELECT	ia1.ID,
		ia1.ItemAttributeID,
		ia1.Name
FROM OPS1.dbo.tbl_ItemAttributeSub ia1   
		 LEFT OUTER JOIN OPS.dbo.tbl_ItemAttributeSub ia2
		 ON ia1.Name  COLLATE DATABASE_DEFAULT = ia2.Name COLLATE DATABASE_DEFAULT
WHERE ia2.Name IS NULL	
OPEN NewItemAttributeSubCursor 
	FETCH NEXT FROM NewItemAttributeSubCursor INTO @ID, @ItemAttributeID , @Name
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		
		SET @parentID =(SELECT TOP 1 iam.[NewId] FROM Indico.dbo.ItemAttributeMapping iam 
													WHERE iam.[OldId] = @ItemAttributeID)
														
		SET @itemID = (SELECT TOP 1 ID FROM Indico.dbo.Item ii
														WHERE ii.Name COLLATE DATABASE_DEFAULT =
														(SELECT TOP 1 oi.Name 
														FROM OPS1.dbo.tbl_Item oi
														JOIN  OPS1.dbo.tbl_ItemAttribute oia
														ON oia.ItemID =  oi.ID
														WHERE oia.ID =(SELECT TOP 1 oias.ItemAttributeID 
														FROM OPS1.dbo.tbl_ItemAttributeSub oias
														WHERE oias.ItemAttributeID = @ItemAttributeID ) ))
														
		
			 INSERT INTO @itemSub (Parent, Item , Name , [Description])
			 VALUES (@parentID,
					 @itemID,
					 @Name, 
					 @Name)
		
		FETCH NEXT FROM NewItemAttributeSubCursor INTO @ID, @ItemAttributeID , @Name
	END 

CLOSE NewItemAttributeSubCursor 
DEALLOCATE NewItemAttributeSubCursor		
INSERT INTO Indico.dbo.ItemAttribute 
SELECT * FROM @itemSub
-----/--------
GO

----Printer-------
	INSERT INTO Indico.dbo.Printer(Name,[Description])
	SELECT P.Name ,P.Name  FROM OPS.dbo.tbl_Printer p 
----/---------------

---PrinterType-----
	INSERT INTO Indico.dbo.PrinterType(Name,[Description])
	SELECT Name , Name FROM OPS.dbo.tbl_PrinterType
----/------
GO
	
----SizeSet-------
	INSERT INTO Indico.dbo.SizeSet(Name,[Description] )
	SELECT Name, Name FROM OPS.dbo.tbl_SizeSet
----/-------
GO

---New SizeSet-----
INSERT INTO Indico.dbo.SizeSet(Name,[Description])
SELECT s1.Name, s1.Name 
FROM OPS1.dbo.tbl_SizeSet s1  
	LEFT OUTER JOIN OPS.dbo.tbl_SizeSet s2
		 ON s1.Name  COLLATE DATABASE_DEFAULT = s2.Name COLLATE DATABASE_DEFAULT
WHERE s2.Name IS NULL

----/--------

-----Size---
DECLARE @ID AS int
DECLARE @SizeSetId AS int
DECLARE @Size AS nvarchar(255) 
DECLARE @SeqNo AS int
DECLARE SizeCursor CURSOR FAST_FORWARD FOR 
SELECT [ID]
      ,[SizeSetId]
      ,[Size]
      ,[SeqNo]
FROM [OPS].[dbo].[tbl_Sizes]
OPEN SizeCursor 
	FETCH NEXT FROM SizeCursor INTO @ID , @SizeSetId , @Size , @SeqNo
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		IF (EXISTS(SELECT ID FROM OPS.dbo.tbl_SizeSet WHERE ID = @SizeSetId))
		BEGIN
			INSERT INTO Indico.dbo.Size(SizeSet , SizeName , SeqNo )
			VALUES (
						(SELECT TOP 1 iss.ID FROM Indico.dbo.SizeSet iss
															WHERE iss.Name = (SELECT TOP 1 oss.Name  
															FROM  OPS.dbo.tbl_SizeSet oss
															WHERE oss.ID = @SizeSetId )),
						@Size,
						@SeqNo
				    )
			INSERT INTO Indico.dbo.SizeMapping ([NewId],[OldId])
			VALUES(SCOPE_IDENTITY(),@ID)
		END
		FETCH NEXT FROM SizeCursor INTO @ID , @SizeSetId , @Size , @SeqNo
	END 

CLOSE SizeCursor 
DEALLOCATE SizeCursor		
-----/--------
GO

----New Sizes-------

DECLARE @ID AS int
DECLARE @SizeSetId AS int
DECLARE @Size AS nvarchar(255) 
DECLARE @SeqNo AS int
DECLARE NewSizeCursor CURSOR FAST_FORWARD FOR 
SELECT s1.ID,
	   s1.SizeSetId,
	   s1.Size,
	   s1.SeqNo
FROM OPS1.dbo.tbl_Sizes s1  
	LEFT OUTER JOIN OPS.dbo.tbl_Sizes s2
		 ON s1.Size  COLLATE DATABASE_DEFAULT = s2.Size COLLATE DATABASE_DEFAULT
WHERE s2.Size IS NULL	

OPEN NewSizeCursor 
	FETCH NEXT FROM NewSizeCursor INTO @ID , @SizeSetId , @Size , @SeqNo
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		IF (EXISTS(SELECT ID FROM OPS1.dbo.tbl_SizeSet WHERE ID = @SizeSetId))
		BEGIN
			INSERT INTO Indico.dbo.Size(SizeSet , SizeName , SeqNo )
			VALUES (
						(SELECT TOP 1 iss.ID FROM Indico.dbo.SizeSet iss
															WHERE iss.Name COLLATE DATABASE_DEFAULT =
														    (SELECT TOP 1 oss.Name  
															FROM  OPS1.dbo.tbl_SizeSet oss
															WHERE oss.ID = @SizeSetId )),
						@Size,
						@SeqNo
				    )
			INSERT INTO Indico.dbo.SizeMapping ([NewId],[OldId])
			VALUES(SCOPE_IDENTITY(),@ID)
		END
		FETCH NEXT FROM NewSizeCursor INTO @ID , @SizeSetId , @Size , @SeqNo
	END 

CLOSE NewSizeCursor 
DEALLOCATE NewSizeCursor		
-----/--------
GO

----ProductionLine------
	INSERT INTO Indico.dbo.ProductionLine(Name,[Description])
	SELECT Name , Name FROM OPS.dbo.tbl_ProductionLines
-----/-------
GO

------SportsCategory------
--	INSERT INTO Indico.dbo.SportsCategory(Name,[Description])
--	SELECT Name,Name FROM OPS.dbo.tbl_SportsCategory
-------/---------
--GO

-----ShipmentMode------
	INSERT INTO Indico.dbo.ShipmentMode(Name,[Description])
	SELECT Name,Name FROM OPS.dbo.tbl_ShipmentMode
-----/-------
GO

-----PriceLevel------
	INSERT INTO Indico.dbo.PriceLevel(Name,Volume)
	SELECT Name , Volume FROM OPS.dbo.tbl_PriceLevel
----/-----
GO

----DestinationPort-----
	INSERT INTO Indico.dbo.DestinationPort(Name,[Description])
	SELECT Name , Name FROM OPS.dbo.tbl_DestinationPort
----/----------
GO


-----OrderStatus--------
	INSERT INTO Indico.dbo.OrderStatus(Name,[Description])
	SELECT Name , Name FROM OPS.dbo.tbl_OrderStatus
-----/-------
GO

----OrderType-------
	INSERT INTO Indico.dbo.OrderType(Name,[Description])
	SELECT Name , Name FROM OPS.dbo.tbl_OrderType
------/--------
GO

----ResolutionProfile----
	INSERT INTO Indico.dbo.ResolutionProfile(Name,[Description])
	SELECT Name , Name FROM OPS.dbo.tbl_ResolutionProfile
-----/------------
GO

-----ColorProfile----------
	INSERT INTO Indico.dbo.ColourProfile(Name,[Description])
	SELECT Name , Name FROM OPS.dbo.tbl_ColourProfile
------/------------
GO

-----NickName---------
	INSERT INTO Indico.dbo.NickName(Name)
	SELECT Name FROM OPS.dbo.tbl_NickName
-----/---------
GO

------KeyWord--------
	INSERT INTO Indico.dbo.Keyword(Name,[Description])
	SELECT Name , Name FROM OPS.dbo.tbl_KeyWord
-----/-------
GO

------JobTitle--------
	INSERT INTO Indico.dbo.JobTitle(Name,[Description])
	SELECT Name , Name FROM OPS.dbo.tbl_JobTitles
-----/-------
GO

-----FabricCodes-----
DECLARE @ID AS int
DECLARE @Code AS nvarchar (255)
DECLARE @Name AS nvarchar(255)
DECLARE @Material AS nvarchar (255)
DECLARE @GSM AS nvarchar (255)
DECLARE @Supplier AS nvarchar (255)
DECLARE @Country AS nvarchar (255)
DECLARE @Denier_Count AS nvarchar (255)
DECLARE @Filaments AS nvarchar (255)
DECLARE @Nickname AS nvarchar (255)
DECLARE @Serial_Order AS nvarchar (255)
DECLARE @Landed_Cost AS nvarchar (255)
DECLARE @FabricID AS int

DECLARE FabricCursor CURSOR FAST_FORWARD FOR 
SELECT [ID]
      ,[code]
      ,[Name]
      ,[Material]
      ,[GSM]
      ,[Supplier]
      ,[Country]
      ,[Denier Count]
      ,[Filaments]
      ,[Nickname]
      ,[Serial Order]
      ,[Landed Cost]
FROM [OPS].[dbo].[tbl_FabricCodes]
OPEN FabricCursor 
	FETCH NEXT FROM FabricCursor INTO @ID, @Code ,@Name , @Material , @GSM , @Supplier , @Country ,
									  @Denier_Count ,@Filaments , @Nickname , @Serial_Order , @Landed_Cost
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
					INSERT INTO Indico.dbo.FabricCode (Code, Name , Material , GSM , Supplier , Country ,														   DenierCount,Filaments , NickName , SerialOrder ,															   LandedCost , LandedCurrency)
					VALUES (    @Code,
								@Name,
								@Material,
								@GSM,
								@Supplier,
								ISNULL((SELECT ID FROM Indico.dbo.Country c 
												 WHERE C.ShortName = @Country),14),
								@Denier_Count ,
								@Filaments ,
								@Nickname,
								@Serial_Order ,
								@Landed_Cost ,
								NULL
							)
							
					SET @FabricID = SCOPE_IDENTITY ()
					INSERT INTO Indico.dbo.FabricMapping ([NewId],[OldId])
					VALUES (@FabricID,@ID)
			
		
		FETCH NEXT FROM FabricCursor INTO @ID, @Code ,@Name , @Material , @GSM , @Supplier , @Country ,
										  @Denier_Count ,@Filaments , @Nickname , @Serial_Order , @Landed_Cost
	END 

CLOSE FabricCursor
DEALLOCATE FabricCursor
-----/--------
GO

---FabricCodes01 to FabricCode----------
--INSERT INTO Indico.dbo.FabricCode 
--				(Code,Name,Material,Supplier,Country,DenierCount,Filaments,NickName,SerialOrder,LandedCost,LandedCurrency)
--		SELECT fc1.Code ,
--			   fc1.Name ,
--			   fc1.Material ,
--			   fc1.Supplier ,
--			   ISNULL((SELECT c.ID FROM Indico.dbo.Country c WHERE c.ShortName = fc1.Country) ,14) AS Country ,
--			   fc1.Denier_Count  , 
--			   fc1.Filaments , 
--			   fc1.NickName , 
--			   fc1.Serial_Order  ,
--			   fc1.Landed_Cost ,
--			   NULL  
--		FROM OPS.dbo.tbl_FabricCodes1 fc1 
------/---------
--GO
-----PaymentMethod-------
	INSERT INTO Indico.dbo.PaymentMethod (Name ,[Description])
	SELECT Name , Name FROM OPS.dbo.tbl_PaymentMethod
-------/----------
GO

----ClientType-------
	INSERT INTO Indico.dbo.ClientType(Name,[Description])
	SELECT Name ,Name FROM OPS.dbo.tbl_ContactType
------/-----------
GO

-----Distributor[COMPANY TABLE]-------
DECLARE @ID AS int
DECLARE @CompanyName AS nvarchar
DECLARE @Title AS nvarchar(255) 
DECLARE @FirstName AS nvarchar (255)
DECLARE @LastName AS nvarchar (255)
DECLARE @AddressLine1 AS nvarchar (255)
DECLARE @AddressLine2 AS nvarchar (255)
DECLARE @City AS nvarchar (255)
DECLARE @State AS nvarchar (255)
DECLARE @PostalCode AS nvarchar (255)
DECLARE @Country AS nvarchar (255)
DECLARE @ContactTel1 AS nvarchar (255)
DECLARE @ContactTel2 AS nvarchar (255)
DECLARE @Mobile AS nvarchar (255)
DECLARE @Fax AS nvarchar (255)
DECLARE @Email AS nvarchar (255)
DECLARE @Web AS nvarchar (255)
DECLARE @ContactTypeID AS int
DECLARE @NickName AS nvarchar (255)
DECLARE @CoordinatorID AS int
DECLARE @EmailSent AS bit

DECLARE DistributorCursor CURSOR FAST_FORWARD FOR 
 SELECT[ID]
      ,[CompanyName]
      ,[Title]
      ,[FirstName]
      ,[LastName]
      ,[AddressLine1]
      ,[AddressLine2]
      ,[City]
      ,[State]
      ,[PostalCode]
      ,[Country]
      ,[ContactTel1]
      ,[ContactTel2]
      ,[Mobile]
      ,[Fax]
      ,[Email]
      ,[Web]
      ,[ContactTypeID]
      ,[NickName]
      ,[CoordinatorID]
      ,[EmailSent]
  FROM [OPS].[dbo].[tbl_Contact]
  
OPEN DistributorCursor 
	FETCH NEXT FROM DistributorCursor INTO @ID, @CompanyName, @Title ,@FirstName ,@LastName ,@AddressLine1 ,
										   @AddressLine2,
										   @City ,@State ,@PostalCode ,@Country , @ContactTel1 ,@ContactTel2 ,@Mobile ,
									       @Fax ,@Email, @Web ,@ContactTypeID ,@NickName ,@CoordinatorID ,@EmailSent     
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		-- Add other categories 
		IF (@ContactTypeID = 5)
		
			BEGIN
				INSERT INTO Indico.dbo.Company ([Type] , IsDistributor , Name , Number , Address1 , Address2 ,												City ,[State] ,Postcode , Country ,Phone1 ,Phone2 ,Fax ,													NickName , Coordinator , [Owner] , Creator ,CreatedDate ,													Modifier ,ModifiedDate)
				VALUES(
						(SELECT TOP 1 ID FROM Indico.dbo.ClientType ict
												WHERE ict.Name = (SELECT TOP 1 Name FROM OPS.dbo.tbl_ContactType oct 
																			  WHERE oct.ID = @ContactTypeID)),
			   1 , 
			   (SELECT oc.CompanyName FROM OPS.dbo.tbl_Contact oc WHERE ID = @ID) ,
			   NULL ,
			   ISNULL(@AddressLine1,'address'),
			   @AddressLine2,
			   ISNULL(@City,'city') ,
			   ISNULL(@State,'state') ,
			   ISNULL(@PostalCode,'postalcode') ,
			   ISNULL((SELECT ID FROM Indico.dbo.Country c WHERE c.ShortName = @Country),14) ,
			   ISNULL(@ContactTel1,'contact1') ,
			   @ContactTel2 ,
			   ISNULL(@Fax,'fax') ,
			   ISNULL(@NickName,NULL) ,
			   NULL ,
			   NULL ,
			   1 ,
			   (SELECT GETDATE()),
			   1 ,
			   (SELECT GETDATE())
		  )  
		 	
			END
			
		FETCH NEXT FROM DistributorCursor INTO @ID, @CompanyName, @Title ,@FirstName ,@LastName ,@AddressLine1 ,
											   @AddressLine2, @City ,@State ,@PostalCode ,@Country , @ContactTel1 ,
											   @ContactTel2 ,@Mobile ,@Fax ,@Email, @Web ,@ContactTypeID ,@NickName ,
											   @CoordinatorID ,@EmailSent  
	END 

CLOSE DistributorCursor 
DEALLOCATE DistributorCursor		
-----/--------
GO

-- TODO - There no records for certain distributors. So use cursor
----- DistributorPriceMarkup -------
DECLARE @DistributorPriceMarkup TABLE 
(
	[Distributor] [int] NULL,
	[PriceLevel] [int]  NULL,
	[Markup] [decimal](4, 2) NOT NULL
)

DECLARE @ID AS int
DECLARE @SpecialPriceID AS int
DECLARE @PriceLevelID AS int 
DECLARE @Rate AS decimal
DECLARE PriceMarkupCursor CURSOR FAST_FORWARD FOR 
	SELECT  [ID]
		   ,[SpecialPriceID]
		   ,[PriceLevelID]
		   ,[Rate]
  FROM [OPS].[dbo].[tbl_SpecialPriceLevel] 
OPEN PriceMarkupCursor 
	FETCH NEXT FROM PriceMarkupCursor INTO @ID, @SpecialPriceID , @PriceLevelID , @Rate
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		
			INSERT INTO @DistributorPriceMarkup(Distributor , PriceLevel , Markup )
			VALUES(
					(SELECT TOP 1 [ID]
									FROM Indico.dbo.Company  ic WHERE ic.Name  =
								(SELECT TOP 1 oc.CompanyName FROM [OPS].[dbo].[tbl_Contact] oc
										WHERE oc.CompanyName = 
								(SELECT TOP 1 sp.Name
									FROM OPS.dbo.tbl_SpecialPrice sp
										WHERE @SpecialPriceID = sp.ID) AND oc.ContactTypeID =5)), 
					(SELECT TOP 1 ipl.[ID]      
								FROM [Indico].[dbo].[PriceLevel] ipl
									WHERE ipl.Name = (SELECT TOP 1 pl.Name
								FROM [OPS].[dbo].[tbl_PriceLevel] pl
									WHERE @PriceLevelID = pl.ID)),
					@Rate
			)
		
		FETCH NEXT FROM PriceMarkupCursor INTO @ID, @SpecialPriceID , @PriceLevelID , @Rate
	END 
INSERT INTO Indico.dbo.DistributorPriceMarkup
SELECT * FROM @DistributorPriceMarkup
CLOSE PriceMarkupCursor 
DEALLOCATE PriceMarkupCursor		
-----/--------
GO

-----Production Sequence---------
	INSERT INTO Indico.dbo.ProductSequence (Number)
	SELECT Number FROM OPS.dbo.tbl_ProductSequence 
-------/-----------
GO

----Client----------
DECLARE @ID AS int
DECLARE @CompanyName AS nvarchar
DECLARE @Title AS nvarchar(255) 
DECLARE @FirstName AS nvarchar (255)
DECLARE @LastName AS nvarchar (255)
DECLARE @AddressLine1 AS nvarchar (255)
DECLARE @AddressLine2 AS nvarchar (255)
DECLARE @City AS nvarchar (255)
DECLARE @State AS nvarchar (255)
DECLARE @PostalCode AS nvarchar (255)
DECLARE @Country AS nvarchar (255)
DECLARE @ContactTel1 AS nvarchar (255)
DECLARE @ContactTel2 AS nvarchar (255)
DECLARE @Mobile AS nvarchar (255)
DECLARE @Fax AS nvarchar (255)
DECLARE @Email AS nvarchar (255)
DECLARE @Web AS nvarchar (255)
DECLARE @ContactTypeID AS int
DECLARE @NickName AS nvarchar (255)
DECLARE @CoordinatorID AS int
DECLARE @EmailSent AS bit

DECLARE ContactCursor CURSOR FAST_FORWARD FOR 
 SELECT[ID]
      ,[CompanyName]
      ,[Title]
      ,[FirstName]
      ,[LastName]
      ,[AddressLine1]
      ,[AddressLine2]
      ,[City]
      ,[State]
      ,[PostalCode]
      ,[Country]
      ,[ContactTel1]
      ,[ContactTel2]
      ,[Mobile]
      ,[Fax]
      ,[Email]
      ,[Web]
      ,[ContactTypeID]
      ,[NickName]
      ,[CoordinatorID]
      ,[EmailSent]
  FROM [OPS].[dbo].[tbl_Contact]
OPEN ContactCursor 
	FETCH NEXT FROM ContactCursor INTO @ID, @CompanyName, @Title ,@FirstName ,@LastName ,@AddressLine1 ,@AddressLine2,
									   @City ,@State ,@PostalCode ,@Country , @ContactTel1 ,@ContactTel2 ,@Mobile ,
									   @Fax ,@Email, @Web ,@ContactTypeID ,@NickName ,@CoordinatorID ,@EmailSent     
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		-- Add other categories 
		IF (@ContactTypeID =4)
			BEGIN
				INSERT INTO Indico.dbo.Client(Distributor,[Type],Name ,Title ,FirstName ,LastName ,Address1 ,														   Address2 ,City ,[State] ,PostalCode ,Country ,Phone1 ,Phone2 ,														   Mobile,Fax,Email,Web,NickName,EmailSent,Creator ,CreatedDate ,														   Modifier ,ModifiedDate )
	VALUES (	4 ,
			   (SELECT TOP 1 ID FROM Indico.dbo.ClientType ict
												WHERE ict.Name = (SELECT Name FROM OPS.dbo.tbl_ContactType oct 
																			  WHERE oct.ID = @ContactTypeID)) ,
			   ISNULL((SELECT oc.CompanyName FROM OPS.dbo.tbl_Contact oc WHERE ID = @ID),'company name'),
			   ISNULL(@Title,0),
			   ISNULL(@FirstName,'firstname'),
			   ISNULL(@LastName,'lastname'),
			   ISNULL(@AddressLine1,0),
			   @AddressLine2,
			   ISNULL(@City,'city'),
			   ISNULL(@State,'state'),
			   ISNULL(@PostalCode,0),
			   ISNULL((SELECT ShortName FROM Indico.dbo.Country c WHERE c.ShortName =@Country),'Australia'),
			   ISNULL(@ContactTel1,'contact1'),
			   ISNULL(@ContactTel2,'contact2'),
			   @Mobile,
			   @Fax,
			   ISNULL(@Email,'noreply@indico.com'),
			   @Web,
			   @NickName,
			   @EmailSent,
			   1,
			   (SELECT GETDATE()),
			   1,
			  (SELECT GETDATE())
		)
			END
			
		FETCH NEXT FROM ContactCursor INTO @ID, @CompanyName, @Title ,@FirstName ,@LastName ,@AddressLine1 ,@AddressLine2,
										   @City ,@State ,@PostalCode ,@Country , @ContactTel1 ,@ContactTel2 ,@Mobile ,
									       @Fax ,@Email, @Web ,@ContactTypeID ,@NickName ,@CoordinatorID ,@EmailSent  
	END 

CLOSE ContactCursor 
DEALLOCATE ContactCursor		
-----/--------
GO
-----Category------
	INSERT INTO Indico.dbo.Category (Name , [Description] )
	SELECT Name , Name FROM OPS.dbo.tbl_SportsCategory
-----/---------
GO

----New Category ------
INSERT INTO Indico.dbo.Category(Name,[Description])
SELECT sc1.Name, sc1.Name 
FROM OPS1.dbo.tbl_SportsCategory sc1  
	LEFT OUTER JOIN OPS.dbo.tbl_SportsCategory sc2
		 ON sc1.Name  COLLATE DATABASE_DEFAULT = sc2.Name COLLATE DATABASE_DEFAULT
WHERE sc2.Name IS NULL		
-----//------------

----Pattern------
DECLARE @ID AS int
DECLARE @PatternNumber AS nvarchar(10)
DECLARE @InactivePattern AS bit
DECLARE @OriginRef AS [nvarchar](20)
DECLARE @ItemID AS [int] 
DECLARE @SubItemID AS [int] 
DECLARE @GenderID AS [int] 
DECLARE @AgeGroupID AS [int] 
DECLARE @SizeSetID AS [int] 
DECLARE @NickName AS [nvarchar](255) 
DECLARE @OtherCategoryID AS [int]
DECLARE @OtherCategories [nvarchar](255)
DECLARE @PrinterTypeID AS [int]
DECLARE @Keywords AS [nvarchar](255)
DECLARE @JKDescription AS [nvarchar](255)
DECLARE @Notes AS [nvarchar](255)
DECLARE @DateCreated AS [datetime]
DECLARE @SpecialAttributes AS [nvarchar](255)
DECLARE @CorPattern AS [nvarchar](255)
DECLARE @Consumption AS [nvarchar](255)
DECLARE PatternCursor CURSOR FAST_FORWARD FOR

SELECT 	[ID],
		[PatternNumber],
		[InactivePattern],
		[OriginRef],
		[ItemID],
		[SubItemID],
		[GenderID],
		[AgeGroupID],
		[SizeSetID],
		[NickName],
		[OtherCategoryID],
		[OtherCategories],
		[PrinterTypeID],
		[Keywords],
		[CorPattern],
		[JKDescription],
		[Consumption],
		[Notes],
		[DateCreated],
		[SpecialAttributes]		
FROM OPS.dbo.tbl_Pattern
  
OPEN PatternCursor 
	FETCH NEXT FROM PatternCursor INTO  @ID, @PatternNumber, @InactivePattern , @OriginRef, @ItemID,												@SubItemID,@GenderID,@AgeGroupID,@SizeSetID, @NickName, 
										@OtherCategoryID, @OtherCategories,@PrinterTypeID,@Keywords,												@CorPattern, @JKDescription, @Consumption, @Notes, 
										@DateCreated,@SpecialAttributes 
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
		INSERT INTO Indico.dbo.Pattern (Item, SubItem,  Gender, AgeGroup, SizeSet,CoreCategory,	PrinterType,										Number, OriginRef, NickName,Keywords, CorePattern, FactoryDescription,										Consumption,ConvertionFactor, SpecialAttributes, PatternNotes,												PriceRemarks,IsActive, Creator,CreatedDate, Modifier, ModifiedDate,											Remarks, IsTemplate,Parent,GarmentSpecStatus)
		
		VALUES(
						(SELECT TOP 1 ID FROM Indico.dbo.Item ii WHERE ii.Name =
														(SELECT Name FROM OPS.dbo.tbl_Item oi 
															         WHERE oi.ID = @ItemID )
																AND ii.Parent IS NULL) , -- Item
			   ISNULL(( SELECT TOP 1 ID				-- SubItem
						FROM Indico.dbo.Item ii 
						WHERE ii.Name = (	SELECT TOP 1 osi.Name 
											FROM OPS.dbo.tbl_SubItem osi	
											WHERE osi.ID = @SubItemID) AND ii.Name IS NOT NULL), 36),
			   
													
			   (	SELECT TOP 1 ID						-- Gender
					FROM Indico.dbo.Gender ig			
					WHERE ig.Name = (	SELECT og.Name 
										FROM OPS.dbo.tbl_Gender og 
										WHERE og.ID = @GenderID)),		
			   (	SELECT TOP 1 ID							-- AgeGroup
					FROM Indico.dbo.AgeGroup ia 
					WHERE ia.Name = (	SELECT oa.Name 
									FROM OPS.dbo.tbl_AgeGroup oa 
									WHERE oa.ID = @AgeGroupID)) , 
			   (	SELECT TOP 1 ID							-- SizeSet
					FROM Indico.dbo.SizeSet iis 
					WHERE iis.Name = (	SELECT oss.Name 
										FROM OPS.dbo.tbl_SizeSet oss 
										WHERE oss.ID = @SizeSetID)) ,
				ISNULL((SELECT TOP 1 ID						-- Category
						FROM Indico.dbo.Category ic 
						WHERE ic.Name = (	SELECT osc.Name 
											FROM OPS.dbo.tbl_SportsCategory osc
											WHERE osc.ID = @OtherCategoryID)), 1), 
				ISNULL((SELECT TOP 1  ip.ID					-- PrinterType
						FROM Indico.dbo.PrinterType ip 
						WHERE ip.Name = (	SELECT opt.Name 
											FROM OPS.dbo.tbl_PrinterType opt 
											WHERE opt.ID = @PrinterTypeID)),3),	
				(SELECT op.PatternNumber FROM OPS.dbo.tbl_Pattern op WHERE op.ID = @ID),
				ISNULL(@OriginRef, 0), 
				@NickName,
				@Keywords,
				@CorPattern,
				NULL, 
				@Consumption,
				ISNULL((SELECT TOP 1 FOBPrice				-- ConvertionFactor
						FROM OPS.dbo.tbl_Prices tp 
						WHERE tp.PatternID = @ID), 0.00), 
				@SpecialAttributes, 
				@Notes, 
				ISNULL((SELECT TOP 1 Remarks				-- PriceRemarks
						FROM OPS.dbo.tbl_Prices tp 
						WHERE tp.PatternID = @ID) , ''), 
				@InactivePattern, 
			    1 ,		---THIS INSERT STATMENT HAVE SOME ISSUES CORECATEGORY , PRINTER TYPE ,SUBITEM
			    @DateCreated , 
			    1 , 
			   (SELECT GETDATE()),
			    NULL , 
			    1 ,
			    NULL  , 
			    'Not Completed')
			    
			    INSERT INTO [Indico].[dbo].[PatternMapping]([NewId]  ,[OldId])
				VALUES(SCOPE_IDENTITY(), @ID)								

			FETCH NEXT FROM PatternCursor INTO  @ID, @PatternNumber, @PatternNumber, @OriginRef, @ItemID, 
												@SubItemID,@GenderID,@AgeGroupID, @SizeSetID,	@NickName,
												@OtherCategoryID,@OtherCategories,@PrinterTypeID, @Keywords,
												@CorPattern,@JKDescription,@Consumption,@Notes,@DateCreated,
												@SpecialAttributes 
	END 

CLOSE PatternCursor 
DEALLOCATE PatternCursor
-----/-----------
GO

---New Pattern Table -------
DECLARE @ID AS int
DECLARE @PatternNumber AS nvarchar(10)
DECLARE @InactivePattern AS bit
DECLARE @OriginRef AS [nvarchar](20)
DECLARE @ItemID AS [int] 
DECLARE @SubItemID AS [int] 
DECLARE @GenderID AS [int] 
DECLARE @AgeGroupID AS [int] 
DECLARE @SizeSetID AS [int] 
DECLARE @NickName AS [nvarchar](255) 
DECLARE @OtherCategoryID AS [int]
DECLARE @OtherCategories [nvarchar](255)
DECLARE @PrintTypeID AS [int]
DECLARE @Keywords AS [nvarchar](255)
DECLARE @JKDescription AS [nvarchar](255)
DECLARE @Notes AS [nvarchar](255)
DECLARE @DateCreated AS [datetime]
DECLARE @SpecialAttributes AS [nvarchar](255)
DECLARE @CorPattern AS [nvarchar](255)
DECLARE @Consumption AS [nvarchar](255)
DECLARE NewReplacePatternCursor CURSOR FAST_FORWARD FOR

SELECT 	p1.[ID],
		p1.[PatternNumber],
		p1.[InactivePattern],
		p1.[OriginRef],
		p1.[ItemID],
		p1.[SubItemID],
		p1.[GenderID],
		p1.[AgeGroupID],
		p1.[SizeSetID],
		p1.[NickName],
		p1.[OtherCategoryID],
		p1.[OtherCategories],
		p1.[PrintTypeID],
		p1.[Keywords],
		p1.[CorPattern],
		p1.[JKDescription],
		p1.[Consumption],
		p1.[Notes],
		p1.[DateCreated],
		p1.[SpecialAttributes]		
FROM OPS1.dbo.tbl_Pattern p1   
	 LEFT OUTER JOIN OPS.dbo.tbl_Pattern p2
	 ON p1.PatternNumber COLLATE DATABASE_DEFAULT = p2.patternNumber COLLATE DATABASE_DEFAULT
WHERE p2.PatternNumber IS NULL
  
OPEN NewReplacePatternCursor 
	FETCH NEXT FROM NewReplacePatternCursor INTO  @ID, @PatternNumber, @InactivePattern , @OriginRef, @ItemID, @SubItemID,
										   @GenderID, @AgeGroupID,@SizeSetID, @NickName, @OtherCategoryID, @OtherCategories										  ,@PrintTypeID, @Keywords, @CorPattern, @JKDescription, @Consumption, @Notes, 
										   @DateCreated, @SpecialAttributes 
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
		INSERT INTO Indico.dbo.Pattern (Item, SubItem,  Gender, AgeGroup, SizeSet,CoreCategory,	PrinterType, Number,											OriginRef, NickName,Keywords, CorePattern, FactoryDescription, Consumption,												ConvertionFactor, SpecialAttributes, PatternNotes,PriceRemarks,IsActive, Creator,										CreatedDate, Modifier, ModifiedDate, Remarks, IsTemplate,Parent,GarmentSpecStatus)
		
		VALUES(
						(SELECT TOP 1 ID FROM Indico.dbo.Item ii WHERE ii.Name COLLATE DATABASE_DEFAULT =
														(SELECT Name FROM OPS1.dbo.tbl_Item oi 
															         WHERE oi.ID = @ItemID )
																AND ii.Parent IS NULL) , -- Item
			   ISNULL(( SELECT TOP 1 ID				-- SubItem
						FROM Indico.dbo.Item ii 
						WHERE ii.Name COLLATE DATABASE_DEFAULT = (	SELECT TOP 1 osi.Name 
											FROM OPS1.dbo.tbl_SubItem osi	
											WHERE osi.ID = @SubItemID) AND ii.Name IS NOT NULL), 36),
			   
													
			   (	SELECT TOP 1 ID						-- Gender
					FROM Indico.dbo.Gender ig			
					WHERE ig.Name COLLATE DATABASE_DEFAULT = (	SELECT og.Name 
										FROM OPS1.dbo.tbl_Gender og 
										WHERE og.ID = @GenderID)),		
			   (	SELECT TOP 1 ID							-- AgeGroup
					FROM Indico.dbo.AgeGroup ia 
					WHERE ia.Name COLLATE DATABASE_DEFAULT = (	SELECT oa.Name 
									FROM OPS1.dbo.tbl_AgeGroup oa 
									WHERE oa.ID = @AgeGroupID)) , 
			   (	SELECT TOP 1 ID							-- SizeSet
					FROM Indico.dbo.SizeSet iis 
					WHERE iis.Name COLLATE DATABASE_DEFAULT = (	SELECT oss.Name 
										FROM OPS1.dbo.tbl_SizeSet oss 
										WHERE oss.ID = @SizeSetID)) ,
				ISNULL((SELECT TOP 1 ID						-- Category
						FROM Indico.dbo.Category ic 
						WHERE ic.Name COLLATE DATABASE_DEFAULT = (	SELECT osc.Name 
											FROM OPS1.dbo.tbl_SportsCategory osc
											WHERE osc.ID = @OtherCategoryID)), 1), 
				ISNULL((SELECT TOP 1  ip.ID					-- PrinterType
						FROM Indico.dbo.PrinterType ip 
						WHERE ip.Name COLLATE DATABASE_DEFAULT = (	SELECT opt.Name 
											FROM OPS1.dbo.tbl_PrintType opt 
											WHERE opt.ID = @PrintTypeID)),3),	
				(SELECT op.PatternNumber FROM OPS1.dbo.tbl_Pattern op WHERE op.ID = @ID),
				ISNULL(@OriginRef, 0), 
				@NickName,
				@Keywords,
				@CorPattern,
				NULL, 
				@Consumption,
				ISNULL((SELECT TOP 1 FOBPrice				-- ConvertionFactor
						FROM OPS.dbo.tbl_Prices tp 
						WHERE tp.PatternID = @ID), 0.00), 
				@SpecialAttributes, 
				@Notes, 
				ISNULL((SELECT TOP 1 Remarks				-- PriceRemarks
						FROM OPS.dbo.tbl_Prices tp 
						WHERE tp.PatternID = @ID) , ''), 
				@InactivePattern, 
			    1 ,		---THIS INSERT STATMENT HAVE SOME ISSUES CORECATEGORY , PRINTER TYPE ,SUBITEM
			    @DateCreated , 
			    1 , 
			   (SELECT GETDATE()),
			    NULL , 
			    1 ,
			    NULL  , 
			    'Not Completed')
			    
			    INSERT INTO [Indico].[dbo].[PatternMapping]([NewId]  ,[OldId])
				VALUES(SCOPE_IDENTITY(), @ID)								

			FETCH NEXT FROM NewReplacePatternCursor INTO  @ID, @PatternNumber, @InactivePattern , @OriginRef, @ItemID, 
														  @SubItemID, @GenderID, @AgeGroupID,@SizeSetID, @NickName, 
														  @OtherCategoryID, @OtherCategories, @PrintTypeID, @Keywords, 
														  @CorPattern, @JKDescription, @Consumption, @Notes, @DateCreated,														  @SpecialAttributes 
	END 

CLOSE NewReplacePatternCursor 
DEALLOCATE NewReplacePatternCursor
-----/-----------
GO

---------Price and PriceLevelCost--------
SET NOCOUNT ON
DECLARE @priceLeveLCost TABLE (
	[Price] [int] NULL,
	[PriceLevel] [int] NULL,
	[FactoryCost] [decimal](8, 2) NULL,
	[IndimanCost] [decimal](8, 2) NULL
)
DECLARE @Price TABLE (
	[Pattern] [int] NULL,
	[FabricCode] [int] NULL,
	[Creator] [int] NULL,
	[CreatedDate] [datetime2](7) NULL,
	[Modifier] [int] NOT NULL,
	[ModifiedDate] [datetime2](7) NULL
)


DECLARE @ID AS int
DECLARE @PatternID AS int
DECLARE @FabricID AS int
DECLARE @Cost AS int
DECLARE @found AS int
DECLARE @Count AS int
--DECLARE @priceLevelCostID AS int
DECLARE PriceCursor CURSOR FAST_FORWARD FOR
 
  SELECT [ID]
		,[PatternID]
		,[FabricID]
		,[Cost]		
  FROM [OPS].[dbo].[tbl_Prices]
  
OPEN PriceCursor 
	FETCH NEXT FROM PriceCursor INTO @ID , @PatternID , @FabricID , @Cost 
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		DECLARE @priceID  int
		
		SET @found = 1
		
		IF(EXISTS (SELECT ID FROM OPS.dbo.tbl_Pattern WHERE ID = @PatternID)
		   AND EXISTS (SELECT ID FROM OPS.dbo.tbl_FabricCodes WHERE ID = @FabricID))
		BEGIN 
		
			INSERT INTO Indico.dbo.Price(Pattern , FabricCode ,Creator ,CreatedDate , Modifier ,											 ModifiedDate)
			VALUES ((SELECT TOP 1 ID  FROM Indico.dbo.Pattern ip WHERE ip.Number = (
								SELECT TOP 1 op.PatternNumber  
								FROM OPS.dbo.tbl_Pattern op 
								WHERE op.ID = @PatternID)),
				 (SELECT TOP 1 ID FROM Indico.dbo.FabricCode iif WHERE iif.Name = (
								SELECT TOP 1 ofb.Name  
								FROM OPS.dbo.tbl_FabricCodes ofb
								WHERE ofb.ID = @FabricID)),
				1,
				(SELECT GETDATE()) ,
				1,
				(SELECT GETDATE())
				)
				
				SET @priceID = SCOPE_IDENTITY()
				
			SET @Count = 1	
			WHILE (@Count <= 8)
			BEGIN
			
				INSERT INTO @priceLeveLCost(Price , PriceLevel , FactoryCost , IndimanCost) 
				VALUES (@priceID,
						@Count,
						ISNULL((SELECT TOP 1 opj.Cost  FROM OPS.dbo.tbl_PricesJK opj
													   WHERE opj.FabricID = @FabricID 
															AND opj.PatternID = @PatternID),0.00),
								(SELECT TOP 1 opr.Cost FROM OPS.dbo.tbl_Prices opr 
									 WHERE opr.PatternID = @PatternID 
											AND opr.FabricID = @FabricID)
						)
						
				SET @Count = @Count + 1					
			END
		END
		FETCH NEXT FROM PriceCursor INTO  @ID, @PatternID , @FabricID, @Cost
	END 
INSERT INTO Indico.dbo.PriceLevelCost 
SELECT * FROM @priceLeveLCost
CLOSE PriceCursor 
DEALLOCATE PriceCursor
-----/--------
GO

----****** DistributorPriceLevelCost ******--
DECLARE @DistributorPriceLevelCost TABLE 
(
	[Distributor] [int] NULL,
	[PriceTerm] [int] NULL,
	[PriceLevelCost] [int] NULL,
	[IndicoCost] [decimal](8,2) NULL
)

----/****** Object:  Index [IX_ID]    Script Date: 07/15/2012 22:15:37 ******/
--IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[OPS].[dbo].[tbl_SpecialPrices]') AND name = N'IX_ID')
--DROP INDEX [IX_ID] ON [OPS].[dbo].[tbl_SpecialPrices] WITH ( ONLINE = OFF )
--GO

--CREATE CLUSTERED INDEX IX_ID
--	ON [OPS].[dbo].[tbl_SpecialPrices] (ID)
--GO

--/****** Object:  Index [IX_ALL]    Script Date: 07/15/2012 22:15:51 ******/
--IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[OPS].[dbo].[tbl_SpecialPrices]') AND name = N'IX_ALL')
--DROP INDEX [IX_ALL] ON [OPS].[dbo].[tbl_SpecialPrices] WITH ( ONLINE = OFF )
--GO

--CREATE NONCLUSTERED INDEX IX_ALL
--	ON [OPS].[dbo].[tbl_SpecialPrices] (PATID, FABID, SPLID, PLID)
--GO

CREATE NONCLUSTERED INDEX IX_FM_NEW_OLD
	ON [Indico].[dbo].[FabricMapping] ([NewId], [OldId])
	
CREATE NONCLUSTERED INDEX IX_PM_NEW_OLD
	ON [Indico].[dbo].[PatternMapping] ([NewId], [OldId])
GO

/****** Object:  Index [IX_Distributor_PriceLevel]    Script Date: 07/15/2012 22:14:11 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Indico].[dbo].[DistributorPriceMarkup]') AND name = N'IX_DistributorPriceMarkup_Distributor_PriceLevel')
DROP INDEX [IX_DistributorPriceMarkup_Distributor_PriceLevel] ON [Indico].[dbo].[DistributorPriceMarkup] WITH ( ONLINE = OFF )
GO

CREATE NONCLUSTERED INDEX IX_DistributorPriceMarkup_Distributor_PriceLevel
	ON [Indico].[dbo].[DistributorPriceMarkup] ([Distributor], [PriceLevel])
GO

/****** Object:  Index [IX_Distributor_PriceTerm_PriceLevelCost]    Script Date: 07/15/2012 22:13:03 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Indico].[dbo].[DistributorPriceLevelCost]') AND name = N'IX_DistributorPriceLevelCost_Distributor_PriceTerm_PriceLevelCost')
DROP INDEX [IX_DistributorPriceLevelCost_Distributor_PriceTerm_PriceLevelCost] ON [Indico].[dbo].[DistributorPriceLevelCost] WITH ( ONLINE = OFF )
GO

CREATE NONCLUSTERED INDEX IX_DistributorPriceLevelCost_Distributor_PriceTerm_PriceLevelCost
	ON [Indico].[dbo].[DistributorPriceLevelCost] ([Distributor], [PriceTerm], [PriceLevelCost])
GO

/****** Object:  Index [IX_Pattern_FabricCode]    Script Date: 07/15/2012 22:11:46 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Indico].[dbo].[Price]') AND name = N'IX_Price_Pattern_FabricCode')
DROP INDEX [IX_Price_Pattern_FabricCode] ON [Indico].[dbo].[Price] WITH ( ONLINE = OFF )
GO

CREATE NONCLUSTERED INDEX IX_Price_Pattern_FabricCode
	ON [Indico].[dbo].[Price] ([Pattern], [FabricCode])
GO

--SELECT idplc.ID AS 'DistributorPriceLevelCost' , idplc.Distributor, p.ID AS Pattern, f.ID AS Fabric, ip.ID AS Price, idplc.IndicoCost, 
--				ipl.ID AS 'PriceLevelCost', p.Number AS 'PatternNumber', idplc.PriceTerm, ipl.PriceLevel
--			FROM Indico.dbo.PriceLevelCost ipl
--				JOIN Indico.dbo.Price ip
--					 ON ipl.Price = ip.ID
--				JOIN Indico.dbo.DistributorPriceLevelCost idplc
--					 ON ipl.ID = idplc.PriceLevelCost
--				JOIN Indico.dbo.FabricCode f
--					 ON f.ID = ip.FabricCode
--				JOIN Indico.dbo.Pattern p
--					 ON p.ID = ip.Pattern 
--			WHERE p.Number = '052'

/****** Object:  Table [dbo].[tbl_SpecialPrices]    Script Date: 07/15/2012 22:57:14 ******/

DECLARE @tbl_NeededSpecialPrices TABLE 
(
	[ID] [int] NULL,
	[SPLID] [int] NULL,
	[PATID] [int] NULL,
	[SIID] [int] NULL,
	[FABID] [int] NULL,
	[TERM] [nvarchar](3) NULL,
	[Value] [decimal](18,2) NULL,
	[PLID] [int] NULL,
	[LastModified] [datetime] NULL,
	[indinotes] [nvarchar](MAX) NULL
)

DECLARE @ID AS int
DECLARE @SPLID AS int
DECLARE @PATID AS int 
DECLARE @FABID AS int
DECLARE @TERM AS nvarchar (255)
DECLARE @Value AS decimal (18,2)
DECLARE @PLID AS int
DECLARE @LastModified AS datetime

--**** Group by and pick the needed records **----

DECLARE TempCursor CURSOR FAST_FORWARD FOR 
	SELECT  SPLID, PATID, FABID, TERM, PLID 
	FROM [OPS].[dbo].[tbl_SpecialPrices]
	GROUP BY  SPLID, PATID, FABID, PLID, TERM
	ORDER BY  SPLID, PATID, FABID, PLID, TERM 

OPEN TempCursor 
	FETCH NEXT FROM TempCursor INTO @SPLID , @PATID , @FABID , @TERM, @PLID
	
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
		INSERT INTO @tbl_NeededSpecialPrices ([ID], [SPLID], [PATID], [SIID], [FABID], [TERM], [Value], [PLID],													      [LastModified],[indinotes])
		SELECT TOP 1 ID, [SPLID], [PATID], [SIID], FABID, TERM, [Value], [PLID], [LastModified], [indinotes]
		FROM [OPS].[dbo].[tbl_SpecialPrices]
		WHERE PATID = @PATID AND FABID = @FABID AND SPLID = @SPLID AND TERM = @TERM AND [PLID] = @PLID
		ORDER BY  SPLID, PATID, FABID, PLID, TERM, [LastModified] DESC 
		
		FETCH NEXT FROM TempCursor INTO @SPLID , @PATID , @FABID , @TERM, @PLID
	END 
	
CLOSE TempCursor 
DEALLOCATE TempCursor

-- **** Now add the changed prices ***---
DECLARE @PriceLevelCost int
DECLARE PriceMarkupCursor CURSOR FAST_FORWARD FOR 
SELECT [ID]
	  ,[SPLID]
	  ,[PATID]
	  ,[FABID]
	  ,[TERM]
	  ,[Value] 
	  ,[PLID]
	  ,[LastModified]
FROM @tbl_NeededSpecialPrices
  
OPEN PriceMarkupCursor 
	FETCH NEXT FROM PriceMarkupCursor INTO @ID, @SPLID , @PATID , @FABID , @TERM , @Value, @PLID, @LastModified
	
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		BEGIN TRY
		
		SET @PriceLevelCost = (	SELECT TOP 1 plc.ID 
								FROM Indico.dbo.PriceLevelCost plc
									JOIN Indico.dbo.Price p
										ON p.ID = plc.Price 
									JOIN [Indico].[dbo].PatternMapping pm
										ON p.Pattern = pm.[NewId]
									JOIN [Indico].[dbo].FabricMapping fm
										ON p.FabricCode = fm.[NewId]		
							WHERE (pm.OldId = @PATID AND fm.OldId = @FABID 
															AND plc.PriceLevel = (SELECT pl.ID 
															FROM Indico.dbo.PriceLevel pl 
															WHERE pl.Name =(SELECT Name 
															FROM OPS.dbo.tbl_PriceLevel	opl 
															WHERE opl.ID = @PLID))))
		IF (@PriceLevelCost != 0 AND  @PriceLevelCost IS NOT NULL)
		BEGIN
			INSERT INTO Indico.dbo.DistributorPriceLevelCost (Distributor, PriceTerm, PriceLevelCost,																	  IndicoCost,ModifiedDate, Modifier)
					VALUES(
							(	SELECT TOP 1 ic.ID
								FROM Indico.dbo.Company ic
									JOIN OPS.dbo.tbl_Contact oc
										ON ic.Name = oc.CompanyName
								WHERE oc.CompanyName =(SELECT TOP 1 Name FROM OPS.dbo.tbl_SpecialPrice sp 
								WHERE sp.ID = @SPLID)AND oc.ContactTypeID = 5), 
								
							(	SELECT ID 
								FROM Indico.dbo.PriceTerm pt
								WHERE pt.Name = @TERM),
							@PriceLevelCost,
							@Value,
							@LastModified,
							1
					)
					
					INSERT INTO Indico.dbo.TEMPDistributorPriceLevelCost(ID)
					VALUES(@ID)
					
				END
			END TRY
			BEGIN CATCH
				PRINT @PATID
				PRINT @FABID
				PRINT @PLID
				SELECT 'There was an error! ' + ERROR_MESSAGE()
				--CONTINUE;
			END CATCH	
	
		FETCH NEXT FROM PriceMarkupCursor INTO @ID, @SPLID , @PATID , @FABID , @TERM , @Value, @PLID, 
											   @LastModified
	END 
	
CLOSE PriceMarkupCursor 
DEALLOCATE PriceMarkupCursor		
-----/--------
GO
------------Create DistributorPriceLevelCostHistory-----
DECLARE @ID AS int
DECLARE @SPLID AS int
DECLARE @PATID AS int 
DECLARE @FABID AS int
DECLARE @TERM AS nvarchar (255)
DECLARE @Value AS decimal (8,2)
DECLARE @PLID AS int
DECLARE @LastModified AS datetime
DECLARE @PriceLevelCost int

DECLARE PriceMarkupHistoryCursor CURSOR FAST_FORWARD FOR 
SELECT [SPLID]
      ,[PATID]
      ,[FABID]
      ,[TERM]
      ,[Value]
      ,[PLID]
      ,[LastModified]
FROM [OPS].[dbo].[tbl_SpecialPrices] sp
	LEFT OUTER JOIN  Indico.dbo.TEMPDistributorPriceLevelCost t
		ON sp.ID = t.ID
WHERE t.ID IS NULL	
  
OPEN PriceMarkupHistoryCursor 
	FETCH NEXT FROM PriceMarkupHistoryCursor INTO @SPLID , @PATID , @FABID , @TERM , @Value, @PLID, @LastModified
	
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		BEGIN TRY
		
		SET @PriceLevelCost = (	SELECT TOP 1 plc.ID 
								FROM Indico.dbo.PriceLevelCost plc
									JOIN Indico.dbo.Price p
										ON p.ID = plc.Price 
									JOIN [Indico].[dbo].PatternMapping pm
										ON p.Pattern = pm.[NewId]
									JOIN [Indico].[dbo].FabricMapping fm
										ON p.FabricCode = fm.[NewId]		
								WHERE (pm.OldId = @PATID AND fm.OldId = @FABID AND plc.PriceLevel = 
															(SELECT pl.ID FROM Indico.dbo.PriceLevel pl 
																		  WHERE pl.Name =(SELECT Name 
																		  FROM OPS.dbo.tbl_PriceLevel	opl 
																		  WHERE opl.ID = @PLID))))
		IF (@PriceLevelCost != 0 AND  @PriceLevelCost IS NOT NULL)
		BEGIN
			INSERT INTO Indico.dbo.DistributorPriceLevelCostHistory(Distributor, PriceTerm, PriceLevelCost,																				IndicoCost,ModifiedDate, Modifier)
					VALUES(
							(	SELECT TOP 1 ic.ID
								FROM Indico.dbo.Company ic
									JOIN OPS.dbo.tbl_Contact oc
										ON ic.Name = oc.CompanyName
								WHERE oc.CompanyName =(SELECT TOP 1 Name FROM OPS.dbo.tbl_SpecialPrice sp 
								WHERE sp.ID = @SPLID)AND oc.ContactTypeID = 5), 
								
							(	SELECT ID 
								FROM Indico.dbo.PriceTerm pt
								WHERE pt.Name = @TERM),
							@PriceLevelCost,
							@Value,
							@LastModified,
							1
						)
				END
			END TRY
			BEGIN CATCH
				PRINT @PATID
				PRINT @FABID
				PRINT @PLID
				SELECT 'There was an error! ' + ERROR_MESSAGE()
				--CONTINUE;
			END CATCH	
	
		FETCH NEXT FROM PriceMarkupHistoryCursor INTO @SPLID , @PATID , @FABID , @TERM , @Value, @PLID, @LastModified
	END 
	
CLOSE PriceMarkupHistoryCursor 
DEALLOCATE PriceMarkupHistoryCursor
--/**************\---------------
GO


------MeasurmentLocation---------

	INSERT INTO Indico.dbo.MeasurementLocation (Item , [Key] ,Name )
		SELECT (SELECT ID FROM Indico.dbo.Item ii WHERE ii.Name = oi.Name AND ii.Parent  IS NULL),
		om.[Key] ,
		om.Name 
	FROM OPS.dbo.tbl_MeasurementLocation om
		JOIN OPS.dbo.tbl_Item oi
			ON oi.ID = om.ItemId 
-------/-------
GO

------SizeChart---------
UPDATE OPS.dbo.tbl_SizeChart SET Val = 0.0 WHERE Val IS NULL OR Val = ''

	INSERT INTO  Indico.dbo.SizeChart (Pattern ,MeasurementLocation , Size , Val)
	SELECT (SELECT ID FROM Indico.dbo.Pattern ip WHERE ip.Number = op.PatternNumber),
		   (SELECT TOP 1 ID FROM Indico.dbo.MeasurementLocation im WHERE im.Name = om.Name),
		   (SELECT TOP 1 ID FROM Indico.dbo.Size iss WHERE iss.SizeName = oss.Size),
		   (SELECT CAST (osc.Val AS DECIMAL))		 
	FROM OPS.dbo.tbl_SizeChart osc	
			JOIN OPS.dbo.tbl_Pattern op
				ON op.ID = osc.PatternID
			JOIN OPS.dbo.tbl_MeasurementLocation  om
				ON om.ID = osc.MLocationID
			JOIN OPS.dbo.tbl_Sizes oss 
				ON osc.SizeID = oss.ID	
------/----------
GO

------PatternOtherCategory------
Delete from Indico.dbo.PatternOtherCategory
		
DECLARE @ID AS int
DECLARE @CurrentID AS int
DECLARE @OtherCategories AS nvarchar(255) 
DECLARE PatternCursor CURSOR FAST_FORWARD FOR 
		SELECT ID, OtherCategories 
		FROM OPS.dbo.tbl_Pattern 
OPEN PatternCursor 
	FETCH NEXT FROM PatternCursor INTO @ID, @OtherCategories 
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		-- Add other categories 
		IF (@OtherCategories != NULL OR @OtherCategories != '')
			BEGIN
				SET @CurrentID = (SELECT p1.ID 
											FROM Indico.dbo.Pattern p1 
											WHERE p1.Number = (SELECT PatternNumber					
																FROM OPS.dbo.tbl_Pattern 
																WHERE ID = @ID))

				INSERT INTO Indico.dbo.PatternOtherCategory (Pattern ,Category)
				SELECT @CurrentID, c.ID 
				FROM Indico.dbo.Category c
				WHERE c.Name IN (	SELECT sc.Name 
									FROM OPS.dbo.tbl_SportsCategory sc 
									WHERE CAST(sc.ID AS nvarchar(255)) IN (SELECT Data 
										FROM [Indico].[dbo].[Split](@OtherCategories, ',')))			
			END
		
		FETCH NEXT FROM PatternCursor INTO @ID, @OtherCategories 
	END 

CLOSE PatternCursor 
DEALLOCATE PatternCursor		
-----/--------
GO

-----Users------- 
UPDATE OPS.dbo.tbl_User  SET Username = 'username'  WHERE Username = NULL OR Username =''
UPDATE OPS.dbo.tbl_User  SET [Last Name] = 'lastname'  WHERE [Last Name] = NULL OR [Last Name] =''

DECLARE @FirstName  AS nvarchar(255)
DECLARE @LastName  AS nvarchar(255)
DECLARE @UserName AS nvarchar(255) 
DECLARE @Company AS int
DECLARE @isDistributor AS bit
DECLARE @userID AS int 
SET @userID = (SELECT COUNT(*) FROM OPS.dbo.tbl_User)
DECLARE UserCursor CURSOR FAST_FORWARD FOR 
		SELECT [First Name] ,
			   [Last Name] ,
			   Username
		FROM OPS.dbo.tbl_User 
OPEN UserCursor 
	FETCH NEXT FROM UserCursor INTO @FirstName, @LastName, @UserName 
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	WHILE 0 < @userID 
		BEGIN
		SET @Company = (SELECT (SELECT TOP 1 ID FROM Indico.dbo.Company c WHERE c.Name = 
											(SELECT TOP	1 oc.CompanyName FROM OPS.dbo.tbl_Contact oc																		WHERE oc.ID = ou.distributerID
													AND oc.ContactTypeID = 5)) 
															FROM OPS.dbo.tbl_User ou	
															WHERE ou.ID = @userID)							
		SET @isDistributor = (SELECT TOP 1 CASE WHEN u.distributerID > 0 THEN 1 ELSE 0 END  AS tt														FROM OPS.dbo.tbl_User u	WHERE u.ID = @userID)
		
			
					INSERT INTO Indico.dbo.[User] ([Company],IsDistributor,[Status],Username , [Password],GivenName ,														FamilyName ,EmailAddress,PhotoPath ,Creator ,CreatedDate ,Modifier,													    ModifiedDate ,IsActive,IsDeleted ,[Guid],OfficeTelephoneNumber ,														MobileTelephoneNumber ,HomeTelephoneNumber ,DateLastLogin)
						SELECT		  ISNULL(@Company,2) AS Company ,
									  @isDistributor AS IsDistributor ,
									  REPLACE(ou.Status,0,2) AS 'Status' , 
									  REPLACE( ou.Username, '' ,'username') AS 'UserName' ,
									  CONVERT(varchar(255),
									  HashBytes('SHA1', 'password')),
									  ou.[First Name] , 
									  ISNULL(ou.[Last Name] , 'LastName') AS LastName, 
								      'noreply@indico.com' ,
								      NULL ,
								      1 'Creator', 
									  (SELECT GETDATE())'CreatedDate' , 
									  1 'Modifier', 
									 (SELECT GETDATE()) AS 'ModifierDate' ,
									  1 AS 'ISActive',
									  0 AS 'IsDelete',
									  NULL AS 'GUID' ,
									  123456 AS 'OFFICETEL', 
									  NULL AS 'MOBILETEL', 
									  NULL AS 'HOMETEL',
									  NULL AS 'DateLastLogin'      
						FROM OPS.dbo.tbl_User ou WHERE ou.ID = @userID
						
		FETCH NEXT FROM UserCursor INTO @FirstName, @LastName, @UserName
		SET @userID = @userID -1
		END
	END 

CLOSE UserCursor 
DEALLOCATE UserCursor		
-----/--------
GO

----from Employee table to User table-------

DECLARE @FirstName  AS nvarchar(255)
DECLARE @LastName  AS nvarchar(255) 
DECLARE @Email AS nvarchar(255)
DECLARE @Company AS int
DECLARE @empid AS int
DECLARE @empCount AS int 
SET @empCount = (SELECT COUNT(*) FROM OPS.dbo.tbl_Employee)
DECLARE UserCursor CURSOR FAST_FORWARD FOR 
		SELECT oe.FirstName , oe.LastName , oe.Email  
		FROM OPS.dbo.tbl_Employee oe
OPEN UserCursor 
	FETCH NEXT FROM UserCursor INTO @FirstName, @LastName , @Email
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	WHILE 0 < @empCount 
		BEGIN
		SET @empid = (SELECT  (SELECT ID FROM(SELECT ROW_NUMBER ()OVER(ORDER BY id)AS row ,ID 
											FROM OPS.dbo.tbl_Employee)	_table WHERE row =@empCount))
			
		SET @Company = (SELECT top 1 (SELECT TOP 1  ID FROM Indico.dbo.Company ic 
												 WHERE ic.Name = oe.CompanyName) 
												 FROM OPS.dbo.tbl_Employee oe WHERE oe.ID = @empid)				
		
		
				INSERT INTO Indico.dbo.[User] ([Company],IsDistributor,[Status],Username ,[Password],GivenName											   ,FamilyName ,EmailAddress,PhotoPath ,Creator ,CreatedDate ,													Modifier,ModifiedDate ,IsActive,IsDeleted ,[Guid],															OfficeTelephoneNumber ,	MobileTelephoneNumber ,																HomeTelephoneNumber ,DateLastLogin)
						SELECT		  ISNULL(@Company,2) AS Company ,
									  1 AS Distributor ,
									  1 AS 'Status' , 
									  'username' AS 'UserName' ,
									  CONVERT(varchar(255),HashBytes('SHA1', 'password')),
									  ISNULL(oe.FirstName ,'noname') , 
									  ISNULL(oe.LastName  , 'noname') AS LastName, 
								      ISNULL(oe.Email,'noreply@indico.com' ),
								      NULL ,
								      1 'Creator', 
									  (SELECT GETDATE())'CreatedDate' , 
									  1 'Modifier', 
									 (SELECT GETDATE()) AS 'ModifierDate' ,
									  1 AS 'ISActive',
									  0 AS 'IsDelete',
									  NULL AS 'GUID' ,
									  ISNULL(oe.ContactTel1,'123456') AS 'OFFICETEL', 
									  oe.ContactTel2 AS 'MOBILETEL', 
									  NULL AS 'HOMETEL',
									  NULL AS 'DateLastLogin'      
						FROM OPS.dbo.tbl_Employee oe WHERE oe.ID = @empid
						
		FETCH NEXT FROM UserCursor INTO @FirstName, @LastName , @Email
		SET @empCount = @empCount -1
		END
	END 

CLOSE UserCursor 
DEALLOCATE UserCursor		
-----/--------
GO

-----Visual Layout---------
SET NOCOUNT ON

DECLARE @VisualLayout TABLE(
	[Name] [nvarchar](64) NULL,
	[Description] [nvarchar](512) NULL,
	[Pattern] [int] NULL,
	[FabricCode] [int]  NULL,
	[Client] [int] NULL,
	[Coordinator] [int] NULL,
	[Distributor] [int]  NULL,
	[NNPFilePath] [nvarchar](512) NULL
	)

DECLARE @Id AS int
DECLARE @ProductNumber  AS nvarchar(255)
DECLARE @PatternId AS int
DECLARE @ResolutionProfileID AS int
DECLARE @ColourProfileID AS int
DECLARE @ContactID AS int 
DECLARE @PrinterID AS int
DECLARE @DateCreated AS DATETIME
DECLARE @Notes  AS nvarchar(255)
DECLARE @FabricCodesID AS int
DECLARE @EmployeeID AS int
DECLARE @DistributorID AS int
DECLARE @found AS bit
DECLARE @VisualLayoutID AS int
DECLARE VisualLayoutCursor CURSOR FAST_FORWARD FOR 
	SELECT	op.[ID]
      ,op.[ProductNumber]
      ,op.[PatternID]
      ,op.[ResolutionProfileID]
      ,op.[ColourProfileID]
      ,op.[ContactID]
      ,op.[Notes]
      ,op.[DateCreated]
      ,op.[FabricCodesID]
      ,op.[DistributorID]
      ,op.[EmployeeID]
      ,op.[PrinterID] 
	FROM OPS.dbo.tbl_Product op
	ORDER BY op.[ProductNumber], op.[DateCreated]
OPEN VisualLayoutCursor 
	FETCH NEXT FROM VisualLayoutCursor INTO @Id, @ProductNumber, @PatternId, @ResolutionProfileID, 
											@ColourProfileID,@ContactID, @Notes, @DateCreated, 
											@FabricCodesID, @DistributorID, 
											@EmployeeID, @PrinterID
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
		SET @found = 1 
		
		IF (EXISTS(SELECT ID FROM OPS.dbo.tbl_Pattern WHERE ID = @PatternId)
			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_Contact WHERE ID = @ContactID)
			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_FabricCodes WHERE ID = @FabricCodesID)
			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_Contact WHERE ID = @DistributorID AND ContactTypeID = 5)
			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_Employee WHERE ID = @EmployeeID))
		BEGIN
			INSERT INTO Indico.dbo.VisualLayout(Name , [Description] , Pattern , FabricCode , Client ,																	Coordinator , Distributor , NNPFilePath )
			VALUES (@ProductNumber, @Notes,
				 (SELECT TOP 1 ID FROM Indico.dbo.Pattern ip WHERE ip.Number = (
						SELECT TOP 1 opa.PatternNumber 
						FROM OPS.dbo.tbl_Pattern opa
						WHERE opa.ID = @PatternId)),
				(SELECT TOP 1  ID FROM Indico.dbo.FabricCode iif WHERE iif.Name = (
						SELECT TOP 1 ofa.Name 
						FROM OPS.dbo.tbl_FabricCodes ofa
						WHERE ofa.ID = @FabricCodesID)),
				(SELECT TOP 1 ID FROM Indico.dbo.Client ic WHERE ic.Name =(
						SELECT TOP 1  oc.CompanyName
						FROM OPS.dbo.tbl_Contact oc									
						WHERE oc.ID = @ContactID)),
				(SELECT TOP 1 ID FROM Indico.dbo.[User] iu WHERE iu.ID = (
						 SELECT TOP 1 ie.ID 
						 FROM OPS.dbo.tbl_Employee ie
						 WHERE ie.ID = @EmployeeID)),
				(SELECT TOP 1 ID FROM Indico.dbo.Company ic WHERE ic.Name = ( 
						 SELECT TOP 1 oc.CompanyName
						 FROM OPS.dbo.tbl_Contact oc
						 WHERE oc.ID = @DistributorID
						 AND oc.ContactTypeID = 5)),
				NULL)
				
				SET @VisualLayoutID = SCOPE_IDENTITY()
				--PRINT @VisualLayoutID
				INSERT INTO [Indico].[dbo].[VisualLayoutMapping]([NewId],[OldId])
				VALUES(@VisualLayoutID,@Id)
		END
			  
		FETCH NEXT FROM VisualLayoutCursor INTO @Id, @ProductNumber, @PatternId, @ResolutionProfileID ,
												@ColourProfileID, @ContactID, @Notes, @DateCreated,
												@FabricCodesID, @DistributorID,	@EmployeeID, @PrinterID	
END 

CLOSE VisualLayoutCursor 
DEALLOCATE VisualLayoutCursor
	
GO

-----Visual Layout-----
--SET NOCOUNT ON

--DECLARE @VisualLayout TABLE(
--	[Name] [nvarchar](64) NULL,
--	[Description] [nvarchar](512) NULL,
--	[Pattern] [int] NULL,
--	[FabricCode] [int]  NULL,
--	[Client] [int] NULL,
--	[Coordinator] [int] NULL,
--	[Distributor] [int]  NULL,
--	[NNPFilePath] [nvarchar](512) NULL
--	)

--DECLARE @Id AS int
--DECLARE @ProductNumber  AS nvarchar(255)
--DECLARE @PatternId AS int
--DECLARE @ResolutionProfileID AS int
--DECLARE @ColourProfileID AS int
--DECLARE @ContactID AS int 
--DECLARE @PrinterID AS int
--DECLARE @DateCreated AS DATETIME
--DECLARE @Notes  AS nvarchar(255)
--DECLARE @FabricCodesID AS int
--DECLARE @EmployeeID AS int
--DECLARE @DistributorID AS int
--DECLARE @found AS bit
--DECLARE VisualLayoutCursor CURSOR FAST_FORWARD FOR 
--	SELECT	op.[ID]
--      ,op.[ProductNumber]
--      ,op.[PatternID]
--      ,op.[ResolutionProfileID]
--      ,op.[ColourProfileID]
--      ,op.[ContactID]
--      ,op.[Notes]
--      ,op.[DateCreated]
--      ,op.[FabricCodesID]
--      ,op.[DistributorID]
--      ,op.[EmployeeID]
--      ,op.[PrinterID] 
--	FROM OPS.dbo.tbl_Product op
--	ORDER BY op.[ProductNumber], op.[DateCreated]
--OPEN VisualLayoutCursor 
--	FETCH NEXT FROM VisualLayoutCursor INTO @Id, @ProductNumber, @PatternId, @ResolutionProfileID, @ColourProfileID,												@ContactID, @Notes, @DateCreated, @FabricCodesID, @DistributorID, 
--											@EmployeeID, @PrinterID
--	WHILE @@FETCH_STATUS = 0 
--	BEGIN 
	
--		SET @found = 1 
		
--		IF (EXISTS(SELECT ID FROM OPS.dbo.tbl_Pattern WHERE ID = @PatternId)
--			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_Contact WHERE ID = @ContactID)
--			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_FabricCodes WHERE ID = @FabricCodesID)
--			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_Distributor WHERE ID = @DistributorID)
--			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_Employee WHERE ID = @EmployeeID))
--		BEGIN
--			INSERT INTO @VisualLayout (Name , [Description] , Pattern , FabricCode , Client , Coordinator ,													 Distributor , NNPFilePath )
--			VALUES (@ProductNumber, @Notes,
--				 (SELECT TOP 1 ID FROM Indico.dbo.Pattern ip WHERE ip.Number = (
--						SELECT TOP 1 opa.PatternNumber 
--						FROM OPS.dbo.tbl_Pattern opa
--						WHERE opa.ID = @PatternId)),
--				(SELECT TOP 1  ID FROM Indico.dbo.FabricCode iif WHERE iif.Name = (
--						SELECT TOP 1 ofa.Name 
--						FROM OPS.dbo.tbl_FabricCodes ofa
--						WHERE ofa.ID = @FabricCodesID)),
--				(SELECT TOP 1 ID FROM Indico.dbo.Client ic WHERE ic.Name =(
--						SELECT TOP 1  oc.CompanyName
--						FROM OPS.dbo.tbl_Contact oc									
--						WHERE oc.ID = @ContactID)),
--				(SELECT TOP 1 ID FROM Indico.dbo.[User] iu WHERE iu.ID = (
--						 SELECT TOP 1 ie.ID 
--						 FROM OPS.dbo.tbl_Employee ie
--						 WHERE ie.ID = @EmployeeID)),
--				(SELECT TOP 1 ID FROM Indico.dbo.Company ic WHERE ic.Name = ( 
--						 SELECT TOP 1 od.CompanyName
--						 FROM OPS.dbo.tbl_Distributor od
--						 WHERE od.ID = @DistributorID)),
--				NULL)		
--		END
			  
--		FETCH NEXT FROM VisualLayoutCursor INTO @Id, @ProductNumber, @PatternId, @ResolutionProfileID, @ColourProfileID,												@ContactID, @Notes, @DateCreated, @FabricCodesID, @DistributorID, 
--												@EmployeeID, @PrinterID	
--END 


--INSERT INTO Indico.dbo.VisualLayout 
--SELECT * FROM @VisualLayout WHERE Coordinator IS NOT NULL

--CLOSE VisualLayoutCursor 
--DEALLOCATE VisualLayoutCursor
	

--GO

--------Invoices---------
DECLARE @Invoices AS TABLE (
	[Status] [int] NULL,
	[InvoiceNo] [nvarchar](64) NULL,
	[InvoiceDate] [datetime2](7) NULL,
	[ShipTo] [nvarchar](512) NULL,
	[Value] [decimal](8, 2)NULL,
	[Freight] [decimal](8, 2) NULL,
	[OtherCost] [decimal](8, 2) NULL,
	[Discount] [decimal](8, 2) NULL,
	[NetValue] [decimal](8, 2) NULL,
	[BillTo] [int] NULL,
	[AWBNo] [nvarchar](255) NULL)

DECLARE @ID AS int
DECLARE @InvoiceNumber AS nvarchar (255)
DECLARE @InvoiceDate AS DATETIME 
DECLARE @ShipTo AS int
DECLARE @InvoiceValue AS decimal(18,0) 
DECLARE @InvoiceFreight AS decimal(18,0)
DECLARE @InvoiceOther  AS decimal(18,0)
DECLARE @InvoiceDiscount AS decimal(18,0)
DECLARE @InvoiceNet AS decimal (18,0)
DECLARE @BillTo AS int 
DECLARE @AWBNumber AS nvarchar (255)

DECLARE InvoiceCursor CURSOR FAST_FORWARD FOR 
 SELECT [ID]
      ,[InvoiceNumber]
      ,[InvoiceDate]
      ,[ShipTo]
      ,[InvoiceValue]
      ,[InvoiceFreight]
      ,[InvoiceOther]
      ,[InvoiceDiscount]
      ,[InvoiceNet]
      ,[BillTo]
      ,[AWBNumber]   
  FROM [OPS].[dbo].[tbl_Invoice] 
OPEN InvoiceCursor 
	FETCH NEXT FROM InvoiceCursor INTO @ID, @InvoiceNumber , @InvoiceDate , @ShipTo , @InvoiceValue , @InvoiceFreight,
											@InvoiceOther ,  @InvoiceDiscount , @InvoiceNet , @BillTo ,	@AWBNumber 
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		INSERT INTO @Invoices([Status] , InvoiceNo , InvoiceDate , ShipTo , Value , Freight , OtherCost , Discount ,							      NetValue ,BillTo , AWBNo)
		VALUES (3,
				@InvoiceNumber ,
				@InvoiceDate,
				@ShipTo,
				@InvoiceValue,
				@InvoiceFreight,
				@InvoiceOther, 
				@InvoiceDiscount,
				@InvoiceNet,
				ISNULL(@BillTo,0),
				CONVERT(nvarchar,@AWBNumber))
	
		FETCH NEXT FROM InvoiceCursor INTO @ID, @InvoiceNumber , @InvoiceDate , @ShipTo , @InvoiceValue , @InvoiceFreight,
										   @InvoiceOther ,  @InvoiceDiscount , @InvoiceNet , @BillTo , @AWBNumber
	END 
INSERT INTO Indico.dbo.Invoice
SELECT * FROM @Invoices
CLOSE InvoiceCursor 
DEALLOCATE InvoiceCursor		
-----/--------
GO


--BEGIN TRAN----
--DECLARE @ID AS int
--DECLARE @CompanyName AS nvarchar
--DECLARE @Title AS nvarchar(255) 
--DECLARE @FirstName AS nvarchar (255)
--DECLARE @LastName AS nvarchar (255)
--DECLARE @AddressLine1 AS nvarchar (255)
--DECLARE @AddressLine2 AS nvarchar (255)
--DECLARE @City AS nvarchar (255)
--DECLARE @State AS nvarchar (255)
--DECLARE @PostalCode AS nvarchar (255)
--DECLARE @Country AS nvarchar (255)
--DECLARE @ContactTel1 AS nvarchar (255)
--DECLARE @ContactTel2 AS nvarchar (255)
--DECLARE @Mobile AS nvarchar (255)
--DECLARE @Fax AS nvarchar (255)
--DECLARE @Email AS nvarchar (255)
--DECLARE @Web AS nvarchar (255)
--DECLARE @ContactTypeID AS int
--DECLARE @NickName AS nvarchar (255)
--DECLARE @CoordinatorID AS int
--DECLARE @EmailSent AS bit
--DECLARE @SpecialPricesCount AS int
--SET @SpecialPricesCount = (SELECT COUNT(*) FROM OPS.dbo.tbl_Contact)
--DECLARE @SpecialPriceID AS int
--DECLARE @Name AS nvarchar (255)

--DECLARE DistributorCursor CURSOR FAST_FORWARD FOR 
-- SELECT[ID]
--      ,[CompanyName]
--      ,[Title]
--      ,[FirstName]
--      ,[LastName]
--      ,[AddressLine1]
--      ,[AddressLine2]
--      ,[City]
--      ,[State]
--      ,[PostalCode]
--      ,[Country]
--      ,[ContactTel1]
--      ,[ContactTel2]
--      ,[Mobile]
--      ,[Fax]
--      ,[Email]
--      ,[Web]
--      ,[ContactTypeID]
--      ,[NickName]
--      ,[CoordinatorID]
--      ,[EmailSent]
--  FROM [OPS].[dbo].[tbl_Contact]
  
--OPEN DistributorCursor 
--	FETCH NEXT FROM DistributorCursor INTO @ID, @CompanyName, @Title ,@FirstName ,@LastName ,@AddressLine1 ,@AddressLine2,
--									   @City ,@State ,@PostalCode ,@Country , @ContactTel1 ,@ContactTel2 ,@Mobile ,
--									   @Fax ,@Email, @Web ,@ContactTypeID ,@NickName ,@CoordinatorID ,@EmailSent     
--	WHILE @@FETCH_STATUS = 0 
--	BEGIN 
--		WHILE(0<@SpecialPricesCount)
--		BEGIN
--		SET @SpecialPriceID = (SELECT  (SELECT ID FROM(SELECT ROW_NUMBER ()OVER(ORDER BY id)AS row ,ID 
--											FROM OPS.dbo.tbl_SpecialPrice sp)	_table WHERE row =@SpecialPricesCount))
--		SET @Name = (SELECT sp.Name FROM OPS.dbo.tbl_SpecialPrice sp WHERE SP.ID = @SpecialPriceID
--																	 AND sp.Name != 'PLATINUM')
--		IF (@CompanyName != @Name OR @ContactTypeID !=5)
		
		
--			BEGIN
--				INSERT INTO OPS.dbo.tbl_Contact(ID ,CompanyName, Title , FirstName  , LastName , AddressLine1 ,															AddressLine2 ,City ,[State] ,PostalCode , Country ,ContactTel1 ,														ContactTel2 ,Mobile ,Fax , Email ,Web ,ContactTypeID , NickName,														CoordinatorID,EmailSent)
--				VALUES(
--						(SELECT MAX(ID)+1 FROM OPS.dbo.tbl_Contact),
--						 @Name,
--						'Title'  , 
--						'FirstName',
--						'LastName',
--						'AddressLine1',
--						'AddressLine2',
--						'City',
--						'State',
--						'PostalCode',
--						'Australia',
--						'ContactTel1',
--						'ContactTel2',
--						'Mobile',
--						'Fax',
--						'E-Mail',
--						'Web',
--						5,
--						@Name,
--						NULL,
--						0
			 
--		  )  
--		  SET @SpecialPricesCount = @SpecialPricesCount - 1
--		 END 
--			END
			
--		FETCH NEXT FROM DistributorCursor INTO @ID, @CompanyName, @Title ,@FirstName ,@LastName ,@AddressLine1 ,
--											   @AddressLine2, @City ,@State ,@PostalCode ,@Country , @ContactTel1 ,
--											   @ContactTel2 ,@Mobile ,@Fax ,@Email, @Web ,@ContactTypeID ,@NickName ,
--											   @CoordinatorID ,@EmailSent  
--	END 

--CLOSE DistributorCursor 
--DEALLOCATE DistributorCursor	
--SELECT * FROM OPS.dbo.tbl_Contact	
-------/--------
--GO
--ROLLBACK TRAN

-----ORDER------
--SET NOCOUNT ON

--DECLARE @OrderDetail TABLE(
--	[OrderType] [int] NULL,
--	[VisualLayout] [int] NULL,
--	[Pattern] [int] NULL,
--	[FabricCode] [int] NULL,
--	[VisualLayoutNotes] [nvarchar](255) NULL,
--	[NameAndNumbersFilePath] [nvarchar](255) NULL,
--	[Order] [int] NULL,
--	[Label] [int] NULL)

--DECLARE @Id AS int
--DECLARE @OrderNumber  AS nvarchar(255)
--DECLARE @ProductID AS int
--DECLARE @EmployeeID AS int
--DECLARE @Notes  AS nvarchar(255)
--DECLARE @DateCreated AS DATETIME
--DECLARE @OrderDate AS DATETIME
--DECLARE @OrderTypeID AS int
--DECLARE @DestinationPortID AS int
--DECLARE @ShipmentModeID AS int
--DECLARE @ShipmentDate AS DATETIME
--DECLARE @StatusID AS int
--DECLARE @DateUpdated AS DATETIME
--DECLARE @CreatedBy AS int
--DECLARE @UpdatedBy AS int
--DECLARE @EstimatedCompletionDate AS DATETIME
--DECLARE @PaymentMethodID AS int
--DECLARE @OrderUsage AS nvarchar(255)
--DECLARE @ShippingAddress AS nvarchar(255)
--DECLARE @PONo AS int
--DECLARE @ShipTo AS int
--DECLARE @Converted AS bit
--DECLARE @OldPONo AS nvarchar(255)
--DECLARE @PrinterID AS int
--DECLARE @InvoiceNumber AS int
--DECLARE @OrderID AS int
--DECLARE @VisualLayoutID AS int
--DECLARE @TODAY AS DATETIME2(7)
--SET @TODAY = GETDATE()

--DECLARE @found AS bit
--DECLARE OrderCursor CURSOR FAST_FORWARD FOR 
--SELECT [ID]
--      ,[OrderNumber]
--      ,[ProductID]
--      ,[Notes]
--      ,[DateCreated]
--      ,[OrderDate]
--      ,[OrderTypeID]
--      ,[DestinationPortID]
--      ,[ShipmentModeID]
--      ,[ShipmentDate]
--      ,[StatusID]
--      ,[DateUpdated]
--      ,[CreatedBy]
--      ,[UpdatedBy]
--      ,[EstimatedCompletionDate]
--      ,[PaymentMethodID]
--      ,[OrderUsage]
--      ,[ShippingAddress]
--      ,[PONo]
--      ,[ShipTo]
--      ,[Converted]
--      ,[OldPONo]
--      ,[InvoiceNumber]
--      ,[PrinterID]
--  FROM [OPS].[dbo].[tbl_Order]
--	--ORDER BY op.[ProductNumber], op.[DateCreated]
--OPEN OrderCursor 
--	FETCH NEXT FROM OrderCursor INTO @Id, @OrderNumber, @ProductID, @Notes,@DateCreated,@OrderDate,															 @OrderTypeID, @DestinationPortID, @ShipmentModeID, @ShipmentDate,@StatusID, 
--									 @DateUpdated, @CreatedBy,@UpdatedBy,@EstimatedCompletionDate,@PaymentMethodID,
--									 @OrderUsage,@ShippingAddress,@PONo,@ShipTo,@Converted,@OldPONo,@PrinterID,
--									 @InvoiceNumber
--	WHILE @@FETCH_STATUS = 0 
--	BEGIN 
	
--		SET @found = 1 
		
--		IF (EXISTS(SELECT ID FROM OPS.dbo.tbl_DestinationPort  WHERE ID = @DestinationPortID)
--			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_ShipmentMode WHERE ID = @ShipmentModeID)
--			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_OrderStatus  WHERE ID = @StatusID)
--			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_PaymentMethod  WHERE ID = @PaymentMethodID)
--			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_Product  WHERE ID = @ProductID)
--			AND EXISTS (SELECT vm.OldId FROM Indico.dbo.VisualLayoutMapping vm WHERE vm.OldId = @ProductID))
		
--		BEGIN
--			INSERT INTO Indico.dbo.[Order] (OrderNumber ,[Date] , DesiredDeliveryDate , Client , Distributor ,														OrderSubmittedDate,EstimatedCompletionDate ,CreatedDate , ModifiedDate , 
--											DestinationPort , ShipmentMode ,ShipmentDate , [Status] , Creator ,Modifier ,
--											PaymentMethod , OrderUsage ,ShippingAddress , PurchaseOrderNo , ShipTo , 
--											Converted , OldPONo ,PhotoApprovalReq , Invoice , Printer ,IsTemporary ,
--											ContactCompanyName , ContactName ,ContactNumber ,AltContactName ,
--											AltContactNumber ,DeliveryMethod ,DeliveryAddress ,DeliveryCity ,
--											DeliveryPostCode ,IsRepeat ,Reservation) 
			  
--			VALUES (	@OrderNumber,
--						CAST(@DateCreated+7 AS DATETIME2)	,
--						@TODAY,
--						1,
--						1,
--						CAST(@OrderDate AS DATETIME2),
--						ISNULL(CAST(@EstimatedCompletionDate AS DATETIME2),(SELECT GETDATE())),
--						CAST(@DateUpdated-7 AS DATETIME2),
--						CAST(@DateUpdated AS DATETIME2),
--					(	SELECT TOP 1 1 ID FROM Indico.dbo.DestinationPort idp 
--													WHERE idp.Name = 
--												   (SELECT TOP 1 Name FROM OPS.dbo.tbl_DestinationPort odp
--													WHERE odp.ID = @DestinationPortID)),
--					(	SELECT TOP 1 ID FROM Indico.dbo.ShipmentMode ism 
--													WHERE ism.Name = 
--												   (SELECT TOP 1 Name FROM OPS.dbo.tbl_ShipmentMode osm
--													WHERE osm.ID = @ShipmentModeID)),
													
--						CAST(@ShipmentDate AS DATETIME2),
						
--					(	SELECT TOP 1 ID FROM Indico.dbo.OrderStatus ios 
--													WHERE ios.Name = 
--												   (SELECT TOP 1 Name FROM OPS.dbo.tbl_OrderStatus oos
--													WHERE oos.ID = @StatusID)),
--						ISNULL(@CreatedBy ,1),
--						ISNULL(@UpdatedBy ,1),
--					(	SELECT TOP 1 ID FROM Indico.dbo.PaymentMethod ipm 
--													WHERE ipm.Name = 
--												   (SELECT TOP 1 Name FROM OPS.dbo.tbl_PaymentMethod  opm
--													WHERE opm.ID = @PaymentMethodID)),
									
--						@OrderUsage,
--						@ShippingAddress,
--						@PONo,
--						@ShipTo,
--						@Converted,
--						@OldPONo,
--						NULL,
--						ISNULL((SELECT TOP 1 ID FROM Indico.dbo.Invoice iin 
--														WHERE iin.InvoiceNo =
--													   (SELECT TOP 1 oin.InvoiceNumber FROM OPS.dbo.tbl_Invoice oin
--														WHERE oin.ID = @InvoiceNumber)),NULL),
--						ISNULL((SELECT TOP 1 ID FROM Indico.dbo.Printer p
--														WHERE P.Name =
--													   (SELECT TOP 1 op.Name FROM OPS.dbo.tbl_Printer op
--														WHERE op.ID=@PrinterID)),1),
--						0,
--						NULL,
--						NULL,
--						NULL,
--						NULL,
--						NULL,
--						NULL,
--						NULL,
--						NULL,
--						NULL,
--						0,
--						NULL
--				 )	
						
			
--				SET @OrderID = SCOPE_IDENTITY ()
--				SET @VisualLayoutID = (SELECT vm.[NewId] FROM Indico.dbo.VisualLayoutMapping vm
--																		WHERE vm.OldId = @ProductID)
--				Print 	@VisualLayoutID							
--			INSERT INTO @OrderDetail (OrderType , VisualLayout , Pattern , FabricCode , VisualLayoutNotes ,													  NameAndNumbersFilePath , [Order] ,Label) 
--			VALUES(
--					(	SELECT TOP 1 ID FROM Indico.dbo.OrderType iot
--												WHERE iot.Name =
--											   (SELECT TOP 1 Name FROM OPS.dbo.tbl_OrderType  oot
--												WHERE oot.ID = @OrderTypeID)),
--						@VisualLayoutID,
--					(	SELECT ivl.Pattern FROM Indico.dbo.VisualLayout ivl WHERE ivl.ID = @VisualLayoutID),
--					(	SELECT ivl.FabricCode  FROM Indico.dbo.VisualLayout ivl WHERE ivl.ID = @VisualLayoutID),
--						@Notes,
--						NULL,
--						@OrderID,
--						NULL
--				  )
--		END
			  
--		FETCH NEXT FROM OrderCursor INTO @Id, @OrderNumber, @ProductID, @Notes,@DateCreated,@OrderDate,															 @OrderTypeID, @DestinationPortID, @ShipmentModeID, @ShipmentDate,@StatusID, 
--										 @DateUpdated, @CreatedBy,@UpdatedBy,@EstimatedCompletionDate,@PaymentMethodID,
--									     @OrderUsage,@ShippingAddress,@PONo,@ShipTo,@Converted,@OldPONo,@PrinterID,
--										 @InvoiceNumber	
--END 
--INSERT INTO Indico.dbo.OrderDetail 
--SELECT * FROM @OrderDetail
--CLOSE OrderCursor 
--DEALLOCATE OrderCursor

----//*//-----------
--GO

--------***///-------------


-------OrderDetailQty---------
--DECLARE @OrderDetailQty TABLE
--(
--	[OrderDetail] [int] NULL,
--	[Size] [int] NULL,
--	[Qty] [int] NULL
--)
--DECLARE @ID AS int
--DECLARE @OrderID AS int
--DECLARE @SizeID AS int 
--DECLARE @Qty AS int
--DECLARE OderDetailQtyCursor CURSOR FAST_FORWARD FOR 
--SELECT  [ID]
--	   ,[OrderID]
--       ,[SizeID]
--       ,[Qty]
--FROM [OPS].[dbo].[tbl_OrderQty]
--OPEN OderDetailQtyCursor 
--	FETCH NEXT FROM OderDetailQtyCursor INTO @ID , @OrderID , @SizeID , @Qty
--	WHILE @@FETCH_STATUS = 0 
--	BEGIN 
--			INSERT INTO @OrderDetailQty (OrderDetail , Size , Qty )
--			VALUES (
--						(SELECT iod.ID FROM Indico.dbo.OrderDetail iod 
--															WHERE iod.[Order] = @OrderID),
--						(SELECT ism.[NewId] FROM Indico.dbo.SizeMapping ism WHERE ism.[OldId] = @SizeID),
--						@Qty
--				    )
		
--		FETCH NEXT FROM OderDetailQtyCursor INTO @ID , @OrderID , @SizeID , @Qty
--	END 

--CLOSE OderDetailQtyCursor 
--INSERT INTO Indico.dbo.OrderDetailQty 
--SELECT * FROM @OrderDetailQty
--DEALLOCATE OderDetailQtyCursor		
-------/--------
--GO



