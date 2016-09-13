USE [Indico]
GO
--**--**--**--**--**--**--**--**--** Insert New Fabrics --**--**--**--**--**--**--**--**--**
DECLARE @Code AS nvarchar(255)
DECLARE @Description AS nvarchar(255)
DECLARE @Width AS nvarchar(255)
DECLARE @FabConst AS nvarchar(255)
DECLARE @GSM AS nvarchar(255)
DECLARE @Color AS nvarchar(255)
DECLARE @SupplierCode AS nvarchar(255)
DECLARE @Price AS float
DECLARE @Unit AS int
DECLARE @Supplier AS int 
DECLARE @SupplierID AS int
DECLARE @UnitID AS int  
DECLARE @ColorID AS int 

DECLARE FabricCostCursor CURSOR FAST_FORWARD FOR

SELECT f.[FabricCode]
      ,f.[FabricDesc]
      ,f.[FabWidth]
      ,f.[FabConst]
      ,f.[FabGSM]
      ,f.[FabColour]
      ,f.[SupplierCode]
      ,f.[FabricPrice]      
      ,f.[Unit]
      ,f.[Supplier]   
FROM [Indman_Sub_CostSheetsSQL].[dbo].[Fabric] f 
	LEFT OUTER JOIN [Indico].[dbo].[FabricCode] fc
		ON  fc.[Code] = f.[FabricCode]
WHERE fc.[ID] IS NULL
			    
		OPEN FabricCostCursor 
			FETCH NEXT FROM FabricCostCursor INTO @Code, @Description, @Width, @FabConst, @GSM, @Color, @SupplierCode, @Price, @Unit, @Supplier  
			WHILE @@FETCH_STATUS = 0 
			BEGIN 					
			
						SET @SupplierID = (SELECT s.[ID] FROM [dbo].[Supplier] s WHERE s.[Name] = (SELECT ss.[SupplierName] FROM [Indman_Sub_CostSheetsSQL].[dbo].[Supplier] ss WHERE ss.[SupplierID] = @Supplier))						
						SET @UnitID = (SELECT u.[ID] FROM [dbo].[Unit] u WHERE u.[Name] = (SELECT uu.[Unit] FROM [Indman_Sub_CostSheetsSQL].[dbo].[Unit] uu WHERE uu.[UnitID] = @Unit))						
						SET @ColorID = (SELECT ac.[ID] FROM [dbo].[AccessoryColor] ac WHERE [Name] = @Color)
					INSERT INTO [Indico].[dbo].[FabricCode]
											   ([Code], [Name], [Material], [GSM], [Supplier], [Country],[DenierCount], [Filaments], [NickName], [SerialOrder]
											   ,[FabricPrice], [LandedCurrency], [Fabricwidth], [Unit], [FabricColor])
										 VALUES
											   (@Code
											   ,@Description
											   ,NULL
											   ,@GSM
											   ,@SupplierID
											   ,14
											   ,NULL
											   ,NULL
											   ,ISNULL(@FabConst, '')
											   ,NULL
											   ,CONVERT(decimal(8,2),@Price)
											   ,NULL
											   ,@Width
											   ,@Unit
											   ,@ColorID)
		
							
			FETCH NEXT FROM FabricCostCursor INTO  @Code, @Description, @Width, @FabConst, @GSM, @Color, @SupplierCode, @Price, @Unit, @Supplier  
		END
CLOSE FabricCostCursor 
DEALLOCATE FabricCostCursor

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


--**--**--**--**--**--**--**--**--** Delete The Accessory Table --**--**--**--**--**--**--**--**--**
DELETE [dbo].[PatternSupportAccessory]
	FROM [dbo].[PatternSupportAccessory]
GO

DELETE [dbo].[PatternSupportFabric]
	FROM [dbo].[PatternSupportFabric] psf
		JOIN [dbo].[CostSheet] cs
			ON cs.[ID] = psf.[CostSheet]

GO

DELETE FROM [dbo].[CostSheet]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


--**--**--**--**--**--**--**--**--** Insert The CostSheet Table --**--**--**--**--**--**--**--**--**
DECLARE @ID AS int
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
DECLARE @FabricID AS int
DECLARE @CostSheetID AS int
DECLARE @AccPatternID AS int
DECLARE @CostSheetPattern AS int 
DECLARE @FabCons AS float
DECLARE @FabCode AS int
DECLARE @AccPattern AS int 
DECLARE @AccCons AS float
DECLARE @AccCode AS int
DECLARE @AccessoryID AS int
DECLARE @PatternID AS int
DECLARE @PatternFabricID AS int 
DECLARE @PatternAccID AS int 

DECLARE CostSheetCursor CURSOR FAST_FORWARD FOR
 
SELECT [PatternID]
	  ,[Pattern]
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
  WHERE [MainFabric] IS NOT NULL AND [Pattern] IS NOT NULL
  
OPEN CostSheetCursor 
	FETCH NEXT FROM CostSheetCursor INTO @ID, @Pattern, @PatternNumber, @MainFabric, @HPCost, @LabelCost, @FOBExp, @CM, @Finance, @Wastage, @JKFOB, @Exch, @CF1, @CONS1, @RT1, @CST1, @CF2, @CONS2, 
										 @RT2, @CST2, @CF3, @CONS3, @RT3, @CST3, @INKCONS, @INKRT, @INKCST, @SUBcons, @PCONS, @PAPRT, @PAPCST, @DUTYRATE, @MARGINRATE, @JKAUD, @FRTAUD, 
										 @CFAUD, @DUTY, @MGTOH, @INDOH, @DEPR, @LANDED, @INDIMANCIF, @QUOTEDCIF, @FOBFACTOR, @INDIMANFOB, @CALMGN, @ACTMGN, @MP, @QUOTEDMP, @JK_SMV, 
										 @JK_SMV_RATE, @CCM
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
			
			SET @PatternID = (SELECT p.[ID] FROM [Indico].[dbo].[Pattern] p WHERE p.[Number] = (SELECT pp.[PatternNumber] FROM [Indman_Sub_CostSheetsSQL].[dbo].[Pattern] pp WHERE pp.[ID] = @Pattern))
			
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
											  [PatternID] = @ID
											    
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
								
							DECLARE AccessoryCostCursor CURSOR FAST_FORWARD FOR
	
								SELECT [PatternID]
									  ,[AccCons]      
									  ,[AccCode]          
								FROM [Indman_Sub_CostSheetsSQL].[dbo].[AccCost]
								WHERE [PatternID] IS NOT NULL AND 
									  [AccCode] IS NOT NULL AND
									  [PatternID] = @ID
									  
									    
								OPEN AccessoryCostCursor 
									FETCH NEXT FROM AccessoryCostCursor INTO @AccPattern, @AccCons, @AccCode
									WHILE @@FETCH_STATUS = 0 
									BEGIN 
									
									SET @PatternAccID = (SELECT p.[ID] FROM [Indico].[dbo].[Pattern] p WHERE p.[Number] = (SELECT pp.[PatternNumber] FROM [Indman_Sub_CostSheetsSQL].[dbo].[Pattern] pp WHERE pp.[ID] = @Pattern))
									SET @AccessoryID = (SELECT TOP 1 a.[ID] FROM [Indico].[dbo].[Accessory] a WHERE a.[Name] = (SELECT aa.[ItemCode]  FROM [Indman_Sub_CostSheetsSQL].[dbo].[Accessory] aa WHERE aa.[AccID] = @AccCode))
									
									IF (@PatternAccID IS NOT NULL AND @AccessoryID IS NOT NULL )
										BEGIN
										 
											INSERT INTO [Indico].[dbo].[PatternSupportAccessory] ([Accessory], [AccConstant], [Pattern]) VALUES (@AccessoryID, @AccCons, @PatternID)
										END
											
									FETCH NEXT FROM AccessoryCostCursor INTO  @AccPattern, @AccCons, @AccCode
								END
								CLOSE AccessoryCostCursor 
								DEALLOCATE AccessoryCostCursor
								 				               
						           
					END
           			
	FETCH NEXT FROM CostSheetCursor INTO   @ID,@Pattern, @PatternNumber, @MainFabric, @HPCost, @LabelCost, @FOBExp, @CM, @Finance, @Wastage, @JKFOB, @Exch, @CF1, @CONS1, @RT1, @CST1, @CF2, @CONS2, 
										   @RT2, @CST2, @CF3, @CONS3, @RT3, @CST3, @INKCONS, @INKRT, @INKCST, @SUBcons, @PCONS, @PAPRT, @PAPCST, @DUTYRATE, @MARGINRATE, @JKAUD, @FRTAUD, 
										   @CFAUD, @DUTY, @MGTOH, @INDOH, @DEPR, @LANDED, @INDIMANCIF, @QUOTEDCIF, @FOBFACTOR, @INDIMANFOB, @CALMGN, @ACTMGN, @MP, @QUOTEDMP, @JK_SMV, 
										   @JK_SMV_RATE, @CCM
	END
CLOSE CostSheetCursor 
DEALLOCATE CostSheetCursor
-----/--------
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

DELETE FROM [dbo].[PatternSupportAccessory] WHERE  [ID] = 782

DELETE FROM [dbo].[PatternSupportAccessory] WHERE  [ID] = 783

DELETE FROM [dbo].[PatternSupportAccessory] WHERE  [ID] = 784


DECLARE @ID AS int
DECLARE @Pattern AS int
DECLARE @TotalFabricCost AS decimal(8,2)
DECLARE @TotalAccessoriesCost AS decimal(8,2)
DECLARE @HPCost AS decimal(8,2)
DECLARE @LabelCost AS decimal(8,2)
DECLARE @Other AS decimal(8,2) 
DECLARE @Finance AS decimal(8,2)
DECLARE @Wastage AS decimal(8,2)
DECLARE @CM AS decimal(8,2)
DECLARE @Accessory AS int 
DECLARE @Const AS decimal(8,2)
DECLARE @AccPattern AS int
DECLARE @Fabric AS int
DECLARE @FabConstant AS decimal(8,2)
DECLARE @CostSheet AS int
DECLARE @AccessoryCost AS decimal(8,2)
DECLARE @AccessoryTotal AS decimal(8,2)
DECLARE @ACCCOST AS decimal(8,2)
DECLARE @FabricPrice AS decimal(8,2)
DECLARE @FabricCost AS decimal(8,2)
DECLARE @FabricTotal AS decimal(8,2)
DECLARE @SubWastage AS decimal(8,2)
DECLARE @SubFinance AS decimal(8,2)
DECLARE @FOBCost AS decimal(8,2)
SET @AccessoryCost = 0
SET @AccessoryTotal = 0
SET @FabricCost = 0
SET @FabricTotal = 0 
SET @SubWastage = 0
SET @SubFinance = 0
SET @FOBCost = 0

DECLARE CostSheetCursor CURSOR FAST_FORWARD FOR
 
SELECT [ID]
      ,[Pattern]
      ,[TotalFabricCost]
      ,[TotalAccessoriesCost]
      ,[HPCost]
      ,[LabelCost]
      ,[Other]
      ,[Finance]
      ,[Wastage]
      ,[CM]
  FROM [Indico].[dbo].[CostSheet]
  
OPEN CostSheetCursor 
	FETCH NEXT FROM CostSheetCursor INTO @ID, @Pattern, @TotalFabricCost, @TotalAccessoriesCost, @HPCost, @LabelCost, @Other, @Finance, @Wastage, @CM
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
				DECLARE AccessoryCursor CURSOR FAST_FORWARD FOR
				 
				SELECT [Accessory]
					  ,[AccConstant]
					  ,[Pattern]
				FROM [Indico].[dbo].[PatternSupportAccessory]
				WHERE [Pattern] = @Pattern
				  
				OPEN AccessoryCursor 
					FETCH NEXT FROM AccessoryCursor INTO @Accessory, @Const, @AccPattern
					WHILE @@FETCH_STATUS = 0 
					BEGIN 
						
						SET @ACCCOST =  (SELECT SUM(a.[Cost]) FROM [dbo].[Accessory] a WHERE a.[ID] = @Accessory)
						
						SET @AccessoryCost = (@Const * @ACCCOST)			
						
						SET @AccessoryTotal = ROUND((@AccessoryTotal+@AccessoryCost), 2)
							
							--PRINT @ACCCOST
							--PRINT @Const
							--PRINT @AccessoryTotal
							--PRINT @AccPattern
							--PRINT '---------------------------'			
							
						FETCH NEXT FROM AccessoryCursor INTO  @Accessory, @Const, @AccPattern
					END
				CLOSE AccessoryCursor 
				DEALLOCATE AccessoryCursor
				
				
				DECLARE FabricCursor CURSOR FAST_FORWARD FOR
				 
				SELECT [Fabric]
					  ,[FabConstant]
					  ,[CostSheet]
				  FROM [Indico].[dbo].[PatternSupportFabric]
				WHERE [CostSheet] = @ID
				  
				OPEN FabricCursor 
					FETCH NEXT FROM FabricCursor INTO @Fabric, @FabConstant, @CostSheet
					WHILE @@FETCH_STATUS = 0 
					BEGIN 
						
						SET @FabricPrice =  (SELECT a.[FabricPrice] FROM [dbo].[FabricCode] a WHERE a.[ID] = @Fabric)
						
						SET @FabricCost = (@FabConstant * @FabricPrice)			
						
						SET @FabricTotal = ROUND((@FabricTotal + @FabricCost), 2)					
						
							
						FETCH NEXT FROM FabricCursor INTO  @Fabric, @FabConstant, @CostSheet
					END
				CLOSE FabricCursor 
				DEALLOCATE FabricCursor
				
				
				
				SET @SubWastage  =  ROUND((((@AccessoryTotal + @HPCost + @LabelCost + @Other) * @Wastage)/100) , 2, 1)
				SET @SubFinance  =  ROUND(((( @FabricTotal + @AccessoryTotal + @HPCost + @LabelCost + @Other) * @Finance)/100) , 2, 1)
				SET @FOBCost =  ROUND((@FabricTotal + @AccessoryTotal + @HPCost + @LabelCost + @Other + @SubFinance + @SubWastage + @CM) , 2, 1)
				
				UPDATE [dbo].[CostSheet] SET [TotalAccessoriesCost] = @AccessoryTotal, 
											 [TotalFabricCost] = @FabricTotal,
											 [SubWastage] = @SubWastage,
											 [SubFinance] = @SubFinance
										WHERE [ID] = @ID
				
				
	SET @AccessoryCost = 0			
	SET @AccessoryTotal = 0
	SET @FabricCost = 0			
	SET @FabricTotal = 0
	SET @SubWastage = 0			
	SET @SubFinance = 0
	SET @FOBCost = 0
			
		FETCH NEXT FROM CostSheetCursor INTO  @ID, @Pattern, @TotalFabricCost, @TotalAccessoriesCost, @HPCost, @LabelCost, @Other, @Finance, @Wastage, @CM
	END
CLOSE CostSheetCursor 
DEALLOCATE CostSheetCursor
-----/--------
GO