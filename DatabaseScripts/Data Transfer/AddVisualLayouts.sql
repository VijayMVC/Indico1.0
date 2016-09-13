
--**--**--**----**----**-- DELETE DistributorMapping --**----**----**----**----**----**--

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DistributorMapping]') AND type in (N'U'))
DROP TABLE [dbo].[DistributorMapping]
GO
--**--**--**----**----**----**--**--**----**----**----**--**--**----**----**----**--**--**----**----**----**--**--**----**----**--


--**--**--**----**----**-- DELETE ClientMapping --**----**----**----**----**----**--

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ClientMapping]') AND type in (N'U'))
DROP TABLE [dbo].[ClientMapping]
GO
--**--**--**----**----**----**--**--**----**----**----**--**--**----**----**----**--**--**----**----**----**--**--**----**----**--

--**--**--**----**----**-- DELETE FabricMapping --**----**----**----**----**----**--

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FabricMapping]') AND type in (N'U'))
DROP TABLE [dbo].[FabricMapping]
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
DECLARE @Coordinator_ID AS int
DECLARE @Address AS NVARCHAR(255)
DECLARE @City AS NVARCHAR(255)
DECLARE @PostCode AS NVARCHAR(255)
DECLARE @Country AS NVARCHAR(255)
DECLARE @Contact AS NVARCHAR(255)
DECLARE @Phone AS NVARCHAR(255)
DECLARE @Email AS NVARCHAR(255)


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
 FROM [Product_1].[dbo].[Distributor] d 
	LEFT OUTER JOIN [Indico].[dbo].[Company] c
		ON d.[Distributor] COLLATE DATABASE_DEFAULT = c.[Name] COLLATE DATABASE_DEFAULT
WHERE c.[Name] IS NULL
	 
OPEN InsertDistributor 
	FETCH NEXT FROM InsertDistributor INTO @DistributorID, @Distributor, @Address, @City, @PostCode, @Country, @Contact, @Phone, @Email
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
				(SELECT GETDATE()),
				1,
				(SELECT GETDATE())		  
			  )  
			  
			  INSERT INTO [Indico].[dbo].[DistributorMapping] ([NewId], [OldId] )
			  VALUES(SCOPE_IDENTITY(), @DistributorID)
	
		FETCH NEXT FROM InsertDistributor INTO @DistributorID, @Distributor, @Address, @City, @PostCode, @Country, @Contact, @Phone, @Email
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
SELECT [ClientID]
      ,[Client]
      ,[Distributor_ID]
      ,[Address]
      ,[City]
      ,[PostCode]
      ,[Country]
      ,[Contact]
      ,[Phone]
      ,[Email]
FROM [Product_1].[dbo].[Client] 
OPEN InsertClient 
	FETCH NEXT FROM InsertClient INTO @ClientID, @Client, @DistributorID, @Address, @City, @PostCode, @Country, @Contact, @Phone, @Email
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	SET @I= @I+1
				 
		IF EXISTS(SELECT [DistributorID]  FROM [Product_1].[dbo].[Distributor]  WHERE [DistributorID] =  @DistributorID )
			BEGIN
			
				IF EXISTS (SELECT [NewId] FROM [Indico].[dbo].[DistributorMapping] WHERE [OldId] = @DistributorID)
					BEGIN
					 SET @ID = (SELECT [NewId] FROM [Indico].[dbo].[DistributorMapping] WHERE [OldId] = @DistributorID)
					END
				ELSE
					BEGIN
					 SET @ID = (SELECT c.[ID] FROM [Indico].[dbo].[Company] c 
										WHERE c.[IsDistributor] = 1 and c.[Name] COLLATE DATABASE_DEFAULT = (
																					 SELECT d.[Distributor] 
																					 FROM [Product_1].[dbo] .[Distributor] d 
																					 WHERE d.[DistributorID] = @DistributorID) COLLATE DATABASE_DEFAULT
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
		
		FETCH NEXT FROM InsertClient INTO @ClientID, @Client, @DistributorID, @Address, @City, @PostCode, @Country, @Contact, @Phone, @Email
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
DECLARE @DistributorID AS int


DECLARE InsertNullDistributorClient CURSOR FAST_FORWARD FOR 

SELECT [ClientID]
      ,[Client]
      ,[Distributor_ID]
      ,[Address]
      ,[City]
      ,[PostCode]
      ,[Country]
      ,[Contact]
      ,[Phone]
      ,[Email]
FROM [Product_1].[dbo].[Client] 
WHERE [Distributor_ID] IS NULL
  
OPEN InsertNullDistributorClient 
	FETCH NEXT FROM InsertNullDistributorClient INTO @ClientID, @Client, @DistributorID, @Address, @City, @PostCode, @Country, @Contact, @Phone, @Email
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
						(SELECT GETDATE()),
						1,
						(SELECT GETDATE())	     
					  )  
				 INSERT INTO [Indico].[dbo].[ClientMapping] ([NewId], [OldId] )
				 VALUES(SCOPE_IDENTITY(), @ClientID)				 		      
		
		FETCH NEXT FROM InsertNullDistributorClient INTO @ClientID, @Client, @DistributorID, @Address, @City, @PostCode, @Country, @Contact, @Phone, @Email
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
FROM [Product_1].[dbo].[Fabric] f
	LEFT OUTER JOIN [Indico] .[dbo] .[FabricCode]  fc
		ON f.[FabricCode] COLLATE DATABASE_DEFAULT = fc.[Code] COLLATE DATABASE_DEFAULT
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

--**----**----**----**----**----**----** UPDATE DISTRIBUTOR COORDINATOR --**----**----**----**----**----**----**
--BEGIN TRAN

DECLARE @DistributorID AS int
DECLARE @Distributor AS NVARCHAR(255)
DECLARE @Coordinator AS int
DECLARE @CID AS int
DECLARE @COMID AS int

DECLARE DeleteDistributor CURSOR FAST_FORWARD FOR 
SELECT [DistributorID]
      ,[Distributor]
      ,[Coordinator_ID]     
FROM [Product_1].[dbo].[Distributor]

OPEN DeleteDistributor 
	FETCH NEXT FROM DeleteDistributor INTO @DistributorID, @Distributor, @Coordinator
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		SET @COMID = (SELECT [ID] FROM [Indico].[dbo].[Company] WHERE[Type] = 3)
		
		 IF((SELECT [Coordinator] FROM [Product_1].[dbo].[Coordinator] WHERE [CoordinatorID] = @Coordinator) = 'MBASSETT')
			BEGIN
			 SET @CID = (SELECT [ID] FROM [Indico].[dbo].[User] WHERE [GivenName] = 'Mark' AND [FamilyName] = 'Bassett' AND [Company] = @COMID)
			END
		 
		 IF((SELECT [Coordinator] FROM [Product_1].[dbo].[Coordinator] WHERE [CoordinatorID] = @Coordinator) = 'MINGRAM')
			BEGIN
			 SET @CID = (SELECT [ID] FROM [Indico].[dbo].[User] WHERE [GivenName] = 'Mark' AND [FamilyName] = 'Ingram' AND [Company] = @COMID)
			END
			
		 IF((SELECT [Coordinator] FROM [Product_1].[dbo].[Coordinator] WHERE [CoordinatorID] = @Coordinator) = 'BEN LESKE')
			BEGIN
			 SET @CID = (SELECT [ID] FROM [Indico].[dbo].[User] WHERE [GivenName] = 'Ben' AND [FamilyName] = 'Leske' AND [Company] = @COMID)
			END
		 
		 IF((SELECT [Coordinator] FROM [Product_1].[dbo].[Coordinator] WHERE [CoordinatorID] = @Coordinator) = 'JENNA KING')
			BEGIN
			 SET @CID = (SELECT [ID] FROM [Indico].[dbo].[User] WHERE [GivenName] = 'Jenna' AND [FamilyName] = 'King' AND [Company] = @COMID)
			END
		
		 IF((SELECT [Coordinator] FROM [Product_1].[dbo].[Coordinator] WHERE [CoordinatorID] = @Coordinator) = 'BEC')
			BEGIN
			 SET @CID = (SELECT [ID] FROM [Indico].[dbo].[User] WHERE [GivenName] = 'Bec' AND [FamilyName] = 'Glastonbury' AND [Company] = @COMID)
			END
			
		 IF((SELECT [Coordinator] FROM [Product_1].[dbo].[Coordinator] WHERE [CoordinatorID] = @Coordinator) = 'BRETT')
			BEGIN
			 SET @CID = (SELECT [ID] FROM [Indico].[dbo].[User] WHERE [GivenName] = 'Brett' AND [FamilyName] = 'McMahon' AND [Company] = @COMID)
			END
		 
		  IF((SELECT [Coordinator] FROM [Product_1].[dbo].[Coordinator] WHERE [CoordinatorID] = @Coordinator) = 'NAJREE')
			BEGIN
			 SET @CID = (SELECT [ID] FROM [Indico].[dbo].[User] WHERE [GivenName] = 'Najree' AND [FamilyName] = 'Lydiard' AND [Company] = @COMID)
			END	 
		
		 UPDATE [Indico].[dbo].[Company] SET [Coordinator] = @CID WHERE [Name] = @Distributor AND IsDistributor = 1
	
		SET @CID = NULL
	
		FETCH NEXT FROM DeleteDistributor INTO @DistributorID, @Distributor, @Coordinator
	END 

CLOSE DeleteDistributor 
DEALLOCATE DeleteDistributor		
GO

--ROLLBACK TRAN
--**----**----**----**----**----**----**--**----**----**----**----**----**----**--**----**----**----**----**----**----**--**----**----**----**----**----**----**

--**----**----**----**----**-- INSERT VISUALLAYOUT --**----**----**----**----**----**----**----**----**--
--BEGIN TRAN

DECLARE @ProductID AS NVARCHAR(255)
DECLARE @Product AS NVARCHAR(255)
DECLARE @Distributor AS NVARCHAR(255)
DECLARE @Client AS NVARCHAR(255)
DECLARE @Pattern AS NVARCHAR(255)
DECLARE @DefaultFabric AS NVARCHAR(255)
DECLARE @DID AS int
DECLARE @CID AS int
DECLARE @FID AS int
DECLARE @PID AS int

DECLARE InsertVisualLayout CURSOR FAST_FORWARD FOR 

SELECT [ProdID]
      ,[Product]
      ,[Distributor_ID]
      ,[Client_ID]
      ,[Pattern] 
      ,[Default_Fabric]      
  FROM [Product_1].[dbo].[Product]
  
OPEN InsertVisualLayout 
	FETCH NEXT FROM InsertVisualLayout INTO @ProductID, @Product, @Distributor, @Client, @Pattern, @DefaultFabric
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		IF (EXISTS(SELECT [Code] FROM [Indico].[dbo].[FabricCode] WHERE [Code] = @DefaultFabric) AND EXISTS 
				  (SELECT [Number] FROM [Indico].[dbo].[Pattern] WHERE [Number] = @Pattern))   
		BEGIN  			 
			----- SET DISTRIBUTOR
			 
				IF EXISTS(SELECT [NewId] FROM [Indico].[dbo].[DistributorMapping] WHERE [OldId] = @Distributor)
					BEGIN
					 SET @DID = (SELECT [NewId] FROM [Indico].[dbo].[DistributorMapping] WHERE [OldId] = @Distributor)
					END
				ELSE
					BEGIN
					 SET @DID = (SELECT c.[ID] FROM [Indico].[dbo].[Company] c 
											WHERE c.[IsDistributor] = 1 and c.[Name] COLLATE DATABASE_DEFAULT = (
																						 SELECT d.[Distributor] 
																						 FROM [Product_1].[dbo].[Distributor] d 
																						 WHERE d.[DistributorID] = @Distributor)
																					  COLLATE DATABASE_DEFAULT )	
					END
				
				------ SET CLIENT
				IF EXISTS (SELECT [NewId] FROM [Indico].[dbo].[ClientMapping] WHERE [OldId] = @Client)
					BEGIN
						SET	@CID = (SELECT [NewId] FROM [Indico].[dbo].[ClientMapping] WHERE [OldId] = @Client)
					END
				ELSE
					BEGIN
					 SET @CID = (SELECT c.[ID] FROM [Indico].[dbo].[Client] c 
											   WHERE c.[Name] COLLATE DATABASE_DEFAULT = (
																 SELECT p.[Client] 
																 FROM [Product_1].[dbo].[Client] p 
																 WHERE p.[ClientID] = @Client) 
															  COLLATE DATABASE_DEFAULT )
					END
				
				------- SET FABRICCODE
				IF EXISTS(SELECT [NewId] FROM [Indico].[dbo].[FabricMapping] WHERE [OldId] = @DefaultFabric)
					BEGIN
						SET @FID = (SELECT [NewId] FROM [Indico].[dbo].[FabricMapping] WHERE [OldId] = @DefaultFabric)
					END
				ELSE
					BEGIN
					 SET @FID = (SELECT f.[ID] FROM [Indico].[dbo].[FabricCode] f 
												WHERE f.[Code] = @DefaultFabric)
					END							
					
			 -------INSERT VisualLayout
			 
				INSERT INTO [Indico].[dbo].[VisualLayout] ([NamePrefix], [Description], [Pattern], [FabricCode], [Client], [Coordinator], [Distributor], [NNPFilePath],
															[NameSuffix], [CreatedDate], [IsCommonProduct])
															
				VALUES(
						@Product,
						NULL,
					    (SELECT p.[ID] FROM [Indico].[dbo].[Pattern] p WHERE p.[Number] = @Pattern),
						@FID,
						@CID,
						NULL,  
						@DID, 
						NULL,
						NULL,
						(SELECT GETDATE()),
						0	
					  )										
		END
		FETCH NEXT FROM InsertVisualLayout INTO @ProductID, @Product, @Distributor, @Client, @Pattern, @DefaultFabric
	END 

CLOSE InsertVisualLayout 
DEALLOCATE InsertVisualLayout
GO

--ROLLBACK TRAN
--**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**----**--


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


















