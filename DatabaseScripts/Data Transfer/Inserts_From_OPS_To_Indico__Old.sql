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

------item[Parent]-------
	 DECLARE @itemCount INT	 	 
	 SET @itemCount =(SELECT COUNT(*) AS [COUNT] FROM OPS.dbo.tbl_Item)
	 
		 WHILE 0<= @itemCount
		 			BEGIN 
				DECLARE @indicoItemID INT
				DECLARE @opsItemID INT
				DECLARE @indicoItemName varchar (255)
				
				SET @indicoItemID =(SELECT TOP 1 ID FROM Indico.dbo.Item ii WHERE ii.ID =@itemCount AND  Name != '' OR																							Name != null)
				SET @indicoItemName = (SELECT TOP 1 Name FROM Indico.dbo.Item ii WHERE ii.ID =@itemCount)
				SET @opsItemID = (SELECT TOP 1 oi.ID FROM OPS.dbo.tbl_Item oi
								WHERE oi.Name = @indicoItemName)
		
				INSERT INTO Indico.dbo.Item (Name,[Description],Parent )
					SELECT Name , Name , @indicoItemID FROM OPS.dbo.tbl_SubItem osi 
					WHERE osi.ItemID = @opsItemID AND   Name != '' OR																											Name != null
				
				SET @itemCount =@itemCount-1
		END
		GO	 		  
------/--------


---Item Attribute----
	INSERT INTO Indico.dbo.ItemAttribute(Parent, Item, Name, [Description])
		SELECT null, (SELECT TOP 1 ID FROM Indico.dbo.Item ii WHERE it.Name = ii.Name), ita.Name, ita.Name
			FROM OPS.dbo.tbl_ItemAttribute ita
				JOIN OPS.dbo.tbl_Item it
					ON ita.ItemID=it.ID
				
-----/-----
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
DECLARE ItemAttributeCursor CURSOR FAST_FORWARD FOR 
	SELECT [ID]
      ,[ItemAttributeID]
      ,[Name]
  FROM [OPS].[dbo].[tbl_ItemAttributeSub]
OPEN ItemAttributeCursor 
	FETCH NEXT FROM ItemAttributeCursor INTO @ID, @ItemAttributeID , @Name
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		
		SET @parentID =(SELECT TOP 1 ID FROM Indico.dbo.ItemAttribute iia WHERE iia.Name =(SELECT TOP 1 oia.Name 
																					 FROM OPS.dbo.tbl_ItemAttribute oia
																					 WHERE oia.ID =@ItemAttributeID ))
		
		 INSERT INTO @itemSub (Parent, Item , Name , [Description])
		 VALUES (@parentID,
				(SELECT iia.Item  FROM Indico.dbo.ItemAttribute iia WHERE iia.ID = @parentID),											@Name, 
				@Name)
		
		FETCH NEXT FROM ItemAttributeCursor INTO @ID, @ItemAttributeID , @Name
	END 

CLOSE ItemAttributeCursor 
DEALLOCATE ItemAttributeCursor		
INSERT INTO Indico.dbo.ItemAttribute SELECT * FROM @itemSub
-----/--------
GO

---Printer-----
	INSERT INTO Indico.dbo.Printer(Name,[Description])
	SELECT Name , Name FROM OPS.dbo.tbl_Printer
----/----
GO

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

-----Size---
	INSERT INTO Indico.dbo.Size(SizeSet,SizeName,SeqNo)
	SELECT (SELECT ID FROM Indico.dbo.SizeSet ss WHERE ss.Name=oss.Name) , s.Size , s.SeqNo  FROM OPS.dbo.tbl_Sizes s
		JOIN OPS.dbo.tbl_SizeSet oss 
			ON oss.ID = s.SizeSetId
-----/-----
GO

----ProductionLine------
	INSERT INTO Indico.dbo.ProductionLine(Name,[Description])
	SELECT Name , Name FROM OPS.dbo.tbl_ProductionLines
-----/-------
GO

----SportsCategory------
	INSERT INTO Indico.dbo.SportsCategory(Name,[Description])
	SELECT Name,Name FROM OPS.dbo.tbl_SportsCategory
-----/---------
GO

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

----Price-----

----/-----

----PriceHistory----

----/-----

----PriceLevelCost----

-----/-----

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

-----FabricCodes------
INSERT INTO Indico.dbo.FabricCode 
	(Code,Name,Material,Supplier,Country,DenierCount,Filaments,NickName,SerialOrder,LandedCost,LandedCurrency)
		SELECT Code , Name , Material , Supplier , ISNULL((SELECT c.ID FROM Indico.dbo.Country c WHERE c.ShortName = fc.Country) ,14) AS Country ,fc.[Denier Count]  , Filaments , NickName , fc.[Serial Order] , fc.[Landed Cost] , NULL  
			FROM OPS.dbo.tbl_FabricCodes fc 
		
------/---------
GO

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
	INSERT INTO Indico.dbo.Company ([Type] , IsDistributor , Name , Number , Address1 , Address2 , City , [State] , Postcode , Country ,Phone1 ,Phone2 ,Fax , NickName , Coordinator , [Owner] , Creator , CreatedDate ,Modifier ,ModifiedDate)
	SELECT 4 ,
		   1 , 
		   od.CompanyName ,
		   NULL ,
		   ISNULL(od.AddressLine1,'address'),
		   od.AddressLine2 ,
		   ISNULL(od.City,'city') ,
		   ISNULL(od.[State],'state') ,
		   ISNULL(od.PostalCode,'postalcode') ,
		   ISNULL((SELECT ID FROM Indico.dbo.Country c WHERE c.ShortName = od.Country),14) ,
		   ISNULL(od.ContactTel1,'contact1') ,
		   NULL ,
		   ISNULL(od.Fax,'fax') ,
		   ISNULL(od.NickName,NULL) ,
		   NULL ,
		   NULL ,
		   1 ,
		   (SELECT GETDATE()),
		   1 ,
		   (SELECT GETDATE())  
		 FROM OPS.dbo.tbl_Distributor od		
					
------/-------
GO

-----Production Sequence---------
	INSERT INTO Indico.dbo.ProductSequence (Number)
	SELECT Number FROM OPS.dbo.tbl_ProductSequence 
-------/-----------
GO

----Client----------
	INSERT INTO Indico.dbo.Client(Distributor,[Type],Name ,Title ,FirstName ,LastName ,Address1 ,Address2 ,City ,[State] ,PostalCode ,Country ,Phone1 ,Phone2 ,Mobile,Fax,Email,Web,NickName,EmailSent,Creator ,CreatedDate ,Modifier ,ModifiedDate )
	SELECT 4 ,
		   2 ,
		   ISNULL(co.CompanyName,'company name'),
		   ISNULL(co.Title,0),ISNULL(co.FirstName,'firstname'),
		   ISNULL(co.LastName,'lastname'),
		   ISNULL(co.AddressLine1,0),
		   co.AddressLine2,ISNULL(co.City,'city'),
		   ISNULL(co.[State],'state'),
		   ISNULL(co.PostalCode,0),
		   ISNULL((SELECT ShortName FROM Indico.dbo.Country c WHERE c.ShortName =co.Country),'Australia'),
		   ISNULL(co.ContactTel1,'contact1'),
		   ISNULL(co.ContactTel2,'contact2'),
		   co.Mobile,
		   co.Fax,
		   ISNULL(co.Email,'noreply@indico.com'),
		   co.Web,
		   co.NickName,
		   co.EmailSent,
		   1,
		   (SELECT GETDATE()),
		   1,
		  (SELECT GETDATE())
	FROM OPS.dbo.tbl_Contact co
------/--------------
GO

-----Category------
	INSERT INTO Indico.dbo.Category (Name , [Description] )
	SELECT Name , Name FROM OPS.dbo.tbl_SportsCategory
-----/---------
GO

----Pattern------
INSERT INTO Indico.dbo.Pattern (Item , SubItem , ItemAttribute , Gender , AgeGroup , SizeSet , CoreCategory , PrinterType			, Number , OriginRef , NickName ,Keywords , CorePattern , FactoryDescription , Consumption , ConvertionFactor			,SpecialAttributes , PatternNotes  , PriceRemarks , IsActive , Creator , CreatedDate , Modifier , ModifiedDate			, Remarks , IsTemplate, Parent, GarmentSpecStatus )
SELECT (SELECT ID FROM Indico.dbo.Item ii WHERE ii.Name = oi.Name AND ii.Parent IS NULL ) AS Item  ,
		ISNULL((SELECT TOP 1  ID FROM Indico.dbo.Item ii WHERE ii.Name = (SELECT TOP 1 osi.Name FROM OPS.dbo. tbl_SubItem					osi	WHERE osi.ID = op.SubItemID) AND ii.Name IS NOT NULL),36),
		ISNULL(op.ItemAttributeID,NULL) AS ItemAttribute,(SELECT ID FROM Indico.dbo.Gender ig WHERE ig.Name = (SELECT og.					Name FROM OPS.dbo.tbl_Gender og WHERE og.ID = op.GenderID))AS Gender ,
		(SELECT ID FROM Indico.dbo.AgeGroup ia WHERE ia.Name = (SELECT oa.Name FROM OPS.dbo.tbl_AgeGroup oa WHERE oa.ID =					op.AgeGroupID )) AS AgeGroup , 
		(SELECT ID FROM Indico.dbo.SizeSet iis WHERE iis.Name = (SELECT oss.Name FROM OPS.dbo.tbl_SizeSet oss WHERE oss.ID					= op.SizeSetID )) AS SizeSet , 
		ISNULL((SELECT ID FROM Indico.dbo.Category ic WHERE ic.Name = (SELECT osc.Name FROM OPS.dbo.tbl_SportsCategory osc						WHERE osc.ID = op.OtherCategoryID )),1) , 
		ISNULL((SELECT ip.ID FROM Indico.dbo.PrinterType ip WHERE ip.Name = (SELECT opt.Name FROM OPS.dbo.tbl_PrinterType					opt WHERE opt.ID = op.PrinterTypeID)),3) ,
		op.PatternNumber , 
		ISNULL(op.OriginRef , 0) AS OriginRef , 
		op.NickName ,
	    op.Keywords , 
	    op.CorPattern , 
	    NULL AS FactoryDescription , 
	    op.Consumption ,
	    ISNULL((SELECT TOP 1 FOBPrice FROM OPS.dbo.tbl_Prices tp WHERE tp.PatternID = op.ID),0.00) , 
	    op.SpecialAttributes , 
	    op.Notes , 
	    NULL AS 'PriceRemarks' ,
	    op.InactivePattern , 
	    1 AS Creator ,				---THIS INSERT STATMENT HAVE SOME ISSUES CORECATEGORY , PRINTER TYPE ,SUBITEM
	    op.DateCreated , 
	    1 AS Modifier , 
	   (SELECT GETDATE()) AS 'ModifiedDate' ,
	    NULL AS Remarks , 
	    1 AS 'IsTemplate',
	     NULL AS 'Parent' , 
	    'NOT COMPLEATED' AS GarmentSpecStatus
FROM OPS.dbo.tbl_Pattern op
			JOIN OPS.dbo.tbl_Item oi
				ON op.ItemID = oi.ID
-----/----------
GO

-----Price-------
SET NOCOUNT ON
DECLARE @priceLeveLCost TABLE (
	[Price] [int] NULL,
	[PriceLevel] [int] NULL,
	[FactoryCost] [decimal](8, 2) NULL,
	[IndimanCost] [decimal](8, 2) NULL,
	[IndicoCost] [decimal](8, 2) NULL
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
		
		SET @found =1
		
		IF(EXISTS (SELECT ID FROM OPS.dbo.tbl_Pattern WHERE ID =@PatternID)
		   AND  EXISTS (SELECT ID FROM OPS.dbo.tbl_FabricCodes WHERE ID = @FabricID))
		BEGIN 
		
			INSERT INTO Indico.dbo.Price(Pattern , FabricCode ,Creator ,CreatedDate , Modifier ,ModifiedDate)
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
			
				INSERT INTO @priceLeveLCost (Price , PriceLevel , FactoryCost , IndimanCost , IndicoCost ) 
				VALUES (@priceID,
						@Count,
						ISNULL((SELECT TOP 1 opj.Cost  FROM OPS.dbo.tbl_PricesJK opj
										WHERE opj.FabricID = @FabricID 
											AND opj.PatternID = @PatternID),0.00),
								(SELECT TOP 1 opr.Cost FROM OPS.dbo.tbl_Prices opr 
									 WHERE opr.PatternID = @PatternID 
											AND opr.FabricID = @FabricID),
								(SELECT  opss.Value FROM OPS.dbo.tbl_SpecialPrices opss
										WHERE opss.PATID = @PatternID
												AND opss.FABID = @FabricID))
					 
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
		SELECT ou.[First Name] , ou.[Last Name] , ou.Username
		FROM OPS.dbo.tbl_User ou
OPEN UserCursor 
	FETCH NEXT FROM UserCursor INTO @FirstName, @LastName, @UserName 
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	WHILE 0 < @userID 
		BEGIN
		SET @Company = (SELECT (SELECT top 1 ID FROM Indico.dbo.Company c WHERE c.Name = (SELECT top 1 od.CompanyName 
							FROM OPS.dbo.tbl_Distributor od	WHERE od.ID = ou.distributerID)) FROM OPS.dbo.tbl_User ou																WHERE ou.ID = @userID)							
		SET @isDistributor = (SELECT TOP 1 CASE WHEN u.distributerID > 0 THEN 1 ELSE 0 END  AS tt FROM OPS.dbo.tbl_User u								WHERE u.ID = @userID)
		
			
						INSERT INTO Indico.dbo.[User] ([Company],IsDistributor,[Status],Username ,[Password],GivenName ,														FamilyName ,EmailAddress,PhotoPath ,Creator ,CreatedDate ,Modifier														,ModifiedDate ,IsActive,IsDeleted ,[Guid],OfficeTelephoneNumber ,														MobileTelephoneNumber ,HomeTelephoneNumber ,DateLastLogin)
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
		SET @empid = (SELECT  (SELECT ID FROM(SELECT ROW_NUMBER ()OVER(ORDER BY id)AS row ,ID  FROM OPS.dbo.tbl_Employee)												_table WHERE row =@empCount))
			
		SET @Company = (SELECT top 1 (SELECT  ID FROM Indico.dbo.Company ic WHERE ic.Name = oe.CompanyName) 
								FROM OPS.dbo.tbl_Employee oe WHERE oe.ID = @empid)				
		
		
						INSERT INTO Indico.dbo.[User] ([Company],IsDistributor,[Status],Username ,[Password],GivenName ,														FamilyName ,EmailAddress,PhotoPath ,Creator ,CreatedDate ,Modifier														,ModifiedDate ,IsActive,IsDeleted ,[Guid],OfficeTelephoneNumber ,														MobileTelephoneNumber ,HomeTelephoneNumber ,DateLastLogin)
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
	FETCH NEXT FROM VisualLayoutCursor INTO @Id, @ProductNumber, @PatternId, @ResolutionProfileID, @ColourProfileID,												@ContactID, @Notes, @DateCreated, @FabricCodesID, @DistributorID, 
											@EmployeeID, @PrinterID
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
		SET @found = 1 
		
		IF (EXISTS(SELECT ID FROM OPS.dbo.tbl_Pattern WHERE ID = @PatternId)
			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_Contact WHERE ID = @ContactID)
			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_FabricCodes WHERE ID = @FabricCodesID)
			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_Distributor WHERE ID = @DistributorID)
			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_Employee WHERE ID = @EmployeeID))
		BEGIN
			INSERT INTO @VisualLayout (Name , [Description] , Pattern , FabricCode , Client , Coordinator ,													 Distributor , NNPFilePath )
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
						 SELECT TOP 1 od.CompanyName
						 FROM OPS.dbo.tbl_Distributor od
						 WHERE od.ID = @DistributorID)),
				NULL)		
		END
			  
		FETCH NEXT FROM VisualLayoutCursor INTO @Id, @ProductNumber, @PatternId, @ResolutionProfileID, @ColourProfileID,												@ContactID, @Notes, @DateCreated, @FabricCodesID, @DistributorID, 
												@EmployeeID, @PrinterID	
END 


INSERT INTO Indico.dbo.VisualLayout 
SELECT * FROM @VisualLayout WHERE Coordinator IS NOT NULL

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


-------DistributorPriceMarkup-----------

 INSERT INTO Indico.dbo.DistributorPriceMarkup (Distributor , PriceLevel , Markup) 
 SELECT NULL , 
		(SELECT ID FROM Indico.dbo.PriceLevel ipl WHERE ipl.Name = opl.Name),
		 (SELECT ospl.Rate WHERE ospl.PriceLevelID =opl.ID)
		FROM OPS.dbo.tbl_SpecialPriceLevel ospl
			JOIN OPS.dbo.tbl_PriceLevel opl 
				ON ospl.PriceLevelID = opl.ID
GO		

----///--------

--------Invoices---------
--DECLARE @Invoices AS TABLE (
--	[Status] [int] NULL,
--	[InvoiceNo] [nvarchar](64) NULL,
--	[InvoiceDate] [datetime2](7) NULL,
--	[ShipTo] [nvarchar](512) NULL,
--	[Value] [decimal](8, 2)NULL,
--	[Freight] [decimal](8, 2) NULL,
--	[OtherCost] [decimal](8, 2) NULL,
--	[Discount] [decimal](8, 2) NULL,
--	[NetValue] [decimal](8, 2) NULL,
--	[BillTo] [int] NULL,
--	[AWBNo] [nvarchar](255) NULL)

--DECLARE @ID AS int
--DECLARE @InvoiceNumber AS nvarchar (255)
--DECLARE @InvoiceDate AS DATETIME 
--DECLARE @ShipTo AS int
--DECLARE @InvoiceValue AS decimal(18,0) 
--DECLARE @InvoiceFreight AS decimal(18,0)
--DECLARE @InvoiceOther  AS decimal(18,0)
--DECLARE @InvoiceDiscount AS decimal(18,0)
--DECLARE @InvoiceNet AS decimal (18,0)
--DECLARE @BillTo AS int 
--DECLARE @AWBNumber AS nvarchar (255)
--DECLARE InvoiceCursor CURSOR FAST_FORWARD FOR 
-- SELECT [ID]
--      ,[InvoiceNumber]
--      ,[InvoiceDate]
--      ,[ShipTo]
--      ,[InvoiceValue]
--      ,[InvoiceFreight]
--      ,[InvoiceOther]
--      ,[InvoiceDiscount]
--      ,[InvoiceNet]
--      ,[BillTo]
--      ,[AWBNumber]   
--  FROM [OPS].[dbo].[tbl_Invoice] 
--OPEN InvoiceCursor 
--	FETCH NEXT FROM InvoiceCursor INTO @ID, @InvoiceNumber , @InvoiceDate , @ShipTo , @InvoiceValue , @InvoiceFreight,
--											@InvoiceOther ,  @InvoiceDiscount , @InvoiceNet , @BillTo ,	@AWBNumber 
--	WHILE @@FETCH_STATUS = 0 
--	BEGIN 
--		INSERT INTO @Invoices([Status] , InvoiceNo , InvoiceDate , ShipTo , Value , Freight , OtherCost , Discount ,							      NetValue ,BillTo , AWBNo)
--		VALUES (1,
--				@InvoiceNumber ,
--				@InvoiceDate,
--				@ShipTo,
--				@InvoiceValue,
--				@InvoiceFreight,
--				@InvoiceOther, 
--				@InvoiceDiscount,
--				@InvoiceNet,
--				@BillTo,
--				CONVERT(nvarchar,@AWBNumber))
	
--		FETCH NEXT FROM InvoiceCursor INTO @ID, @InvoiceNumber , @InvoiceDate , @ShipTo , @InvoiceValue , @InvoiceFreight,
--										   @InvoiceOther ,  @InvoiceDiscount , @InvoiceNet , @BillTo , @AWBNumber
--	END 
--SELECT * FROM @Invoices
--CLOSE InvoiceCursor 
--DEALLOCATE InvoiceCursor		
-------/--------
--GO

