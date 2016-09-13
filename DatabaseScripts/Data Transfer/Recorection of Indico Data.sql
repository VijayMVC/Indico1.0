--**--**--**----**----**-- DELETE FabricMapping --**----**----**----**----**----**--

DROP TABLE [Indico].[dbo].[FabricMapping]
GO
--**--**--**----**----**----**--**--**----**----**----**--**--**----**----**----**--**--**----**----**----**--**--**----**----**--

--**--**--**----**----**-- DELETE PatternMapping --**----**----**----**----**----**--

DROP TABLE [Indico].[dbo].[PatternMapping]
GO
--**--**--**----**----**----**--**--**----**----**----**--**--**----**----**----**--**--**----**----**----**--**--**----**----**-- 

--**----**----**----**----**-- DELETE VISUALLAYOUT --**----**----**----**----**----**----**----**----**--

DELETE [Indico].[dbo].[VisualLayout]
GO

--**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**--

--**----**----**----**----**-- DELETE CLIENT --**----**----**----**----**----**----**----**----**--

DELETE [Indico].[dbo].[Client]
GO

--**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**--

--**--**--**----**----**-- CREATE DISTRIBUTOR_MAPPING --**----**----**----**----**----**--
CREATE TABLE [Indico].[dbo].[DistributorMapping](
	[NewId] [int] NOT NULL,
	[OldId] [int] NOT NULL,
 CONSTRAINT [PK_DistributorMapping] PRIMARY KEY CLUSTERED 
(
	[NewId] ASC,
	[OldId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
--**--**--**----**----**----**--**--**----**----**----**--**--**----**----**----**--**--**----**----**----**--**--**----**----**--
 
--**--**--**----**----**-- CREATE CLIENT_MAPPING --**----**----**----**----**----**--

CREATE TABLE [Indico].[dbo].[ClientMapping](
	[NewId] [int] NOT NULL,
	[OldId] [int] NOT NULL,
 CONSTRAINT [PK_ClientMapping] PRIMARY KEY CLUSTERED 
(
	[NewId] ASC,
	[OldId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
--**--**--**----**----**----**--**--**----**----**----**--**--**----**----**----**--**--**----**----**----**--**--**----**----**--
--**--**--**----**----**-- CREATE SIZESET MAPPING --**----**----**----**----**----**--
CREATE TABLE [Indico].[dbo].[SizeSetMapping](
	[NewId] [int] NOT NULL,
	[OldId] [int] NOT NULL,
 CONSTRAINT [PK_SizeSetMapping] PRIMARY KEY CLUSTERED 
(
	[NewId] ASC,
	[OldId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

--**--**--**----**----**----**--**--**----**----**----**--**--**----**----**----**--**--**----**----**----**--**--**----**----**--

--**--**--**----**----**-- CREATE FabricMapping --**----**----**----**----**----**--
CREATE TABLE [Indico].[dbo].[FabricMapping]
(
	[NewId] [NVARCHAR](60) NOT NULL,
	[OldId] [NVARCHAR](60) NOT NULL,
 CONSTRAINT [PK_FabricMapping] PRIMARY KEY CLUSTERED 
(
	[NewId] ASC,
	[OldId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
--**--**--**----**----**----**--**--**----**----**----**--**--**----**----**----**--**--**----**----**----**--**--**----**----**--

--**--**--**----**----**-- CREATE PatternMapping --**----**----**----**----**----**--

CREATE TABLE [Indico].[dbo].[PatternMapping](
	[NewId] [int] NOT NULL,
	[OldId] NVARCHAR(20) NOT NULL,
 CONSTRAINT [PK_PatternMapping] PRIMARY KEY CLUSTERED 
(
	[NewId] ASC,
	[OldId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
--**--**--**----**----**----**--**--**----**----**----**--**--**----**----**----**--**--**----**----**----**--**--**----**----**--


--**--**--**----**----**-- INSERT CATEGORY --**----**----**----**----**----**--
INSERT INTO [Indico].[dbo].[Category] ([Name], [Description] ) VALUES ('MISC', 'MISC')
GO

INSERT INTO [Indico].[dbo].[Category] ([Name], [Description] ) VALUES ('POLO SHIRT', 'POLO SHIRT')
GO

--**--**--**----**----**----**--**--**----**----**----**--**--**----**----**----**--**--**----**----**----**--**--**----**----**--

--**--**--**----**----**-- UPDATE DISTRIBUTOR TYPE--**----**----**----**----**----**--

UPDATE [Indico].[dbo].[Company] SET [Type] = 4 WHERE [IsDistributor] = 1
--**--**--**----**----**----**--**--**----**----**----**--**--**----**----**----**--**--**----**----**----**--**--**----**----**--


--**--**--**----**----**-- DELETE DISTRIBUTOR --**----**----**----**----**----**--

DECLARE @ID AS int

DECLARE DeleteDistributor CURSOR FAST_FORWARD FOR 
SELECT c.[ID]	 
FROM [Indico].[dbo].[Company] c 
WHERE     (SELECT COUNT(*) 
	       FROM [Indico].[dbo].[VisualLayout] vl 
	       WHERE c.ID = vl.[Distributor] ) = 0  
	AND   (SELECT COUNT(*)
		   FROM [Indico].[dbo].[Order] o
		   WHERE c.ID = o.Distributor) = 0
	AND   (SELECT COUNT(*)
		   FROM [Indico].[dbo].[PriceListDownloads] pld
		   WHERE c.ID = pld.Distributor) = 0
	AND   (SELECT COUNT(*)
		   FROM [Indico].[dbo].[DistributorLabel] dl
	       WHERE c.ID = dl.Distributor) = 0
	AND   (SELECT COUNT(*)
		   FROM [Indico].[dbo].[DistributorPriceMarkup] dpm
		   WHERE c.ID = dpm.Distributor) = 0
	AND   (SELECT COUNT(*) 
		   FROM [Indico].[dbo].[DistributorPriceLevelCost] dplc 
		   WHERE c.ID = dplc.Distributor) = 0
	AND   (SELECT COUNT(*) 
		   FROM [Indico].[dbo].[DistributorPriceLevelCostHistory] dplch  
	       WHERE c.ID = dplch.Distributor) = 0
	AND   (SELECT COUNT(*)
		   FROM [Indico].[dbo].[User] u
		   WHERE c.ID = u.Company) = 0
AND c.[IsDistributor] = 1 
OPEN DeleteDistributor 
	FETCH NEXT FROM DeleteDistributor INTO @ID
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		
		DELETE FROM [Indico].[dbo].[Company] WHERE [ID] = @ID 
	
		FETCH NEXT FROM DeleteDistributor INTO @ID
	END 

CLOSE DeleteDistributor 
DEALLOCATE DeleteDistributor		
GO

--**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**--

--**----**----**----**----**-- INSERT DISTRIBUTOR --**----**----**----**----**----**----**----**----**--

DECLARE @DistributorID AS int
DECLARE @Distributor AS NVARCHAR(255)
DECLARE @Address AS NVARCHAR(255)
DECLARE @City AS NVARCHAR(255)
DECLARE @PostCode AS NVARCHAR(255)
DECLARE @Country AS NVARCHAR(255)
DECLARE @Contact AS NVARCHAR(255)
DECLARE @Phone AS NVARCHAR(255)
DECLARE @Email AS NVARCHAR(255)
DECLARE @Created AS DATETIME2(7)


DECLARE InsertDistributor CURSOR FAST_FORWARD FOR 

SELECT d.[DistributorID]
      ,d.[Distributor]      
      ,d.[Address]
      ,d.[City]
      ,d.[PostCode]
      ,d.[Country]
      ,d.[Contact]
      ,d.[Phone]
      ,d.[Email]     
      ,d.[Created]      
 FROM [Product].[dbo].[Distributors] d WHERE NOT EXISTS (
															SELECT * FROM [Indico].[dbo].[Company] c  
														    WHERE  d.Distributor = c.Name
														)
 
OPEN InsertDistributor 
	FETCH NEXT FROM InsertDistributor INTO @DistributorID, @Distributor, @Address, @City, @PostCode, @Country, @Contact, @Phone, @Email, @Created  
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		
		INSERT INTO [Indico].[dbo].[Company] ([Type], [IsDistributor], [Name], [Number], [Address1], [Address2], [City], [State], [Postcode], [Country], 
											  [Phone1], [Phone2], [Fax], [NickName], [Coordinator], [Owner], [Creator], [CreatedDate], [Modifier], [ModifiedDate]) 
		VALUES( 4,
				1,
				@Distributor,
				NULL,
				ISNULL(@Address, NULL),
				NULL,
				ISNULL(@City, NULL),
				NULL,
				ISNULL(@PostCode, NULL),
				ISNULL((SELECT [ID] FROM [Indico].[dbo].[Country] cu WHERE cu.[ShortName] = @Country ), 14), 
				ISNULL(@Contact, NULL),
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				1,
				ISNULL(@Created, (SELECT GETDATE())),
				1,
				(SELECT GETDATE())		  
			  )  
			  
			  INSERT INTO [Indico].[dbo].[DistributorMapping] ([NewId], [OldId] )
			  VALUES(SCOPE_IDENTITY(), @DistributorID)
	
		FETCH NEXT FROM InsertDistributor INTO @DistributorID, @Distributor, @Address, @City, @PostCode, @Country, @Contact, @Phone, @Email, @Created  
	END 

CLOSE InsertDistributor 
DEALLOCATE InsertDistributor
GO

--**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**--

--**----**----**----**----**-- INSERT CLIENT --**----**----**----**----**----**----**----**----**--
--BEGIN TRAN

DECLARE @ClientID AS int
DECLARE @Client AS NVARCHAR(255)
DECLARE @Address AS NVARCHAR(255)
DECLARE @City AS NVARCHAR(255)
DECLARE @PostCode AS NVARCHAR(255)
DECLARE @Country AS NVARCHAR(255)
DECLARE @Contact AS NVARCHAR(255)
DECLARE @Phone AS NVARCHAR(255)
DECLARE @Email AS NVARCHAR(255)
DECLARE @Created AS DATETIME2(7)
DECLARE @DistributorID AS int
DECLARE @ID AS int
DECLARE @I AS int

DECLARE InsertClient CURSOR FAST_FORWARD FOR 

SELECT cl.[ClientID],
	   cl.[Client],
	   cl.[Address],
	   cl.[City],
	   cl.[PostCode],
	   cl.[Country],
	   cl.[Contact],
	   cl.[Phone],
	   cl.[Email],
	   cl.[Created],
	   cl.[DistributorID]
FROM [Product].[dbo].[Client] cl
  
OPEN InsertClient 
	FETCH NEXT FROM InsertClient INTO @ClientID, @Client, @Address, @City, @PostCode, @Country, @Contact, @Phone, @Email, @Created, @DistributorID
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	SET @I= @I+1
				 
		IF EXISTS(SELECT [DistributorID]  FROM [Product].[dbo].[Distributors] WHERE [DistributorID] =  @DistributorID )
			BEGIN
			
				IF EXISTS (SELECT [NewId] FROM [Indico].[dbo].[DistributorMapping] WHERE [OldId] = @DistributorID)
					BEGIN
					 SET @ID = (SELECT [NewId] FROM [Indico].[dbo].[DistributorMapping] WHERE [OldId] = @DistributorID)
					END
				ELSE
					BEGIN
					 SET @ID = (SELECT c.[ID] FROM [Indico].[dbo].[Company] c 
										WHERE c.[IsDistributor] = 1 and c.[Name] = (
																					 SELECT d.[Distributor] 
																					 FROM [Product].[dbo].[Distributors] d 
																					 WHERE d.[DistributorID] = @DistributorID)
																				   )	
					END
				INSERT INTO [Indico].[dbo].[Client] ([Distributor], [Type], [Name], [Title], [FirstName], [LastName],[Address1], [Address2],  [City],
													 [State], [PostalCode], [Country], [Phone1], [Phone2], [Mobile], [Fax], [Email], [Web], [NickName], 
													 [EmailSent], [Creator], [CreatedDate], [Modifier], [ModifiedDate])   
													 
				VALUES(				
						@ID,
						4,
						ISNULL(@Client, ''),
						'', 
						'',
						'',
						ISNULL(@Address, ''),  
						'',
						ISNULL(@City, ''),
						'',
						ISNULL(@PostCode, ''),
						ISNULL((SELECT [ShortName] FROM [Indico].[dbo].[Country] WHERE [ShortName] = @Country), 'Australia'), 
						ISNULL(@Contact, ''),
						'',
						'',
						'',
						ISNULL(@Email, ''),
						'',
						'',
						0,
						1,
						ISNULL(@Created, (SELECT GETDATE())),
						1,
						(SELECT GETDATE())	     
					  )   
					  
				  INSERT INTO [Indico].[dbo].[ClientMapping] ([NewId], [OldId] )
				  VALUES(SCOPE_IDENTITY(), @ClientID)
			  
			END         
		
		FETCH NEXT FROM InsertClient INTO @ClientID, @Client, @Address, @City, @PostCode, @Country, @Contact, @Phone, @Email, @Created, @DistributorID
		PRINT @I	
	END 

CLOSE InsertClient 
DEALLOCATE InsertClient
GO

--ROLLBACK TRAN
--**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**--

--**----**----**----**----**-- INSERT NULL DISTRIBUTOR CLIENT --**----**----**----**----**----**----**----**----**--
DECLARE @ClientID AS int
DECLARE @Client AS NVARCHAR(255)
DECLARE @Address AS NVARCHAR(255)
DECLARE @City AS NVARCHAR(255)
DECLARE @PostCode AS NVARCHAR(255)
DECLARE @Country AS NVARCHAR(255)
DECLARE @Contact AS NVARCHAR(255)
DECLARE @Phone AS NVARCHAR(255)
DECLARE @Email AS NVARCHAR(255)
DECLARE @Created AS DATETIME2(7)
DECLARE @DistributorID AS int


DECLARE InsertNullDistributorClient CURSOR FAST_FORWARD FOR 

SELECT cl.[ClientID],
	   cl.[Client],
	   cl.[Address],
	   cl.[City],
	   cl.[PostCode],
	   cl.[Country],
	   cl.[Contact],
	   cl.[Phone],
	   cl.[Email],
	   cl.[Created],
	   cl.[DistributorID]
FROM [Product].[dbo].[Client] cl
WHERE cl.[DistributorID] IS NULL
  
OPEN InsertNullDistributorClient 
	FETCH NEXT FROM InsertNullDistributorClient INTO @ClientID, @Client, @Address, @City, @PostCode, @Country, @Contact, @Phone, @Email, @Created, @DistributorID
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		 
				INSERT INTO [Indico].[dbo].[Client] ([Distributor], [Type], [Name], [Title], [FirstName], [LastName],[Address1], [Address2],  [City],
													 [State], [PostalCode], [Country], [Phone1], [Phone2], [Mobile], [Fax], [Email], [Web], [NickName], 
													 [EmailSent], [Creator], [CreatedDate], [Modifier], [ModifiedDate])   
													 
				VALUES(
						5,
						4,
						ISNULL(@Client, ''),
						'', 
						'',
						'',
						ISNULL(@Address, ''),  
						'',
						ISNULL(@City, ''),
						'',
						ISNULL(@PostCode, ''),
						ISNULL((SELECT [ShortName] FROM [Indico].[dbo].[Country] WHERE [ShortName] = @Country), 'Australia'),  
						ISNULL(@Contact, ''),
						'',
						'',
						'',
						ISNULL(@Email, ''),
						'',
						'',
						0,
						1,
						ISNULL(@Created, (SELECT GETDATE())),
						1,
						(SELECT GETDATE())	     
					  )  
				 INSERT INTO [Indico].[dbo].[ClientMapping] ([NewId], [OldId] )
				 VALUES(SCOPE_IDENTITY(), @ClientID)				 		      
		
		FETCH NEXT FROM InsertNullDistributorClient INTO @ClientID, @Client, @Address, @City, @PostCode, @Country, @Contact, @Phone, @Email, @Created, @DistributorID		
	END 

CLOSE InsertNullDistributorClient 
DEALLOCATE InsertNullDistributorClient
GO

--**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**--

--**----**----**----**----**-- INSERT FABRICCODE --**----**----**----**----**----**----**----**----**--
--BEGIN TRAN

DECLARE @FabricCode AS NVARCHAR(255)
DECLARE @FabricDesc AS NVARCHAR(255)
DECLARE @Material AS NVARCHAR(255)
DECLARE @GSM AS NVARCHAR(255)
DECLARE @Supplier AS NVARCHAR(255)
DECLARE @Country AS NVARCHAR(255)
DECLARE @DenierCount AS NVARCHAR(255)
DECLARE @Filaments AS NVARCHAR(255)
DECLARE @Nickname AS NVARCHAR(255)
DECLARE @SerialOrder AS int
DECLARE @LandedCost AS real

DECLARE InsertFabriCode CURSOR FAST_FORWARD FOR 

SELECT f.[FabricCode]      
      ,f.[FabricDesc]
      ,f.[Material]
      ,f.[GSM]
      ,f.[Supplier]
      ,f.[Country]
      ,f.[Denier Count]
      ,f.[Filaments]
      ,f.[Nickname]
      ,f.[Serial Order]
      ,f.[Landed Cost] 
FROM [Product].[dbo].[Fabric] f
	LEFT OUTER JOIN [Indico] .[dbo] .[FabricCode]  fc
		ON f.[FabricCode] = fc.[Code] 
WHERE fc.[Code] IS NULL	
  
OPEN InsertFabriCode 
	FETCH NEXT FROM InsertFabriCode INTO @FabricCode, @FabricDesc, @Material, @GSM, @Supplier, @Country, @DenierCount, @Filaments, @Nickname, @SerialOrder, @LandedCost
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
			
			 INSERT INTO  [Indico].[dbo].[FabricCode] ([Code], [Name], [Material], [GSM], [Supplier], [Country], [DenierCount], [Filaments],
													   [NickName], [SerialOrder], [LandedCost], [LandedCurrency] )
													   
		     VALUES(
						CONVERT(NVARCHAR(64), @FabricCode),
						@FabricDesc,
						@Material,
						@GSM,
						@Supplier,
						ISNULL((SELECT [ID] FROM [Indico].[dbo].[Country] WHERE [ShortName] = @Country), 14),
						@DenierCount,
						@Filaments,
						ISNULL(@Nickname,''),
						CONVERT(NVARCHAR(32), @SerialOrder),
						@LandedCost,
						NULL 
				   )
				   
			INSERT INTO [Indico].[dbo].[FabricMapping] ([NewId], [OldId])
			VALUES(SCOPE_IDENTITY(), @FabricCode)
		
		FETCH NEXT FROM InsertFabriCode INTO @FabricCode, @FabricDesc, @Material, @GSM, @Supplier, @Country, @DenierCount, @Filaments, @Nickname, @SerialOrder, @LandedCost
	END 

CLOSE InsertFabriCode 
DEALLOCATE InsertFabriCode
GO
--ROLLBACK TRAN
--**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**--

--**----**----**----**----**----**----** INSERT SIZESET --**----**----**----**----**----**----**

DECLARE @ID AS int
DECLARE @SizeSet AS NVARCHAR(255)

DECLARE InsertItem CURSOR FAST_FORWARD FOR 

SELECT ps.[ID]
      ,ps.[SizeSet]     
FROM [Product].[dbo].[SizeSet] ps
	 LEFT OUTER JOIN [Indico].[dbo].[SizeSet] iss
		ON ps.SizeSet = iss.[Name] 
WHERE iss.[Name] IS NULL
				  
OPEN InsertItem 
	FETCH NEXT FROM InsertItem INTO @ID, @SizeSet
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		
		INSERT INTO [Indico].[dbo].[SizeSet] ([Name] , [Description])
		VALUES (
				@SizeSet,
				@SizeSet				
			   )	
		INSERT INTO [Indico].[dbo].[SizeSetMapping] ([NewId], [OldId] )
		VALUES(SCOPE_IDENTITY(), @ID)
		FETCH NEXT FROM InsertItem INTO @ID, @SizeSet
	END 

CLOSE InsertItem 
DEALLOCATE InsertItem	

GO
--**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**--			  

--**----**----**----**----**----**----** INSERT PATTERN --**----**----**----**----**----**----**
--BEGIN TRAN

DECLARE @PatternCode AS NVARCHAR(255)
DECLARE @DateCreated AS DATETIME2(7)
DECLARE @Correspondingpattern AS NVARCHAR(255)
DECLARE @SplAttribute AS NVARCHAR(255)
DECLARE @Item AS NVARCHAR(255)
DECLARE @Itemsubcat AS NVARCHAR(255)
DECLARE @Gender AS NVARCHAR(255)
DECLARE @AgeGroup AS NVARCHAR(255)
DECLARE @SizeSet AS int
DECLARE @SportsCat AS NVARCHAR(255)
DECLARE @KeyWords AS NVARCHAR(255)
DECLARE @Nickname AS NVARCHAR(255)
DECLARE @Notes AS NVARCHAR(255)
DECLARE @PrintType AS NVARCHAR(255)
DECLARE @JKDesc AS NVARCHAR(255)
DECLARE @Inactive AS bit
DECLARE @Consumption AS real
DECLARE @Desc AS NVARCHAR(255)
DECLARE @OnWeb AS bit
DECLARE @SSID AS int
DECLARE @PTID AS int

DECLARE InsertPattern CURSOR FAST_FORWARD FOR 

SELECT p.[PatternCode]
      ,p.[DateCreated]
      ,p.[Corresponding_pattern]
      ,p.[Spl_Attribute]
      ,p.[Item]
      ,p.[Itemsubcat]     
      ,p.[Gender]
      ,p.[AgeGroup]
      ,p.[SizeSet]       
      ,p.[SportsCat]
      ,p.[Key_Words]
      ,p.[Nick_name]
      ,p.[Notes]      
      ,p.[Print_Type]
      ,p.[JK Desc]
      ,p.[Consumption]     
      ,p.[On Web]     
FROM [Product].[dbo].[Pattern] p
	LEFT OUTER JOIN [Indico] .[dbo].[Pattern]  pc
		ON p.[PatternCode] = pc.[Number] 
WHERE pc.Number IS NULL	
  
OPEN InsertPattern 
	FETCH NEXT FROM InsertPattern INTO @PatternCode, @DateCreated, @Correspondingpattern, @SplAttribute, @Item, @Itemsubcat, @Gender, @AgeGroup, @SizeSet, 
									   @SportsCat, @KeyWords, @Nickname, @Notes, @PrintType, @JKDesc, @Consumption, @OnWeb
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		------- SET PRINTER TYPE
		
			IF (@PrintType = 1)
				BEGIN
				 SET @PTID = 1
				END
			ELSE 
				BEGIN
				 SET @PTID = 3 
				END
				
			------- SET SIZESET	
			
			IF EXISTS(SELECT [NewId] FROM [Indico].[dbo].[SizeSetMapping] WHERE [OldId] = @SizeSet )
				 BEGIN
					SET @SSID = (SELECT [NewId] FROM [Indico].[dbo].[SizeSetMapping] WHERE [OldId] = @SizeSet )
				 END
			ELSE IF(@SizeSet IS NOT NULL)	 
				 BEGIN					
					SET @SSID = (SELECT [ID]  FROM [Indico].[dbo].[SizeSet] WHERE [Name] =(SELECT [SizeSet] FROM [Product].[dbo].[SizeSet] WHERE [ID] = @SizeSet )) 
				 END
			ELSE
				BEGIN
					SET @SSID = 6
				END
			--------- INSERT SIZESET
			
				 INSERT INTO [Indico].[dbo].[Pattern] ([Item], [SubItem], [Gender], [AgeGroup], [SizeSet], [CoreCategory], [PrinterType], [Number], [OriginRef], [NickName],
													   [Keywords], [CorePattern], [FactoryDescription], [Consumption], [ConvertionFactor], [SpecialAttributes], [PatternNotes],
													   [PriceRemarks], [IsActive], [Creator], [CreatedDate], [Modifier], [ModifiedDate], [Remarks], [IsTemplate], [Parent], 
													   [GarmentSpecStatus], [IsActiveWS] )
				VALUES(
						(SELECT TOP 1 [ID] FROM [Indico].[dbo].[Item] WHERE [Name] = @Item AND [Parent] IS NULL), --ITEM
						(SELECT TOP 1 [ID] FROM [Indico].[dbo].[Item] WHERE [Name] = @Itemsubcat AND [Parent] IS NOT NULL), --SUBITEM
						ISNULL((SELECT TOP 1 [ID] FROM [Indico].[dbo].[Gender] WHERE [Name] = @Gender),4),    --GENDER
						ISNULL((SELECT TOP 1 [ID] FROM [Indico].[dbo].[AgeGroup] WHERE [Name] = @AgeGroup),4), --AGEGROUP
						@SSID,
					    (SELECT [ID] FROM [Indico].[dbo].[Category] WHERE [Name] =  @SportsCat),--CORECATEGORY
						@PTID,						 
						@PatternCode,
						NULL,
						@Nickname,
						@KeyWords,
						@Correspondingpattern, 
						@JKDesc,
						CONVERT(NVARCHAR(255), @Consumption),
						0,
						@SplAttribute,
						@Notes,
						NULL,
						1,					
						1,
						ISNULL(@DateCreated, (SELECT GETDATE())),
						1,
						(SELECT GETDATE()),
						NULL,
						0,
						NULL,
						'Not Completed',
						@OnWeb  
					  )                         
			INSERT INTO [Indico].[dbo].[PatternMapping] ([NewId], [OldId] )  
			VALUES(SCOPE_IDENTITY(), @PatternCode)
			
		FETCH NEXT FROM InsertPattern INTO @PatternCode, @DateCreated, @Correspondingpattern, @SplAttribute, @Item, @Itemsubcat, @Gender, @AgeGroup, @SizeSet, 
									       @SportsCat, @KeyWords, @Nickname, @Notes, @PrintType, @JKDesc, @Consumption, @OnWeb
	END 

CLOSE InsertPattern 
DEALLOCATE InsertPattern
GO
	
--ROLLBACK TRAN
--**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**--

--**----**----**----**----**-- INSERT VISUALLAYOUT --**----**----**----**----**----**----**----**----**--
--BEGIN TRAN

DECLARE @ProductID AS NVARCHAR(255)
DECLARE @Product AS NVARCHAR(255)
DECLARE @Distributor AS NVARCHAR(255)
DECLARE @Client AS NVARCHAR(255)
DECLARE @Pattern AS NVARCHAR(255)
DECLARE @DefaultFabric AS NVARCHAR(255)
DECLARE @Created AS DATETIME2(7)
DECLARE @DID AS int
DECLARE @CID AS int
DECLARE @FID AS int
DECLARE @PID AS int

DECLARE InsertVisualLayout CURSOR FAST_FORWARD FOR 

SELECT [ProductID]
      ,[Product]
      ,[Distributor]
      ,[Client]
      ,[Pattern] 
      ,[Default_Fabric]      
      ,[Created]
FROM [Product].[dbo].[Product]
  
OPEN InsertVisualLayout 
	FETCH NEXT FROM InsertVisualLayout INTO @ProductID, @Product, @Distributor, @Client, @Pattern, @DefaultFabric, @Created
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		IF (EXISTS(SELECT [FabricCode] FROM [Product].[dbo].[Fabric] WHERE [FabricCode] = @DefaultFabric) AND EXISTS
				  (SELECT [PatternCode] FROM [Product].[dbo].[Pattern] WHERE [PatternCode] = @Pattern))  
		BEGIN  			 
			----- SET DISTRIBUTOR
				IF EXISTS(SELECT [NewId] FROM [Indico].[dbo].[DistributorMapping] WHERE [OldId] = @Distributor)
					BEGIN
					 SET @DID = (SELECT [NewId] FROM [Indico].[dbo].[DistributorMapping] WHERE [OldId] = @Distributor)
					END
				ELSE
					BEGIN
					 SET @DID = (SELECT c.[ID] FROM [Indico].[dbo].[Company] c 
											WHERE c.[IsDistributor] = 1 and c.[Name] = (
																						 SELECT d.[Distributor] 
																						 FROM [Product].[dbo].[Distributors] d 
																						 WHERE d.[DistributorID] = @Distributor)
																					   )	
					END
				
				------ SET CLIENT
				IF EXISTS (SELECT [NewId] FROM [Indico].[dbo].[ClientMapping] WHERE [OldId] = @Client)
					BEGIN
						SET	@CID = (SELECT [NewId] FROM [Indico].[dbo].[ClientMapping] WHERE [OldId] = @Client)
					END
				ELSE
					BEGIN
					 SET @CID = (SELECT c.[ID] FROM [Indico].[dbo].[Client] c 
											   WHERE c.[Name] = (
																 SELECT p.[Client] 
																 FROM [Product].[dbo].[Client] p 
																 WHERE p.[ClientID] = @Client) 
																)
					END
				
				------- SET FABRICCODE
				IF EXISTS(SELECT [NewId] FROM [Indico].[dbo].[FabricMapping] WHERE [OldId] = @DefaultFabric)
					BEGIN
						SET @FID = (SELECT [NewId] FROM [Indico].[dbo].[FabricMapping] WHERE [OldId] = @DefaultFabric)
					END
				ELSE
					BEGIN
					 SET @FID = (SELECT f.[ID] FROM [Indico].[dbo].[FabricCode] f 
												WHERE f.[Code] = ( 
																	SELECT pf.[FabricCode] 
																	FROM [Product].[dbo].[Fabric] pf 
																	WHERE pf.[FabricCode]  = @DefaultFabric)
																 )
					END
					
				---------- SET PATTERN
				IF EXISTS(SELECT [NewId] FROM [Indico].[dbo].[PatternMapping] WHERE [OldId] = @Pattern )
					BEGIN
						SET @PID = (SELECT [NewId] FROM [Indico].[dbo].[PatternMapping] WHERE [OldId] = @Pattern )
					END	 
				ELSE
					BEGIN
					 SET @PID = (SELECT [ID] FROM [Indico].[dbo].[Pattern] p 
										WHERE p.[Number] = @Pattern)
														   
					END
			 -------INSERT VisualLayout
			 
				INSERT INTO [Indico].[dbo].[VisualLayout] ([NamePrefix], [Description], [Pattern], [FabricCode], [Client], [Coordinator], [Distributor], [NNPFilePath],
															[NameSuffix], [CreatedDate], [IsCommonProduct])
															
				VALUES(
						@Product,
						NULL,
						@PID,
						@FID,
						@CID,
						NULL,
						@DID, 
						NULL,
						NULL,
						ISNULL(@Created, (SELECT GETDATE())),
						0	
					  )		
				
		END
		FETCH NEXT FROM InsertVisualLayout INTO @ProductID, @Product, @Distributor, @Client, @Pattern, @DefaultFabric, @Created
	END 

CLOSE InsertVisualLayout 
DEALLOCATE InsertVisualLayout
GO

--ROLLBACK TRAN
--**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**--

--**----**----**----**----**----**----** INSERT COORDINATOR --**----**----**----**----**----**----**


INSERT INTO [Indico].[dbo].[User]
           ([Company] ,[IsDistributor] ,[Status] ,[Username] ,[Password] ,[GivenName] ,[FamilyName] ,[EmailAddress] ,[PhotoPath] ,[Creator] ,[CreatedDate]
           ,[Modifier] ,[ModifiedDate] ,[IsActive] ,[IsDeleted] ,[Guid] ,[OfficeTelephoneNumber] ,[MobileTelephoneNumber] ,[HomeTelephoneNumber]
           ,[DateLastLogin])
     VALUES
           (4
           ,1
           ,1
           ,'Username'
           ,HashBytes('SHA1', 'password')
           ,'MBASSETT'
           ,''
           ,'mark@indico.net.au'
           ,NULL
           ,1
           ,(SELECT GETDATE())
           ,1
           ,(SELECT GETDATE())
           ,1
           ,0
           ,NULL
           ,''
           ,NULL
           ,NULL
           ,NULL)
GO

INSERT INTO [Indico].[dbo].[User]
            ([Company] ,[IsDistributor] ,[Status] ,[Username] ,[Password] ,[GivenName] ,[FamilyName] ,[EmailAddress] ,[PhotoPath] ,[Creator] ,[CreatedDate]
           ,[Modifier] ,[ModifiedDate] ,[IsActive] ,[IsDeleted] ,[Guid] ,[OfficeTelephoneNumber] ,[MobileTelephoneNumber] ,[HomeTelephoneNumber]
           ,[DateLastLogin])
     VALUES
           (4
           ,1
           ,1
           ,'Username1'
           ,HashBytes('SHA1', 'password')
           ,'MINGRAM'
           ,''
           ,'markingram@indico.net.au'
           ,NULL
           ,1
           ,(SELECT GETDATE())
           ,1
           ,(SELECT GETDATE())
           ,1
           ,0
           ,NULL
           ,''
           ,NULL
           ,NULL
           ,NULL)
GO

INSERT INTO [Indico].[dbo].[User]
           ([Company] ,[IsDistributor] ,[Status] ,[Username] ,[Password] ,[GivenName] ,[FamilyName] ,[EmailAddress] ,[PhotoPath] ,[Creator] ,[CreatedDate]
           ,[Modifier] ,[ModifiedDate] ,[IsActive] ,[IsDeleted] ,[Guid] ,[OfficeTelephoneNumber] ,[MobileTelephoneNumber] ,[HomeTelephoneNumber]
           ,[DateLastLogin])
     VALUES
           (4
           ,1
           ,1
           ,'Username2'
           ,HashBytes('SHA1', 'password')
           ,'BEN LESKE'
           ,''
           ,'BenLeske@indico.net.au'
           ,NULL
           ,1
           ,(SELECT GETDATE())
           ,1
           ,(SELECT GETDATE())
           ,1
           ,0
           ,NULL
           ,''
           ,NULL
           ,NULL
           ,NULL)
GO

INSERT INTO [Indico].[dbo].[User]
            ([Company] ,[IsDistributor] ,[Status] ,[Username] ,[Password] ,[GivenName] ,[FamilyName] ,[EmailAddress] ,[PhotoPath] ,[Creator] ,[CreatedDate]
           ,[Modifier] ,[ModifiedDate] ,[IsActive] ,[IsDeleted] ,[Guid] ,[OfficeTelephoneNumber] ,[MobileTelephoneNumber] ,[HomeTelephoneNumber]
           ,[DateLastLogin])
     VALUES
           (4
           ,1
           ,1
           ,'Username3'
           ,HashBytes('SHA1', 'password')
           ,'JENNA KING'
           ,''
           ,'jenna@indico.net.au'
           ,NULL
           ,1
           ,(SELECT GETDATE())
           ,1
           ,(SELECT GETDATE())
           ,1
           ,0
           ,NULL
           ,''
           ,NULL
           ,NULL
           ,NULL)
GO

INSERT INTO [Indico].[dbo].[User]
            ([Company] ,[IsDistributor] ,[Status] ,[Username] ,[Password] ,[GivenName] ,[FamilyName] ,[EmailAddress] ,[PhotoPath] ,[Creator] ,[CreatedDate]
           ,[Modifier] ,[ModifiedDate] ,[IsActive] ,[IsDeleted] ,[Guid] ,[OfficeTelephoneNumber] ,[MobileTelephoneNumber] ,[HomeTelephoneNumber]
           ,[DateLastLogin])
     VALUES
           (4
           ,1
           ,1
           ,'Username3'
           ,HashBytes('SHA1', 'password')
           ,'EVERYONE'
           ,''
           ,'info@indico.net.au'
           ,NULL
           ,1
           ,(SELECT GETDATE())
           ,1
           ,(SELECT GETDATE())
           ,1
           ,0
           ,NULL
           ,''
           ,NULL
           ,NULL
           ,NULL)
GO
--**----**----**----**----**----**----**--**----**----**----**----**----**----**--**----**----**----**----**----**----**--**----**----**----**----**----**----**

--**----**----**----**----**----**----** UPDATE DISTRIBUTOR COORDINATOR --**----**----**----**----**----**----**


DECLARE @DistributorID AS int
DECLARE @Distributor AS NVARCHAR(255)
DECLARE @Coordinator AS int
DECLARE @CID AS int

DECLARE DeleteDistributor CURSOR FAST_FORWARD FOR 
SELECT [DistributorID]
      ,[Distributor]
      ,[Coordinator]     
FROM [Product].[dbo].[Distributors]

OPEN DeleteDistributor 
	FETCH NEXT FROM DeleteDistributor INTO @DistributorID, @Distributor, @Coordinator
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		SET @CID = (SELECT TOP 1 [ID] FROM [Indico].[dbo].[User] WHERE [GivenName] = (
																				 SELECT TOP 1 [Coordinator] 
																				 FROM [Product].[dbo].[Coordinator] 
																				 WHERE [CoordinatorID] = @Coordinator 
																			  ))
		UPDATE [Indico].[dbo].[Company] SET [Coordinator] = @CID WHERE [Name] = @Distributor AND IsDistributor = 1
	
		FETCH NEXT FROM DeleteDistributor INTO @DistributorID, @Distributor, @Coordinator
	END 

CLOSE DeleteDistributor 
DEALLOCATE DeleteDistributor		
GO

--**----**----**----**----**----**----**--**----**----**----**----**----**----**--**----**----**----**----**----**----**--**----**----**----**----**----**----**


--**----**----**----**----**----**----** DROP TEMP TABLES --**----**----**----**----**----**----**
USE [Indico]
GO
/****** Object:  Table [dbo].[ClientMapping]    Script Date: 12/03/2012 15:57:24 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ClientMapping]') AND type in (N'U'))
DROP TABLE [dbo].[ClientMapping]
GO
/****** Object:  Table [dbo].[DistributorMapping]    Script Date: 12/03/2012 15:57:24 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DistributorMapping]') AND type in (N'U'))
DROP TABLE [dbo].[DistributorMapping]
GO
/****** Object:  Table [dbo].[FabricMapping]    Script Date: 12/03/2012 15:57:24 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FabricMapping]') AND type in (N'U'))
DROP TABLE [dbo].[FabricMapping]
GO
/****** Object:  Table [dbo].[ItemAttributeMapping]    Script Date: 12/03/2012 15:57:24 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ItemAttributeMapping]') AND type in (N'U'))
DROP TABLE [dbo].[ItemAttributeMapping]
GO
/****** Object:  Table [dbo].[PatternMapping]    Script Date: 12/03/2012 15:57:24 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PatternMapping]') AND type in (N'U'))
DROP TABLE [dbo].[PatternMapping]
GO
/****** Object:  Table [dbo].[SizeMapping]    Script Date: 12/03/2012 15:57:24 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SizeMapping]') AND type in (N'U'))
DROP TABLE [dbo].[SizeMapping]
GO
/****** Object:  Table [dbo].[SizeSetMapping]    Script Date: 12/03/2012 15:57:24 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SizeSetMapping]') AND type in (N'U'))
DROP TABLE [dbo].[SizeSetMapping]
GO


--**----**----**----**----**----**----**--**----**----**----**----**----**----**--**----**----**----**----**----**----**--**----**----**----**----**----**----**


















