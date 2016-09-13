USE [Indico]
GO


DECLARE @ID AS int
DECLARE @Pattern AS int
DECLARE @FabricCode AS int 
DECLARE PriceCursor CURSOR FAST_FORWARD FOR
 
SELECT [ID]
      ,[Pattern]
      ,[FabricCode]      
  FROM [Indico].[dbo].[Price]
  
OPEN PriceCursor 
	FETCH NEXT FROM PriceCursor INTO @ID, @Pattern, @FabricCode
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		 
			IF( NOT EXISTS(SELECT [ID] FROM [dbo].[CostSheet] WHERE [Pattern] = @Pattern AND [Fabric] = @FabricCode))
				BEGIN
				
					INSERT INTO [Indico].[dbo].[CostSheet]
						   ([Pattern], [Fabric], [TotalFabricCost], [TotalAccessoriesCost], [HPCost], [LabelCost], [Other], [Finance], [Wastage], [FOBExp], [CM], [JKFOBCost], [QuotedFOBCost]
						   ,[Roundup], [SMV], [SMVRate], [CalculateCM], [Creator], [CreatedDate], [Modifier], [ModifiedDate], [SubWastage], [SubFinance], [SubCons], [DutyRate], [CF1], [CF2]
						   ,[CF3], [CONS1], [CONS2], [CONS3], [InkCons], [PaperCons], [Rate1], [Rate2], [Rate3], [InkRate], [PaperRate], [MarginRate], [FOBAUD], [Duty], [Cost1], [Cost2], [Cost3]
						   ,[InkCost], [PaperCost], [MGTOH], [IndicoOH], [Depr], [Landed], [IndimanCIF], [QuotedCIF], [FobFactor], [IndimanFOB], [CalMGN], [ActMgn], [MP], [QuotedMP],[ExchangeRate]
						   ,[AirFregiht], [ImpCharges])
					 VALUES
						   (@Pattern
						   ,@FabricCode
						   ,0.00
						   ,0.00
						   ,1.15
						   ,0.10
						   ,0.30
						   ,4.0
						   ,3.0
						   ,0.00
						   ,0.00
						   ,0.00
						   ,0.00
						   ,0.00
						   ,0.00
						   ,0.15
						   ,0.00
						   ,1
						   ,GETDATE()
						   ,1
						   ,GETDATE()
						   ,0.00
						   ,0.00
						   ,0.00
						   ,10.0
						   ,''
						   ,''
						   ,''
						   ,0.00
						   ,0.00
						   ,0.00
						   ,0.017
						   ,0.00
						   ,0.00
						   ,0.00
						   ,0.00
						   ,80.00
						   ,080
						   ,12.5
						   ,0.00
						   ,1.2
						   ,0.00
						   ,0.00
						   ,0.00
						   ,1.387
						   ,0.00
						   ,1.83
						   ,0.56
						   ,0.20
						   ,0.00
						   ,0.00
						   ,0.00
						   ,0.00
						   ,0.00
						   ,0.00
						   ,0.00
						   ,0.00
						   ,0.00
						   ,0.85
						   ,1.15
						   ,0.35)
						   
						   
				INSERT INTO [Indico].[dbo].[PatternSupportFabric] ([Fabric], [FabConstant], [CostSheet]) VALUES (@FabricCode, 0.00, SCOPE_IDENTITY())				
				END
		
		FETCH NEXT FROM PriceCursor INTO @ID, @Pattern, @FabricCode
	END
CLOSE PriceCursor 
DEALLOCATE PriceCursor
GO
