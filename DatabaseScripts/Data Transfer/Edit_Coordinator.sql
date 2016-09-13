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

--**----**----**----**----**----**----** UPDATE VISUALLAYOUT COORDINATOR --**----**----**----**----**----**----**

--BEGIN TRAN

DECLARE @Product AS NVARCHAR(255)
DECLARE @Coordinator AS int
DECLARE @CID AS int
DECLARE @COMID AS int

DECLARE DeleteDistributor CURSOR FAST_FORWARD FOR 
SELECT [Product]      
      ,[Product_Coordinator]
FROM [Product_1].[dbo].[Product]

OPEN DeleteDistributor 
	FETCH NEXT FROM DeleteDistributor INTO @Product, @Coordinator
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		
		IF EXISTS((SELECT [ID] FROM [Indico].[dbo].[VisualLayout] WHERE [NamePrefix] = @Product))
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
				
				 UPDATE [Indico].[dbo].[VisualLayout] SET [Coordinator]  = @CID WHERE [NamePrefix] = @Product 
			
				SET @CID = NULL
	END
		FETCH NEXT FROM DeleteDistributor INTO @Product, @Coordinator
	END 

CLOSE DeleteDistributor 
DEALLOCATE DeleteDistributor		
GO

--ROLLBACK TRAN
--**----**----**----**----**----**----**--**----**----**----**----**----**----**--**----**----**----**----**----**----**--**----**----**----**----**----**----**