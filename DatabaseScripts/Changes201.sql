
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  Table [dbo].[PriceListDownloads]    Script Date: 08/31/2012 19:09:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PatternDevelopment]') AND type in (N'U'))
	DROP TABLE [dbo].[PatternDevelopment]
GO

CREATE TABLE [dbo].[PatternDevelopment]  
   ([ID] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,  
    [Spec] [bit] NOT NULL ,  
    [LectraPattern] [bit] NOT NULL,
	[WhiteSample] [bit] NOT NULL,
	[LogoPositioning] [bit] NOT NULL,
	[Photo] [bit] NOT NULL,
	[Fake3DVis] [bit] NOT NULL,
	[NestedWireframe] [bit] NOT NULL,
	[BySizeWireframe] [bit] NOT NULL,
	[PreProd] [bit] NOT NULL,
	[SpecChart] [bit] NOT NULL,
	[FinalTemplate] [bit] NOT NULL,
	[TemplateApproved] [bit] NOT NULL,
	[Remarks] nvarchar(512) NULL,
	[LastModified] datetime2(7) NOT NULL,
	[Created] datetime2(7) NOT NULL,
	[LastModifier] [int] NULL,
	[Creator] [int] NOT NULL,
	[Pattern] [int] NOT NULL);

ALTER TABLE [dbo].[PatternDevelopment] WITH CHECK
	ADD CONSTRAINT [FK_PatternDevelopment_Pattern]
		FOREIGN KEY(Pattern) REFERENCES [dbo].Pattern(ID);
GO
ALTER TABLE [dbo].[PatternDevelopment] CHECK CONSTRAINT [FK_PatternDevelopment_Pattern]
GO

ALTER TABLE [dbo].[PatternDevelopment] WITH CHECK
	ADD CONSTRAINT [FK_PatternDevelopment_LastModifier]
		FOREIGN KEY (LastModifier) REFERENCES [dbo].[User](ID);
GO
ALTER TABLE [dbo].[PatternDevelopment] CHECK CONSTRAINT [FK_PatternDevelopment_LastModifier]
GO

ALTER TABLE [dbo].[PatternDevelopment] WITH CHECK
	ADD CONSTRAINT [FK_PatternDevelopment_Creator]
		FOREIGN KEY (Creator) REFERENCES [dbo].[User](ID);
GO
ALTER TABLE [dbo].[PatternDevelopment] CHECK CONSTRAINT [FK_PatternDevelopment_Creator]
GO

ALTER TABLE [dbo].[PatternDevelopment] 
 ADD CONSTRAINT [DF_Spec] DEFAULT (0 ) FOR [Spec]
GO

ALTER TABLE [dbo].[PatternDevelopment] 
 ADD CONSTRAINT [DF_LectraPattern] DEFAULT (0 ) FOR [LectraPattern]
GO

ALTER TABLE [dbo].[PatternDevelopment] 
 ADD CONSTRAINT [DF_WhiteSample] DEFAULT (0 ) FOR [WhiteSample]
GO

ALTER TABLE [dbo].[PatternDevelopment] 
 ADD CONSTRAINT [DF_LogoPositioning] DEFAULT (0 ) FOR [LogoPositioning]
GO

ALTER TABLE [dbo].[PatternDevelopment] 
 ADD CONSTRAINT [DF_Photo] DEFAULT (0 ) FOR [Photo]
GO

ALTER TABLE [dbo].[PatternDevelopment] 
 ADD CONSTRAINT [DF_Fake3DVis] DEFAULT (0 ) FOR [Fake3DVis]
GO

ALTER TABLE [dbo].[PatternDevelopment] 
 ADD CONSTRAINT [DF_NestedWireframe] DEFAULT (0 ) FOR [NestedWireframe]
GO

ALTER TABLE [dbo].[PatternDevelopment] 
 ADD CONSTRAINT [DF_BySizeWireframe] DEFAULT (0 ) FOR [BySizeWireframe]
GO

ALTER TABLE [dbo].[PatternDevelopment] 
 ADD CONSTRAINT [DF_PreProd] DEFAULT (0 ) FOR [PreProd]
GO

ALTER TABLE [dbo].[PatternDevelopment] 
 ADD CONSTRAINT [DF_SpecChart] DEFAULT (0 ) FOR [SpecChart]
GO

ALTER TABLE [dbo].[PatternDevelopment] 
 ADD CONSTRAINT [DF_FinalTemplate] DEFAULT (0 ) FOR [FinalTemplate]
GO

ALTER TABLE [dbo].[PatternDevelopment] 
 ADD CONSTRAINT [DF_TemplateApproved] DEFAULT (0 ) FOR [TemplateApproved]
GO

ALTER TABLE [dbo].[PatternDevelopment] 
 ADD CONSTRAINT [DF_LastModified] DEFAULT (GETDATE() ) FOR [LastModified]
GO

ALTER TABLE [dbo].[PatternDevelopment] 
 ADD CONSTRAINT [DF_Created] DEFAULT (GETDATE() ) FOR [Created]
GO

/****** Object:  Table [dbo].[PatternDevelopmentHistory]    Script Date: 08/31/2012 19:09:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PatternDevelopmentHistory]') AND type in (N'U'))
	DROP TABLE [dbo].[PatternDevelopmentHistory]
GO

CREATE TABLE [dbo].[PatternDevelopmentHistory]
	([ID] int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	 [PatternDevelopment] int NOT NULL,
	 [Modifier] int NOT NULL,
	 [ModifiedDate] datetime2(7),
	 [ChangeDescription] nvarchar(250));

ALTER TABLE [dbo].[PatternDevelopmentHistory]
	ADD CONSTRAINT [FK_PatternDevelopmentHistory_Modifier]
		FOREIGN KEY(Modifier) REFERENCES [dbo].[User](ID);
GO
ALTER TABLE [dbo].[PatternDevelopmentHistory] CHECK CONSTRAINT FK_PatternDevelopmentHistory_Modifier
GO

ALTER TABLE [dbo].[PatternDevelopmentHistory]
	ADD CONSTRAINT [FK_PatternDevelopmentHistory_PatternDevelopment]
		FOREIGN KEY(PatternDevelopment) REFERENCES [dbo].[PatternDevelopment](ID);
GO
ALTER TABLE [dbo].[PatternDevelopmentHistory] CHECK CONSTRAINT [FK_PatternDevelopmentHistory_PatternDevelopment]
GO


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_GetIndimanPriceListData]    Script Date: 02/03/2014 14:26:55 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetPatternDevelopments]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[SPC_GetIndimanPriceListData]
GO

CREATE PROC [dbo].[SPC_GetPatternDevelopments] 
	@P_PatternNumber nvarchar(64) = ''
AS 
BEGIN
	IF(@P_PatternNumber <> '')
	BEGIN
		SELECT
			pd.ID,
			pd.[Spec],
			pd.[LectraPattern],
			pd.[WhiteSample],
			pd.LogoPositioning,
			pd.Photo,
			pd.Fake3DVis,
			pd.NestedWireframe,
			pd.BySizeWireframe,
			pd.PreProd,
			pd.SpecChart,
			pd.FinalTemplate,
			pd.TemplateApproved,
			pd.Remarks,
			p.[NickName] AS [Description],
			p.Number AS PatternNumber,
			ISNULL(lm.GivenName + ' '+lm.FamilyName,'') AS LastModifier,
			pd.LastModified
		FROM [dbo].PatternDevelopment pd
			INNER JOIN [dbo].[Pattern] p
				ON p.ID = pd.Pattern
			LEFT OUTER JOIN [dbo].[User] lm
				ON pd.LastModifier = lm.ID
		WHERE p.Number LIKE '%'+@P_PatternNumber+'%'
	END
	ELSE
	BEGIN
		SELECT
			pd.ID, 
			pd.[Spec],
			pd.[LectraPattern],
			pd.[WhiteSample],
			pd.LogoPositioning,
			pd.Photo,
			pd.Fake3DVis,
			pd.NestedWireframe,
			pd.BySizeWireframe,
			pd.PreProd,
			pd.SpecChart,
			pd.FinalTemplate,
			pd.TemplateApproved,
			pd.Remarks,
			p.[NickName] AS [Description],
			p.Number AS PatternNumber,
			ISNULL(lm.GivenName + ' '+lm.FamilyName,'') AS LastModifier,
			pd.LastModified
		FROM [dbo].PatternDevelopment pd
			INNER JOIN [dbo].[Pattern] p
				ON p.ID = pd.Pattern
			LEFT OUTER JOIN [dbo].[User] lm
				ON pd.LastModifier = lm.ID
		ORDER BY  pd.LastModified DESC
	END
END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

DECLARE @PageId int
DECLARE @MenuItemMenuId int
DECLARE @MenuItemId int

INSERT INTO [dbo].[Page]([Name],[Title],[Heading])
     VALUES ('/ViewPatternDevelopment.aspx','Pattern Development','Pattern Development')	 
SET @PageId = SCOPE_IDENTITY()

SELECT TOP 1 @MenuItemMenuId = ID FROM [dbo].[MenuItem] WHERE Name = 'Patterns' AND Parent IS NULL
			
INSERT INTO [dbo].[MenuItem]
			([Page],[Name],[Description],[IsActive],[Parent],[Position],[IsVisible])
	 VALUES (@PageId, 'Pattern Development', 'Pattern Development', 1, @MenuItemMenuId, 15, 1)
SET @MenuItemId = SCOPE_IDENTITY()

INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, 1)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, 2)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, 3)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, 4)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, 5)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, 6)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, 7)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, 8)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, 9)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, 10)
INSERT INTO [dbo].[MenuItemRole] ([MenuItem],[Role])
	 VALUES (@MenuItemId, 11)
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_GetIndimanPriceListData]    Script Date: 02/03/2014 14:26:55 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_ViewPatternDetails]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[SPC_ViewPatternDetails]
GO

CREATE PROCEDURE [dbo].[SPC_ViewPatternDetails]
(
	@P_SearchText AS NVARCHAR(255) = '',	
	@P_Blackchrome AS int =  2,
	@P_GarmentStatus AS NVARCHAR(255) = '',
	@P_PatternStatus AS int = 2
)
AS
BEGIN
	SET NOCOUNT ON	
		SELECT  
				p.[ID] AS Pattern,
				i.[Name] AS Item,
				ISNULL(si.[Name], '') AS SubItem,
				g.[Name] AS Gender,
				ISNULL(ag.[Name], '') AS AgeGroup,
				ss.[Name] AS SizeSet,
				c.[Name] AS CoreCategory,
				pt.[Name] AS PrinterType,
				p.[Number] AS Number,
				ISNULL(p.[OriginRef], '') AS OriginRef,
				p.[NickName] AS NickName,
				ISNULL(p.[Keywords], '') AS Keywords,
				ISNULL(p.[CorePattern], '') AS CorePattern,
				ISNULL(p.[FactoryDescription], '') AS FactoryDescription,
				ISNULL(p.[Consumption], '') AS Consumption,
				p.[ConvertionFactor] AS ConvertionFactor,
				ISNULL(p.[SpecialAttributes], '') AS SpecialAttributes,
				ISNULL(p.[PatternNotes], '') AS PatternNotes,
				ISNULL(p.[PriceRemarks], '') AS PriceRemarks,
				p.[IsActive] AS IsActive,
				p.[Creator] AS Creator,
				p.[CreatedDate] AS CreatedDate,
				p.[Modifier] AS Modifier,
				p.[ModifiedDate] AS ModifiedDate,
				ISNULL(p.[Remarks], '') AS Remarks,
				p.[IsTemplate] AS IsTemplate,
				ISNULL(p.[Parent], 0) AS Parent,
				p.[GarmentSpecStatus] AS GarmentSpecStatus,
				p.[IsActiveWS] AS IsActiveWS,
				p.[IsCoreRange] AS IsCoreRange,
				ISNULL(p.[HTSCode], '') AS HTSCode,
				ISNULL(p.[SMV], 0.00) AS SMV,
				ISNULL(p.[Description], '') AS MarketingDescription,
				CASE WHEN	(EXISTS(SELECT TOP 1 ID FROM [dbo].[CostSheet] WHERE Pattern = p.[ID])) OR
							(EXISTS(SELECT TOP 1 ID FROM [dbo].[VisualLayout] WHERE Pattern = p.[ID])) OR
							(EXISTS(SELECT TOP 1 ID FROM [dbo].[SizeChart]  WHERE Pattern = p.[ID])) 
				THEN 0	
				ELSE 1 
				END
				AS CanDelete,
				pd.ID AS PatternDevelopmentID
			    --CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (pat.[Parent]) FROM [dbo].[Pattern] pat WHERE pat.[Parent] = p.[ID])) THEN 1 ELSE 0 END)) AS PatternParent,
			    --CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (r.[Pattern]) FROM [dbo].[Reservation] r WHERE r.[Pattern] = p.[ID])) THEN 1 ELSE 0 END)) AS Reservation,
			    --CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (pr.[Pattern]) FROM [dbo].[Price] pr WHERE pr.[Pattern] = p.[ID])) THEN 1 ELSE 0 END)) AS Price,
			    --CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (pti.[Pattern]) FROM [dbo].[PatternTemplateImage] pti WHERE pti.[Pattern] = p.[ID])) THEN 1 ELSE 0 END)) AS PatternTemplateImage,
			    --CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (prod.[Pattern]) FROM [dbo].[Product] prod WHERE prod.[Pattern] = p.[ID])) THEN 1 ELSE 0 END)) AS Product,
			    --CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (od.[Pattern]) FROM [dbo].[OrderDetail] od WHERE od.[Pattern] = p.[ID])) THEN 1 ELSE 0 END)) AS OrderDetail,
			    --CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (v.[Pattern]) FROM [dbo].[VisualLayout] v WHERE v.[Pattern] = p.[ID])) THEN 1 ELSE 0 END)) AS VisualLayout
		 FROM [dbo].[Pattern] p
			INNER JOIN [dbo].[Item] i
				ON p.[Item]= i.[ID]
			LEFT OUTER JOIN [dbo].[Item] si
				ON p.[SubItem] = si.[ID]
			LEFT OUTER JOIN [dbo].[Gender] g
				ON p.[Gender] = g.[ID]
			LEFT OUTER JOIN [dbo].[AgeGroup] ag
				ON p.[AgeGroup] = ag.[ID]
			INNER JOIN [dbo].[SizeSet] ss
				ON p.[SizeSet] = ss.[ID]
			INNER JOIN [dbo].[Category] c
				ON p.[CoreCategory] = c.[ID]
			INNER JOIN [dbo].[PrinterType] pt
				ON p.[PrinterType] = pt.[ID]
			LEFT OUTER JOIN [dbo].[PatternDevelopment] pd
				ON pd.Pattern = p.ID
		WHERE (@P_SearchText = '' OR
				i.[Name] LIKE '%' + @P_SearchText + '%' OR
				si.[Name] LIKE '%' + @P_SearchText + '%' OR
				g.[Name] LIKE '%' + @P_SearchText + '%' OR
				ag.[Name] LIKE '%' + @P_SearchText + '%' OR
				ss.[Name] LIKE '%' + @P_SearchText + '%' OR
				c.[Name] LIKE '%' + @P_SearchText + '%' OR
				pt.[Name] LIKE '%' + @P_SearchText + '%' OR
				p.[Number] LIKE '%' + @P_SearchText + '%' OR
				p.[NickName] LIKE '%' + @P_SearchText + '%' OR 
				p.[GarmentSpecStatus] LIKE '%' + @P_SearchText + '%' OR
				p.[CorePattern] LIKE '%' + (@P_SearchText) + '%' )
				AND( @P_Blackchrome = 2  OR p.[IsActiveWS] = CONVERT(bit,@P_Blackchrome)) 
				AND (@P_GarmentStatus = '' OR p.[GarmentSpecStatus] LIKE '%' + @P_GarmentStatus + '%') 
				AND (@P_PatternStatus = 2 OR p.[IsActive] = CONVERT(bit, @P_PatternStatus))					
END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_GetIndimanPriceListData]    Script Date: 02/03/2014 14:26:55 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SPC_GetPatterDevelopmentHistory]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[SPC_GetPatterDevelopmentHistory]
GO

CREATE PROC [dbo].[SPC_GetPatterDevelopmentHistory]
	@P_PatternDevelopment int 
AS
BEGIN
	SELECT
		u.GivenName + u.FamilyName AS UserName,
		pdh.ModifiedDate,
		pdh.ChangeDescription
	FROM [dbo].PatternDevelopmentHistory pdh
		INNER JOIN [dbo].[User] u
			ON pdh.Modifier = u.ID
		INNER JOIN [dbo].[PatternDevelopment] pd
			ON pdh.PatternDevelopment = pd.ID
	WHERE pd.ID = @P_PatternDevelopment
END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  View [dbo].[ReturnIndimanPriceListDataView]    Script Date: 02/03/2014 14:34:32 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[GetNonDevelopedPatternsView]'))
	DROP VIEW [dbo].[GetNonDevelopedPatternsView]
GO

CREATE VIEW [dbo].[GetNonDevelopedPatternsView]
AS
	SELECT p.Number AS PatternNumber	
	FROM [dbo].[Pattern] p
		LEFT JOIN [dbo].[PatternDevelopment] pd
			ON p.ID = pd.Pattern
	WHERE pd.ID IS NULL

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--