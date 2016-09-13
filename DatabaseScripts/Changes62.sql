USE [Indico] 
GO

--**--**--**--**--**--**--**--**--** Delete The Accessory Table --**--**--**--**--**--**--**--**--**
DELETE [dbo].[PatternSupportAccessory]
	FROM [dbo].[PatternSupportAccessory] psa
		JOIN [dbo].[CostSheet] cs
			ON cs.[ID] = psa.[CostSheet]

GO

DELETE [dbo].[PatternSupportFabric]
	FROM [dbo].[PatternSupportFabric] psf
		JOIN [dbo].[CostSheet] cs
			ON cs.[ID] = psf.[CostSheet]

GO

DELETE FROM [dbo].[CostSheet]
GO

DELETE FROM [dbo].[Accessory]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** DELETE CostSheet Column from the Pattern Support Accessory Table --**--**--**--**--**--**--**--**--**

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PatternSupportAccessory_CostSheet]') AND parent_object_id = OBJECT_ID(N'[dbo].[PatternSupportAccessory]'))
ALTER TABLE [dbo].[PatternSupportAccessory] DROP CONSTRAINT [FK_PatternSupportAccessory_CostSheet]
GO

ALTER TABLE [dbo].[PatternSupportAccessory]
DROP COLUMN [CostSheet]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** ADD Pattern Column to The Pattern Support Accessory Table --**--**--**--**--**--**--**--**--**
ALTER TABLE [dbo].[PatternSupportAccessory]
ADD [Pattern] [int] NOT NULL
GO

ALTER TABLE [dbo].[PatternSupportAccessory]  WITH CHECK ADD  CONSTRAINT [FK_PatternSupportAccessory_Pattern] FOREIGN KEY([Pattern])
REFERENCES [dbo].[Pattern] ([ID])
GO

ALTER TABLE [dbo].[PatternSupportAccessory] CHECK CONSTRAINT [FK_PatternSupportAccessory_Pattern]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

----**--**--**--**--**--**--**--**--** Upadte Image Table --**--**--**--**--**--**--**--**--**
--DECLARE @VLID AS int 

--SET @VLID = (SELECT TOP(1) [ID] FROM [dbo].[Image] WHERE [VisualLayout] = 25722)

--UPDATE [dbo].[Image] SET [IsHero]= 0 WHERE [ID] = @VLID
--GO

----**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Update The Fabric Table --**--**--**--**--**--**--**--**--**

DECLARE @Code AS nvarchar(255)
DECLARE @Desc AS nvarchar(255)
DECLARE @Width AS nvarchar(255)
DECLARE @Const AS nvarchar(255)
DECLARE @GSM AS nvarchar(255)
DECLARE @Color AS nvarchar(255)
DECLARE @Price AS decimal (8,2)
DECLARE @Unit AS int
DECLARE @Supplier AS int
DECLARE @FabricID AS int
DECLARE @SupplierID AS int
DECLARE @UnitID AS int
DECLARE @ColorID AS int

DECLARE FabricCursor CURSOR FAST_FORWARD FOR
 
SELECT [FabricCode]
      ,[FabricDesc]
      ,[FabWidth]
      ,[FabConst]
      ,[FabGSM]
      ,[FabColour]      
      ,[FabricPrice]      
      ,[Unit]
      ,[Supplier]       
FROM [Indman_Sub_CostSheetsSQL].[dbo].[Fabric]
  
OPEN FabricCursor 
	FETCH NEXT FROM FabricCursor INTO @Code, @Desc, @Width , @Const, @GSM, @Color, @Price, @Unit, @Supplier   
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
		SET @FabricID = (SELECT f.[ID] FROM [Indico].[dbo].[FabricCode] f WHERE f.[Code] = @Code)
		SET @SupplierID = (SELECT s.[ID] FROM [Indico].[dbo].[Supplier] s WHERE s.[Name] = (SELECT ss.[SupplierName] FROM [Indman_Sub_CostSheetsSQL].[dbo].[Supplier] ss WHERE ss.[SupplierID] = @Supplier))
		SET @UnitID= (SELECT u.[ID] FROM [Indico].[dbo].[Unit] u WHERE u.[Name] = (SELECT uu.[Unit] FROM [Indman_Sub_CostSheetsSQL].[dbo].[Unit] uu WHERE uu.[UnitID] = @Unit))
		SET @ColorID = (SELECT ac.[ID] FROM [Indico].[dbo].[AccessoryColor] ac WHERE ac.[Name] = @Color)
		
		UPDATE [dbo].[FabricCode] 
		SET [GSM] = @GSM,
			[Supplier] = @SupplierID,
			[FabricPrice] = @Price,
			[Fabricwidth] = @Width,
			[Unit] = @UnitID,
			[FabricColor] = @ColorID
		WHERE [ID] = @FabricID
		
		FETCH NEXT FROM FabricCursor INTO  @Code, @Desc, @Width , @Const, @GSM, @Color, @Price, @Unit, @Supplier   
	END
CLOSE FabricCursor 
DEALLOCATE FabricCursor
-----/--------
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**



--**--**--**--**--**--**--**--**--** Insert The Accessory Category Table --**--**--**--**--**--**--**--**--**
INSERT INTO [Indico].[dbo].[AccessoryCategory] ([Name], [Code]) VALUES ('VISOR', 'V')
GO

INSERT INTO [Indico].[dbo].[AccessoryCategory] ([Name], [Code]) VALUES ('Bonding', 'BO')
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Insert The Accessory Table --**--**--**--**--**--**--**--**--**

DECLARE @Code AS nvarchar(255)
DECLARE @Desc AS nvarchar(255)
DECLARE @Price AS decimal (8,2)
DECLARE @SuppCode AS nvarchar(255)
DECLARE @Unit AS int
DECLARE @Category AS int
DECLARE @Supplier AS int
DECLARE @FabricID AS int
DECLARE @SupplierID AS int
DECLARE @UnitID AS int
DECLARE @ColorID AS int
DECLARE @CategoryID AS int
DECLARE @CATEGORYNAME AS nvarchar(255)

DECLARE FabricCursor CURSOR FAST_FORWARD FOR
 
SELECT [ItemCode]
      ,[ItemDesc]
      ,[ItemCost]
      ,[SuppCode]     
      ,[Unit]
      ,[AccCat]
      ,[Supplier]     
FROM [Indman_Sub_CostSheetsSQL].[dbo].[Accessory]
WHERE [AccCat] IS NOT NULL
  
OPEN FabricCursor 
	FETCH NEXT FROM FabricCursor INTO @Code, @Desc, @Price, @SuppCode, @Unit, @Category, @Supplier
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
		SET @CATEGORYNAME = (SELECT aa.[AccCategory] FROM [Indman_Sub_CostSheetsSQL].[dbo].[AccessoryCategory] aa WHERE aa.[AccCatID] = @Category )
		SET @CategoryID = (SELECT a.[ID] FROM [Indico].[dbo].[AccessoryCategory] a WHERE a.[Name] = @CATEGORYNAME)
		SET @SupplierID = (SELECT s.[ID] FROM [Indico].[dbo].[Supplier] s WHERE s.[Name] = (SELECT ss.[SupplierName] FROM [Indman_Sub_CostSheetsSQL].[dbo].[Supplier] ss WHERE ss.[SupplierID] = @Supplier))
		SET @UnitID= (SELECT u.[ID] FROM [Indico].[dbo].[Unit] u WHERE u.[Name] = (SELECT uu.[Unit] FROM [Indman_Sub_CostSheetsSQL].[dbo].[Unit] uu WHERE uu.[UnitID] = @Unit))
		
		
	 INSERT INTO [Indico].[dbo].[Accessory]
            ([Name], [Code], [AccessoryCategory], [Description], [Cost], [SuppCode], [Unit], [Supplier])
     VALUES (@Code, SUBSTRING(@Code, 1, 2), @CategoryID, @Desc, @Price, @SuppCode, @UnitID, @SupplierID)

			
		FETCH NEXT FROM FabricCursor INTO  @Code, @Desc, @Price, @SuppCode, @Unit, @Category, @Supplier
	END
CLOSE FabricCursor 
DEALLOCATE FabricCursor
-----/--------
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--** Insert The CostSheet Table --**--**--**--**--**--**--**--**--**

DECLARE @Pattern AS int
DECLARE @PatternNumber AS nvarchar(255)      
DECLARE @MainFabric AS int
DECLARE @HPCost AS float 
DECLARE @LabelCost AS float 
DECLARE @FOBExp AS float 
DECLARE @CM AS float 
DECLARE @Finance AS float 
DECLARE @Wastage AS float
DECLARE @JKFOB AS float 
DECLARE @Exch AS float 
DECLARE @CF1 AS nvarchar(255) 
DECLARE @CONS1 AS float 
DECLARE @RT1 AS float 
DECLARE @CST1 AS float 
DECLARE @CF2 AS nvarchar(255) 
DECLARE @CONS2 AS float 
DECLARE @RT2 AS float 
DECLARE @CF3 AS nvarchar(255) 
DECLARE @CST2 AS float 
DECLARE @CONS3 AS float 
DECLARE @RT3 AS float 
DECLARE @CST3 AS float 
DECLARE @INKCONS AS float 
DECLARE @INKRT AS float 
DECLARE @INKCST AS float 
DECLARE @SUBcons AS float 
DECLARE @PCONS AS float 
DECLARE @PAPRT AS float 
DECLARE @PAPCST AS float 
DECLARE @DUTYRATE AS float 
DECLARE @MARGINRATE AS float 
DECLARE @JKAUD AS float 
DECLARE @FRTAUD AS float 
DECLARE @CFAUD AS float 
DECLARE @DUTY AS float 
DECLARE @MGTOH AS float 
DECLARE @INDOH AS float 
DECLARE @DEPR AS float 
DECLARE @LANDED AS float 
DECLARE @INDIMANCIF AS float 
DECLARE @QUOTEDCIF AS float 
DECLARE @FOBFACTOR AS float 
DECLARE @INDIMANFOB AS float 
DECLARE @CALMGN AS float 
DECLARE @ACTMGN AS float 
DECLARE @MP AS float 
DECLARE @QUOTEDMP AS float 
DECLARE @JK_SMV AS float 
DECLARE @JK_SMV_RATE AS float 
DECLARE @CCM AS float 
DECLARE @PatternID AS int
DECLARE @FabricID AS int
DECLARE @CostSheetID AS int
DECLARE @AccPatternID AS int
DECLARE @CostSheetPattern AS int 
DECLARE @FabCons AS float
DECLARE @FabCode AS int
DECLARE @AccessoryID AS int
DECLARE @PatternFabricID AS int 

DECLARE CostSheetCursor CURSOR FAST_FORWARD FOR
 
SELECT [Pattern]
	  ,[PatternNumber]
      ,[MainFabric]      
      ,[HPCost]
      ,[LabelCost]
      ,[FOBExp]
      ,[CM]
      ,[Finance]
      ,[Wastage]
      ,[JKFOB]    
      ,[Exch]
      ,[CF1]
      ,[CONS1]
      ,[RT1]
      ,[CST1]
      ,[CF2]
      ,[CONS2]
      ,[RT2]
      ,[CST2]
      ,[CF3]
      ,[CONS3]
      ,[RT3]
      ,[CST3]
      ,[INKCONS]
      ,[INKRT]
      ,[INKCST]
      ,[SUBcons]
      ,[PCONS]
      ,[PAPRT]
      ,[PAPCST]
      ,[DUTYRATE]
      ,[MARGINRATE]
      ,[JKAUD]
      ,[FRTAUD]
      ,[CFAUD]
      ,[DUTY]
      ,[MGTOH]
      ,[INDOH]
      ,[DEPR]
      ,[LANDED]
      ,[INDIMANCIF]
      ,[QUOTEDCIF]
      ,[FOBFACTOR]
      ,[INDIMANFOB]
      ,[CALMGN]
      ,[ACTMGN]
      ,[MP]
      ,[QUOTEDMP]     
      ,[JK_SMV]
      ,[JK_SMV_RATE]
      ,[CCM]      
  FROM [Indman_Sub_CostSheetsSQL].[dbo].[CostSheet]
  WHERE [MainFabric] IS NOT NULL
  
OPEN CostSheetCursor 
	FETCH NEXT FROM CostSheetCursor INTO @Pattern, @PatternNumber, @MainFabric, @HPCost, @LabelCost, @FOBExp, @CM, @Finance, @Wastage, @JKFOB, @Exch, @CF1, @CONS1, @RT1, @CST1, @CF2, @CONS2, 
										 @RT2, @CST2, @CF3, @CONS3, @RT3, @CST3, @INKCONS, @INKRT, @INKCST, @SUBcons, @PCONS, @PAPRT, @PAPCST, @DUTYRATE, @MARGINRATE, @JKAUD, @FRTAUD, 
										 @CFAUD, @DUTY, @MGTOH, @INDOH, @DEPR, @LANDED, @INDIMANCIF, @QUOTEDCIF, @FOBFACTOR, @INDIMANFOB, @CALMGN, @ACTMGN, @MP, @QUOTEDMP, @JK_SMV, 
										 @JK_SMV_RATE, @CCM
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
			
			IF(@PatternNumber IS NOT NULL)	
				BEGIN
				
					SET @PatternID = (SELECT p.[ID] FROM [Indico].[dbo].[Pattern] p WHERE p.[Number] = @PatternNumber)
				END
			ELSE
				BEGIN
				
					SET @PatternID = (SELECT p.[ID] FROM [Indico].[dbo].[Pattern] p WHERE p.[Number] = (SELECT pp.[PatternNumber] FROM [Indman_Sub_CostSheetsSQL].[dbo].[Pattern] pp WHERE pp.[ID] = @Pattern))
					
				END		
	
		
		SET @FabricID = (SELECT fc.[ID] FROM [Indico].[dbo].[FabricCode] fc WHERE fc.[Code] = (SELECT ff.[FabricCode] FROM [Indman_Sub_CostSheetsSQL].[dbo].[Fabric] ff WHERE ff.[FabricID] = @MainFabric))

					IF (EXISTS((SELECT fc.[ID] FROM [Indico].[dbo].[FabricCode] fc WHERE fc.[Code] = (SELECT ff.[FabricCode] FROM [Indman_Sub_CostSheetsSQL].[dbo].[Fabric] ff WHERE ff.[FabricID] = @MainFabric))) AND @PatternID IS NOT NULL)	
					
						BEGIN
								INSERT INTO [Indico].[dbo].[CostSheet]
						           ([Pattern], [Fabric], [TotalFabricCost], [TotalAccessoriesCost], [HPCost], [LabelCost], [Other], [Finance], [Wastage], [FOBExp], [CM], [JKFOBCost], [QuotedFOBCost]
						           ,[Roundup], [SMV], [SMVRate], [CalculateCM], [Creator], [CreatedDate], [Modifier], [ModifiedDate], [SubWastage], [SubFinance], [SubCons], [DutyRate], [CF1], [CF2]
						           ,[CF3], [CONS1], [CONS2], [CONS3], [InkCons], [PaperCons], [Rate1], [Rate2], [Rate3], [InkRate], [PaperRate], [MarginRate], [FOBAUD], [Duty], [Cost1], [Cost2]
						           ,[Cost3], [InkCost], [PaperCost], [MGTOH], [IndicoOH], [Depr], [Landed], [IndimanCIF], [QuotedCIF], [FobFactor], [IndimanFOB], [CalMGN], [ActMgn], [MP], [QuotedMP]
						           ,[ExchangeRate], [AirFregiht], [ImpCharges])
								VALUES
						           (@PatternID
						           ,@FabricID
						           ,NULL
						           ,NULL
						           ,CONVERT(decimal(8,2), @HPCost)
						           ,CONVERT(decimal(8,2), @LabelCost)
						           ,CONVERT(decimal(8,2), @FOBExp)
						           ,CONVERT(decimal(8,2), @Finance)
						           ,CONVERT(decimal(8,2), @Wastage)
						           ,CONVERT(decimal(8,2), '0.00')
						           ,CONVERT(decimal(8,2), ISNULL(@CM, '0.00'))
						           ,CONVERT(decimal(8,2), ISNULL(@JKFOB, '0.00'))
						           ,NULL
						           ,NULL
						           ,CONVERT(decimal(8,2), @JK_SMV)
						           ,CONVERT(decimal(8,2), @JK_SMV_RATE)
						           ,CONVERT(decimal(8,2), @CCM)
						           ,1
						           ,GETDATE()
						           ,1
						           ,GETDATE()
						           ,NULL
						           ,NULL
						           ,CONVERT(decimal(8,2), @SUBcons)
						           ,CONVERT(decimal(8,2), @DUTYRATE)
						           ,@CF1
						           ,@CF2
						           ,@CF3
						           ,CONVERT(decimal(8,2), @CONS1)
						           ,CONVERT(decimal(8,2), @CONS2)
						           ,CONVERT(decimal(8,2), @CONS3)
						           ,CONVERT(decimal(8,2), @INKCONS)
						           ,CONVERT(decimal(8,2), @PCONS)
						           ,CONVERT(decimal(8,2), @RT1)
						           ,CONVERT(decimal(8,2), @RT2)
						           ,CONVERT(decimal(8,2), @RT3)
						           ,CONVERT(decimal(8,2), @INKRT)
						           ,CONVERT(decimal(8,2), @PAPRT)
						           ,CONVERT(decimal(8,2), @MARGINRATE)
						           ,CONVERT(decimal(8,2), @JKAUD)
						           ,CONVERT(decimal(8,2), @DUTY)
						           ,CONVERT(decimal(8,2), @CST1)
						           ,CONVERT(decimal(8,2), @CST2)
						           ,CONVERT(decimal(8,2), @CST3)
						           ,CONVERT(decimal(8,2), @INKCST)
						           ,CONVERT(decimal(8,2), @PAPCST)
						           ,CONVERT(decimal(8,2), @MGTOH)
						           ,CONVERT(decimal(8,2), @INDOH)
						           ,CONVERT(decimal(8,2), @DEPR)
						           ,CONVERT(decimal(8,2), @LANDED)
						           ,CONVERT(decimal(8,2), @INDIMANCIF)
						           ,CONVERT(decimal(8,2), @QUOTEDCIF)
						           ,CONVERT(decimal(8,2), @FOBFACTOR)
						           ,CONVERT(decimal(8,2), @INDIMANFOB)
						           ,CONVERT(decimal(8,2), @CALMGN)
						           ,CONVERT(decimal(8,2), @ACTMGN)
						           ,CONVERT(decimal(8,2), @MP)
						           ,CONVERT(decimal(8,2), @QUOTEDMP)
						           ,CONVERT(decimal(8,2), @Exch)
						           ,CONVERT(decimal(8,2), @FRTAUD)
						           ,CONVERT(decimal(8,2), @CFAUD))
						       
						       SET @CostSheetID = SCOPE_IDENTITY()						       
						       				       
						       DECLARE FabricCostCursor CURSOR FAST_FORWARD FOR
			 
										SELECT [PatternID]
											  ,[FabCons]      
											  ,[Fabric]     
										FROM [Indman_Sub_CostSheetsSQL].[dbo].[FabCost]
										WHERE [PatternID] IS NOT NULL AND 
											  [Fabric] IS NOT NULL AND
											  [PatternID] = @Pattern
											    
										OPEN FabricCostCursor 
											FETCH NEXT FROM FabricCostCursor INTO @CostSheetPattern, @FabCons, @FabCode
											WHILE @@FETCH_STATUS = 0 
											BEGIN 											
													
													SET @PatternFabricID = (SELECT a.[ID] FROM [Indico].[dbo].[FabricCode] a WHERE a.[Code] = (SELECT aa.[FabricCode]  FROM [Indman_Sub_CostSheetsSQL].[dbo].[Fabric] aa WHERE aa.[FabricID] = @FabCode))
													 IF (@PatternFabricID IS NOT NULL)
														BEGIN
													 													
															INSERT INTO [Indico].[dbo].[PatternSupportFabric] ([Fabric], [FabConstant], [CostSheet]) VALUES (@PatternFabricID, ISNULL(@FabCons, '0.00'), @CostSheetID)
													
														END			
															
											FETCH NEXT FROM FabricCostCursor INTO  @CostSheetPattern, @FabCons, @FabCode
										END
								CLOSE FabricCostCursor 
								DEALLOCATE FabricCostCursor  	
								
								PRINT @PatternNumber
								PRINT '-------------------------'
								-- DECLARE FabricCostPatternNumberCursor CURSOR FAST_FORWARD FOR
			 
								--		SELECT [PatternID]
								--			  ,[FabCons]      
								--			  ,[Fabric]     
								--		FROM [Indman_Sub_CostSheetsSQL].[dbo].[FabCost]
								--		WHERE [PatternID] IS NOT NULL AND 
								--			  [Fabric] IS NOT NULL AND
								--			  [PatternID] = (SELECT ppp.[ID] FROM [Indman_Sub_CostSheetsSQL].[dbo].[Pattern] ppp WHERE ppp.[PatternNumber] =  @PatternNumber)
											    
								--		OPEN FabricCostPatternNumberCursor 
								--			FETCH NEXT FROM FabricCostPatternNumberCursor INTO @CostSheetPattern, @FabCons, @FabCode
								--			WHILE @@FETCH_STATUS = 0 
								--			BEGIN 											
													
								--					SET @PatternFabricID = (SELECT a.[ID] FROM [Indico].[dbo].[FabricCode] a WHERE a.[Code] = (SELECT aa.[FabricCode]  FROM [Indman_Sub_CostSheetsSQL].[dbo].[Fabric] aa WHERE aa.[FabricID] = @FabCode))
								--					 IF (@PatternFabricID IS NOT NULL)
								--						BEGIN
													 													
								--							INSERT INTO [Indico].[dbo].[PatternSupportFabric] ([Fabric], [FabConstant], [CostSheet]) VALUES (@PatternFabricID, ISNULL(@FabCons, '0.00'), @CostSheetID)
													
								--						END			
															
								--			FETCH NEXT FROM FabricCostPatternNumberCursor INTO  @CostSheetPattern, @FabCons, @FabCode
								--		END
								--CLOSE FabricCostPatternNumberCursor 
								--DEALLOCATE FabricCostPatternNumberCursor  				               
						           
					END
           			
	FETCH NEXT FROM CostSheetCursor INTO   @Pattern, @PatternNumber, @MainFabric, @HPCost, @LabelCost, @FOBExp, @CM, @Finance, @Wastage, @JKFOB, @Exch, @CF1, @CONS1, @RT1, @CST1, @CF2, @CONS2, 
										   @RT2, @CST2, @CF3, @CONS3, @RT3, @CST3, @INKCONS, @INKRT, @INKCST, @SUBcons, @PCONS, @PAPRT, @PAPCST, @DUTYRATE, @MARGINRATE, @JKAUD, @FRTAUD, 
										   @CFAUD, @DUTY, @MGTOH, @INDOH, @DEPR, @LANDED, @INDIMANCIF, @QUOTEDCIF, @FOBFACTOR, @INDIMANFOB, @CALMGN, @ACTMGN, @MP, @QUOTEDMP, @JK_SMV, 
										   @JK_SMV_RATE, @CCM
	END
CLOSE CostSheetCursor 
DEALLOCATE CostSheetCursor
-----/--------
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

DECLARE @Pattern AS int 
DECLARE @AccCons AS float
DECLARE @AccCode AS int
DECLARE @AccessoryID AS int
DECLARE @PatternID AS int

DECLARE AccessoryCostCursor CURSOR FAST_FORWARD FOR
			 
SELECT [PatternID]
	  ,[AccCons]      
	  ,[AccCode]          
FROM [Indman_Sub_CostSheetsSQL].[dbo].[AccCost]
WHERE [PatternID] IS NOT NULL AND 
	  [AccCode] IS NOT NULL 
	    
OPEN AccessoryCostCursor 
	FETCH NEXT FROM AccessoryCostCursor INTO @Pattern, @AccCons, @AccCode
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
	SET @PatternID = (SELECT p.[ID] FROM [Indico].[dbo].[Pattern] p WHERE p.[Number] = (SELECT pp.[PatternNumber] FROM [Indman_Sub_CostSheetsSQL].[dbo].[Pattern] pp WHERE pp.[ID] = @Pattern))
	SET @AccessoryID = (SELECT TOP 1 a.[ID] FROM [Indico].[dbo].[Accessory] a WHERE a.[Name] = (SELECT aa.[ItemCode]  FROM [Indman_Sub_CostSheetsSQL].[dbo].[Accessory] aa WHERE aa.[AccID] = @AccCode))
	
	IF (@PatternID IS NOT NULL AND @AccessoryID IS NOT NULL )
		BEGIN
				INSERT INTO [Indico].[dbo].[PatternSupportAccessory] ([Accessory], [AccConstant], [Pattern]) VALUES (@AccessoryID, @AccCons, @PatternID)
		END
			
	FETCH NEXT FROM AccessoryCostCursor INTO  @Pattern, @AccCons, @AccCode
END
CLOSE AccessoryCostCursor 
DEALLOCATE AccessoryCostCursor
			
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--Insert ViewCostSheet Page--**--**--**--**--**--**--**--**--**--**--**--**--**

INSERT INTO [Indico].[dbo].[Page] ([Name], [Title], [Heading]) VALUES('/ViewCostSheets.aspx', 'Cost Sheets', 'Cost Sheets')
GO

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Position AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewCostSheets.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/EditIndimanPrice.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
--SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Position = (SELECT (MAX([Position])+1) FROM [dbo].[MenuItem] WHERE [Parent] = @Parent)

INSERT INTO [Indico].[dbo].[MenuItem]
           ([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible])
     VALUES
           (@Page, 'Cost Sheets', 'Cost Sheets', 1, @Parent, @Position , 1)
GO

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Role AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewCostSheets.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/EditIndimanPrice.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Indiman Administrator')

INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @Role)
GO

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Position AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewCostSheets.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPrices.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
--SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Position = (SELECT (MAX([Position])+1) FROM [dbo].[MenuItem] WHERE [Parent] = @Parent)

INSERT INTO [Indico].[dbo].[MenuItem]
           ([Page], [Name], [Description], [IsActive], [Parent], [Position], [IsVisible])
     VALUES
           (@Page, 'Cost Sheets', 'Cost Sheets', 1, @Parent, @Position , 1)
GO

DECLARE @Page AS int
DECLARE @ParentPage AS int
DECLARE @MenuItem AS int
DECLARE @Parent AS int
DECLARE @Role AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewCostSheets.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPrices.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)
SET @Role = (SELECT [ID] FROM [dbo].[Role] WHERE [Description] = 'Factory Administrator')

INSERT INTO [Indico].[dbo].[MenuItemRole] ([MenuItem], [Role]) VALUES (@MenuItem, @Role)
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**--**--Update CostSheet Page--**--**--**--**--**--**--**--**--**--**--**--**--**
						           
DECLARE @Page AS int
DECLARE @ParentPage AS int 
DECLARE @Parent AS int
DECLARE @MenuItem AS int
DECLARE @MasterPage AS int 
DECLARE @MasterMenuItem AS int 
DECLARE @MasterPartent As int
DECLARE @MainMenuItem AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewCostSheets.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewPrices.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL) 	
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)

SET @MasterPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/AddEditFactoryCostSheet.aspx')
SET @MasterPartent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MasterMenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @MasterPage AND [Parent] = @MasterPartent)

				

SET @MasterPartent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NOT NULL) 										

UPDATE [dbo].[MenuItem] SET [IsVisible] = 0, [Parent] = @MenuItem WHERE [ID] = @MasterMenuItem
GO

DECLARE @Page AS int
DECLARE @ParentPage AS int 
DECLARE @Parent AS int
DECLARE @MenuItem AS int
DECLARE @MasterPage AS int 
DECLARE @MasterMenuItem AS int 
DECLARE @MasterPartent As int
DECLARE @MainMenuItem AS int 

SET @Page = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/ViewCostSheets.aspx')
SET @ParentPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/EditIndimanPrice.aspx')
SET @Parent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL) 	
SET @MenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @Page AND [Parent] = @Parent)

SET @MasterPage = (SELECT [ID] FROM [dbo].[Page] WHERE [Name] = '/AddEditFactoryCostSheet.aspx')
SET @MasterPartent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NULL)
SET @MasterMenuItem = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @MasterPage AND [Parent] = @MasterPartent)

				

SET @MasterPartent = (SELECT [ID] FROM [dbo].[MenuItem] WHERE [Page] = @ParentPage AND [Parent] IS NOT NULL) 										

UPDATE [dbo].[MenuItem] SET [IsVisible] = 0, [Parent] = @MenuItem WHERE [ID] = @MasterMenuItem
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
DECLARE @Pattern AS int 
DECLARE @PatternTemp AS int

SET @Pattern = (SELECT [ID] FROM [dbo].[Pattern] WHERE [Number] = '052')
SET @PatternTemp = (SELECT TOP 1 [ID] FROM [dbo].[PatternTemplateImage] WHERE [Pattern] = @Pattern AND [IsHero] = 1)

DELETE FROM [dbo].[PatternTemplateImage] WHERE [ID] != @PatternTemp AND [Pattern] = @Pattern AND [IsHero] = 1
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

--**--**--**--**--**--**--**-UPDATE USER TABLE-**--**--**--**--**--**--**--**--**--**--**--**

UPDATE [dbo].[User] SET [Guid] = NEWID() WHERE [Guid] IS NULL
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
