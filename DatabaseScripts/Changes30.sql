USE[Indico] 
GO

/****** Object:  Table [dbo].[PriceMarkupLabel]    Script Date: 02/07/2013 09:16:13 ******/

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_LabelPriceMarkup_Label]') AND parent_object_id = OBJECT_ID(N'[dbo].[LabelPriceMarkup]'))
ALTER TABLE [dbo].[LabelPriceMarkup] DROP CONSTRAINT [FK_LabelPriceMarkup_Label]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_LabelPriceLevelCost_Label]') AND parent_object_id = OBJECT_ID(N'[dbo].[LabelPriceLevelCost]'))
ALTER TABLE [dbo].[LabelPriceLevelCost] DROP CONSTRAINT [FK_LabelPriceLevelCost_Label]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PriceMarkupLabel]') AND type in (N'U'))
DROP TABLE [dbo].[PriceMarkupLabel]
GO
/****** Object:  Table [dbo].[PriceMarkupLabel]    Script Date: 02/07/2013 09:16:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PriceMarkupLabel](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_PriceMarkupLabel] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_LabelPriceMarkup_PriceLevel]') AND parent_object_id = OBJECT_ID(N'[dbo].[LabelPriceMarkup]'))
ALTER TABLE [dbo].[LabelPriceMarkup] DROP CONSTRAINT [FK_LabelPriceMarkup_PriceLevel]
GO

/****** Object:  Table [dbo].[LabelPriceMarkup]    Script Date: 02/07/2013 09:16:52 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LabelPriceMarkup]') AND type in (N'U'))
DROP TABLE [dbo].[LabelPriceMarkup]
GO

/****** Object:  Table [dbo].[LabelPriceMarkup]    Script Date: 02/07/2013 09:16:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[LabelPriceMarkup](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Label] [int] NULL,
	[PriceLevel] [int] NOT NULL,
	[Markup] [decimal](4, 2) NOT NULL,
 CONSTRAINT [PK_LabelPriceMarkup] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[LabelPriceMarkup]  WITH CHECK ADD  CONSTRAINT [FK_LabelPriceMarkup_Label] FOREIGN KEY([Label])
REFERENCES [dbo].[PriceMarkupLabel] ([ID])
GO

ALTER TABLE [dbo].[LabelPriceMarkup] CHECK CONSTRAINT [FK_LabelPriceMarkup_Label]
GO

ALTER TABLE [dbo].[LabelPriceMarkup]  WITH CHECK ADD  CONSTRAINT [FK_LabelPriceMarkup_PriceLevel] FOREIGN KEY([PriceLevel])
REFERENCES [dbo].[PriceLevel] ([ID])
GO

ALTER TABLE [dbo].[LabelPriceMarkup] CHECK CONSTRAINT [FK_LabelPriceMarkup_PriceLevel]
GO


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_LabelPriceLevelCost_Modifier]') AND parent_object_id = OBJECT_ID(N'[dbo].[LabelPriceLevelCost]'))
ALTER TABLE [dbo].[LabelPriceLevelCost] DROP CONSTRAINT [FK_LabelPriceLevelCost_Modifier]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_LabelPriceLevelCost_PriceLevelCost]') AND parent_object_id = OBJECT_ID(N'[dbo].[LabelPriceLevelCost]'))
ALTER TABLE [dbo].[LabelPriceLevelCost] DROP CONSTRAINT [FK_LabelPriceLevelCost_PriceLevelCost]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_LabelPriceLevelCost_PriceTerm]') AND parent_object_id = OBJECT_ID(N'[dbo].[LabelPriceLevelCost]'))
ALTER TABLE [dbo].[LabelPriceLevelCost] DROP CONSTRAINT [FK_LabelPriceLevelCost_PriceTerm]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__LabelPric__Indic__66E0EF00]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LabelPriceLevelCost] DROP CONSTRAINT [DF__LabelPric__Indic__66E0EF00]
END

GO

/****** Object:  Table [dbo].[LabelPriceLevelCost]    Script Date: 02/07/2013 09:17:26 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LabelPriceLevelCost]') AND type in (N'U'))
DROP TABLE [dbo].[LabelPriceLevelCost]
GO

/****** Object:  Table [dbo].[LabelPriceLevelCost]    Script Date: 02/07/2013 09:17:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[LabelPriceLevelCost](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Label] [int] NULL,
	[PriceTerm] [int] NULL,
	[PriceLevelCost] [int] NOT NULL,
	[IndicoCost] [decimal](8, 2) NOT NULL,
	[ModifiedDate] [datetime2](7) NOT NULL,
	[Modifier] [int] NOT NULL,
 CONSTRAINT [PK_LabelPriceLevelCost] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[LabelPriceLevelCost]  WITH CHECK ADD  CONSTRAINT [FK_LabelPriceLevelCost_Label] FOREIGN KEY([Label])
REFERENCES [dbo].[PriceMarkupLabel] ([ID])
GO

ALTER TABLE [dbo].[LabelPriceLevelCost] CHECK CONSTRAINT [FK_LabelPriceLevelCost_Label]
GO

ALTER TABLE [dbo].[LabelPriceLevelCost]  WITH CHECK ADD  CONSTRAINT [FK_LabelPriceLevelCost_Modifier] FOREIGN KEY([Modifier])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[LabelPriceLevelCost] CHECK CONSTRAINT [FK_LabelPriceLevelCost_Modifier]
GO

ALTER TABLE [dbo].[LabelPriceLevelCost]  WITH CHECK ADD  CONSTRAINT [FK_LabelPriceLevelCost_PriceLevelCost] FOREIGN KEY([PriceLevelCost])
REFERENCES [dbo].[PriceLevelCost] ([ID])
GO

ALTER TABLE [dbo].[LabelPriceLevelCost] CHECK CONSTRAINT [FK_LabelPriceLevelCost_PriceLevelCost]
GO

ALTER TABLE [dbo].[LabelPriceLevelCost]  WITH CHECK ADD  CONSTRAINT [FK_LabelPriceLevelCost_PriceTerm] FOREIGN KEY([PriceTerm])
REFERENCES [dbo].[PriceTerm] ([ID])
GO

ALTER TABLE [dbo].[LabelPriceLevelCost] CHECK CONSTRAINT [FK_LabelPriceLevelCost_PriceTerm]
GO

ALTER TABLE [dbo].[LabelPriceLevelCost] ADD  DEFAULT ((0.00)) FOR [IndicoCost]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

/****** Object:  StoredProcedure [dbo].[SPC_CloneLabelPriceMarkup]    Script Date: 02/08/2013 12:47:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_CloneLabelPriceMarkup]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_CloneLabelPriceMarkup]
GO

/****** Object:  StoredProcedure [dbo].[SPC_CloneLabelPriceMarkup]    Script Date: 02/08/2013 12:47:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_CloneLabelPriceMarkup]
(
	@P_ExistDistributor int,
	@P_NewLabel nvarchar(255)
)
AS BEGIN

	DECLARE @RetVal int
	DECLARE @LabelID int
	
	BEGIN TRY
	
		INSERT INTO [dbo].[PriceMarkupLabel] ([Name]) 
		VALUES(@P_NewLabel)
		
		SET @LabelID = SCOPE_IDENTITY()

		INSERT INTO [dbo].[LabelPriceMarkup] ([Label], [PriceLevel], [Markup])
		SELECT @LabelID,
			   [PriceLevel],
			   [Markup] 				
		FROM [dbo].[DistributorPriceMarkup]
		WHERE (@P_ExistDistributor = 0 AND [Distributor] IS NULL)
		OR [Distributor] = @P_ExistDistributor 

		INSERT INTO [dbo].[LabelPriceLevelCost] ([Label] , [PriceTerm] , [PriceLevelCost], [IndicoCost], [ModifiedDate], [Modifier])
		SELECT @LabelID,
			   [PriceTerm],
			   [PriceLevelCost],
			   [IndicoCost],
			   (SELECT (GETDATE())),
			   [Modifier]			
		FROM [dbo].[DistributorPriceLevelCost] 
		WHERE (@P_ExistDistributor = 0 AND [Distributor] IS NULL) 
		OR [Distributor] = @P_ExistDistributor 
		
		SET @RetVal = 1
	END TRY
	BEGIN CATCH
		SET @RetVal = 0
	END CATCH
	
	SELECT @RetVal AS RetVal
END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

/****** Object:  StoredProcedure [dbo].[SPC_DeleteLabelPriceMarkup]    Script Date: 02/08/2013 12:58:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_DeleteLabelPriceMarkup]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SPC_DeleteLabelPriceMarkup]
GO

/****** Object:  StoredProcedure [dbo].[SPC_DeleteLabelPriceMarkup]    Script Date: 02/08/2013 12:58:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_DeleteLabelPriceMarkup]
(
	@P_Label int	
)
AS 
BEGIN

	DECLARE @RetVal int
	
	BEGIN TRY
	
		DELETE [dbo].[LabelPriceLevelCost] 
		FROM [dbo].[LabelPriceLevelCost] lplc  
		WHERE   lplc.[Label] = @P_Label  
		
		DELETE [dbo].[LabelPriceMarkup]  
		FROM [dbo].[LabelPriceMarkup] lpm 
		WHERE	lpm.[Label] = @P_Label  
		
		SET @RetVal = 1
	END TRY
	BEGIN CATCH
		SET @RetVal = 0
	END CATCH
	
	SELECT @RetVal AS RetVal
END

GO


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**

/****** Object:  View [dbo].[LabelPatternPriceLevelCostView]    Script Date: 02/11/2013 16:17:32 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[LabelPatternPriceLevelCostView]'))
DROP VIEW [dbo].[LabelPatternPriceLevelCostView]
GO

/****** Object:  View [dbo].[LabelPatternPriceLevelCostView]    Script Date: 02/11/2013 16:17:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[LabelPatternPriceLevelCostView]
AS

SELECT	    plc.ID,
			plc.Price,
			plc.PriceLevel,
			plc.FactoryCost,
			plc.IndimanCost,
			lpm.Label,
			lpm.Markup,
			(	SELECT	lplc.IndicoCost 
				FROM	LabelPriceLevelCost lplc WITH (NOLOCK)
				WHERE	lplc.Label = lpm.Label
						AND lplc.PriceTerm = 1
						AND lplc.PriceLevelCost = plc.ID) AS EditedCIFPrice,
			(	SELECT	lplc.IndicoCost 
				FROM	LabelPriceLevelCost lplc WITH (NOLOCK)
				WHERE	lplc.Label = lpm.Label
						AND lplc.PriceTerm = 2
						AND lplc.PriceLevelCost = plc.ID) AS EditedFOBPrice,
			(	SELECT	CONVERT(VARCHAR(12), lplc.ModifiedDate, 113)
				FROM	LabelPriceLevelCost lplc WITH (NOLOCK)
				WHERE	lplc.Label = lpm.Label
						AND lplc.PriceTerm = 1
						AND lplc.PriceLevelCost = plc.ID) AS ModifiedDate
	FROM PriceLevelCost plc WITH (NOLOCK)
		 JOIN LabelPriceMarkup lpm WITH (NOLOCK)
			ON plc.PriceLevel = lpm.PriceLevel	
			

GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_LabelPriceListDownloads_Creator]') AND parent_object_id = OBJECT_ID(N'[dbo].[LabelPriceListDownloads]'))
ALTER TABLE [dbo].[LabelPriceListDownloads] DROP CONSTRAINT [FK_LabelPriceListDownloads_Creator]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_LabelPriceListDownloads_Label]') AND parent_object_id = OBJECT_ID(N'[dbo].[LabelPriceListDownloads]'))
ALTER TABLE [dbo].[LabelPriceListDownloads] DROP CONSTRAINT [FK_LabelPriceListDownloads_Label]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_LabelPriceListDownloads_PriceTerm]') AND parent_object_id = OBJECT_ID(N'[dbo].[LabelPriceListDownloads]'))
ALTER TABLE [dbo].[LabelPriceListDownloads] DROP CONSTRAINT [FK_LabelPriceListDownloads_PriceTerm]
GO

/****** Object:  Table [dbo].[LabelPriceListDownloads]    Script Date: 02/11/2013 16:52:22 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LabelPriceListDownloads]') AND type in (N'U'))
DROP TABLE [dbo].[LabelPriceListDownloads]
GO

/****** Object:  Table [dbo].[LabelPriceListDownloads]    Script Date: 02/11/2013 16:52:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[LabelPriceListDownloads](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Label] [int] NULL,
	[PriceTerm] [int] NOT NULL,
	[EditedPrice] [bit] NOT NULL,
	[CreativeDesign] [decimal](18, 0) NULL,
	[StudioDesign] [decimal](18, 0) NULL,
	[ThirdPartyDesign] [decimal](18, 0) NULL,
	[Position1] [decimal](18, 0) NULL,
	[Position2] [decimal](18, 0) NULL,
	[Position3] [decimal](18, 0) NULL,
	[FileName] [nvarchar](256) NULL,
	[Creator] [int] NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_LabelPriceListDownloads] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[LabelPriceListDownloads]  WITH CHECK ADD  CONSTRAINT [FK_LabelPriceListDownloads_Creator] FOREIGN KEY([Creator])
REFERENCES [dbo].[User] ([ID])
GO

ALTER TABLE [dbo].[LabelPriceListDownloads] CHECK CONSTRAINT [FK_LabelPriceListDownloads_Creator]
GO

ALTER TABLE [dbo].[LabelPriceListDownloads]  WITH CHECK ADD  CONSTRAINT [FK_LabelPriceListDownloads_Label] FOREIGN KEY([Label])
REFERENCES [dbo].[PriceMarkupLabel] ([ID])
GO

ALTER TABLE [dbo].[LabelPriceListDownloads] CHECK CONSTRAINT [FK_LabelPriceListDownloads_Label]
GO

ALTER TABLE [dbo].[LabelPriceListDownloads]  WITH CHECK ADD  CONSTRAINT [FK_LabelPriceListDownloads_PriceTerm] FOREIGN KEY([PriceTerm])
REFERENCES [dbo].[PriceTerm] ([ID])
GO

ALTER TABLE [dbo].[LabelPriceListDownloads] CHECK CONSTRAINT [FK_LabelPriceListDownloads_PriceTerm]
GO


