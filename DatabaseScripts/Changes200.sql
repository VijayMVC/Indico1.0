USE [Indico]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

	BEGIN TRAN

	BEGIN TRY

	DECLARE @AddressesToDelete TABLE
		(
			TEMPID int,
			TBAID int
		)

	INSERT INTO @AddressesToDelete 
	SELECT dc1.ID, dc2.ID FROM
		[dbo].[DistributorClientAddress] dc1
			INNER JOIN [dbo].[DistributorClientAddress] dc2
				ON dc1.Distributor = dc2.Distributor
	WHERE 
	( dc1.Address = 'A'
		OR dc1.Address = 'a'
		OR dc1.Address = '1'
		OR dc1.Address = '0'
		OR dc1.Address = '-' ) 	
	 AND dc2.CompanyName = 'TBA'
	 	
	DECLARE db_cursor CURSOR LOCAL FAST_FORWARD
					FOR SELECT * FROM @AddressesToDelete; 

	DECLARE @TEMPID INT;
	DECLARE @TBAID INT;

	OPEN db_cursor;
	FETCH NEXT FROM db_cursor INTO @TEMPID, @TBAID;

	WHILE @@FETCH_STATUS = 0  
	BEGIN 

	UPDATE [dbo].[Order] 
	SET [BillingAddress] = @TBAID WHERE [BillingAddress] = @TEMPID

	UPDATE [dbo].[Order] 
	SET [DespatchToAddress] = @TBAID WHERE [DespatchToAddress] = @TEMPID

	UPDATE [dbo].[OrderDetail] 
	SET [DespatchTo] = @TBAID WHERE [DespatchTo] = @TEMPID

	DELETE FROM [dbo].[DistributorClientAddress] 
	WHERE ID = @TEMPID

	FETCH NEXT FROM db_cursor INTO @TEMPID, @TBAID;
	END;
	CLOSE db_cursor;
	DEALLOCATE db_cursor;

	UPDATE 	[dbo].[DistributorClientAddress]
	SET		[Address] = 'TBA'			
			,[Suburb] = 'TBA'
			,[PostCode] = 'TBA'
			,Country = 14
			,[ContactName] = 'TBA'
			,[ContactPhone] = 'TBA'
			,[CompanyName] = 'TBA'
			,[State] = 'TBA'
			,Port = 3
			,[EmailAddress] = 'TBA'
			,AddressType = 0
			,[IsAdelaideWarehouse] = 0
	WHERE ( Address = 'A'
   OR Address = 'a'
   OR Address = '1'
   OR Address = '0'
   OR Address = '-'
   ) AND Distributor != 587 
   AND Distributor != 1025 
   AND Distributor != 1496 

   --Correcting 162
   UPDATE 	[dbo].[DistributorClientAddress]
	SET		[Address] = 'TBA'			
			,[Suburb] = 'TBA'
			,[PostCode] = 'TBA'
			,Country = 14
			,[ContactName] = 'TBA'
			,[ContactPhone] = 'TBA'
			,[CompanyName] = 'TBA'
			,[State] = 'TBA'
			,Port = 3
			,[EmailAddress] = 'TBA'
			,AddressType = 0
			,[IsAdelaideWarehouse] = 0
	WHERE ID = 162

	UPDATE [dbo].[Order] 
	SET [BillingAddress] = 162 WHERE [BillingAddress] = 168
	UPDATE [dbo].[Order] 
	SET [DespatchToAddress] = 162 WHERE [DespatchToAddress] = 168
	UPDATE [dbo].[OrderDetail] 
	SET [DespatchTo] = 162 WHERE [DespatchTo] = 168

	UPDATE [dbo].[Order] 
	SET [BillingAddress] = 162 WHERE [BillingAddress] = 835
	UPDATE [dbo].[Order] 
	SET [DespatchToAddress] = 162 WHERE [DespatchToAddress] = 835
	UPDATE [dbo].[OrderDetail] 
	SET [DespatchTo] = 162 WHERE [DespatchTo] = 835

	DELETE FROM [dbo].[DistributorClientAddress] WHERE ID = 168 OR ID = 835


	 --Correcting 189
	UPDATE 	[dbo].[DistributorClientAddress]
	SET		[Address] = 'TBA'			
			,[Suburb] = 'TBA'
			,[PostCode] = 'TBA'
			,Country = 14
			,[ContactName] = 'TBA'
			,[ContactPhone] = 'TBA'
			,[CompanyName] = 'TBA'
			,[State] = 'TBA'
			,Port = 3
			,[EmailAddress] = 'TBA'
			,AddressType = 0
			,[IsAdelaideWarehouse] = 0
	WHERE ID = 189

	UPDATE [dbo].[Order] 
	SET [BillingAddress] = 189 WHERE [BillingAddress] = 190
	UPDATE [dbo].[Order] 
	SET [DespatchToAddress] = 189 WHERE [DespatchToAddress] = 190
	UPDATE [dbo].[OrderDetail] 
	SET [DespatchTo] = 189 WHERE [DespatchTo] = 190

	UPDATE [dbo].[Order] 
	SET [BillingAddress] = 189 WHERE [BillingAddress] = 192
	UPDATE [dbo].[Order] 
	SET [DespatchToAddress] = 189 WHERE [DespatchToAddress] = 192
	UPDATE [dbo].[OrderDetail] 
	SET [DespatchTo] = 189 WHERE [DespatchTo] = 192

	DELETE FROM [dbo].[DistributorClientAddress] WHERE ID = 190 OR ID = 192

	 --Correcting 201
	UPDATE 	[dbo].[DistributorClientAddress]
	SET		[Address] = 'TBA'			
			,[Suburb] = 'TBA'
			,[PostCode] = 'TBA'
			,Country = 14
			,[ContactName] = 'TBA'
			,[ContactPhone] = 'TBA'
			,[CompanyName] = 'TBA'
			,[State] = 'TBA'
			,Port = 3
			,[EmailAddress] = 'TBA'
			,AddressType = 0
			,[IsAdelaideWarehouse] = 0
	WHERE ID = 201

	UPDATE [dbo].[Order] 
	SET [BillingAddress] = 201 WHERE [BillingAddress] = 241
	UPDATE [dbo].[Order] 
	SET [DespatchToAddress] = 201 WHERE [DespatchToAddress] = 241
	UPDATE [dbo].[OrderDetail] 
	SET [DespatchTo] = 201 WHERE [DespatchTo] = 241

	DELETE FROM [dbo].[DistributorClientAddress] WHERE ID = 241
		
	COMMIT TRAN
END TRY
BEGIN CATCH
 ROLLBACK TRAN
END CATCH

GO


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

CREATE TABLE [dbo].PatternDevelopment  
   (ID int PRIMARY KEY IDENTITY(1,1) NOT NULL,  
    Spec bit NOT NULL DEFAULT 0,  
    LectraPattern bit NOT NULL DEFAULT 0,
	WhiteSample bit NOT NULL DEFAULT 0,
	LogoPositioning bit NOT NULL DEFAULT 0,
	Photo bit NOT NULL DEFAULT 0,
	Fake3DVis bit NOT NULL DEFAULT 0,
	NestedWireframe bit NOT NULL DEFAULT 0,
	BySizeWireframe bit NOT NULL DEFAULT 0,
	PreProd bit NOT NULL DEFAULT 0,
	SpecChart bit NOT NULL DEFAULT 0,
	FinalTemplate bit NOT NULL DEFAULT 0,
	TemplateApproved bit NOT NULL DEFAULT 0,
	Remarks nvarchar(512) NULL,
	LastModified datetime2(7) NOT NULL DEFAULT GETDATE(),
	Created datetime2(7) NOT NULL DEFAULT GETDATE(),
	LastModifier int NULL,
	Creator int NOT NULL,
	Pattern int NOT NULL);
ALTER TABLE [dbo].[PatternDevelopment]
	ADD CONSTRAINT FK_PatternDevelopment_Pattern
		FOREIGN KEY(Pattern) REFERENCES [dbo].Pattern(ID);

ALTER TABLE [dbo].[PatternDevelopment]
	ADD CONSTRAINT FK_PatternDevelopment_LastModifier
		FOREIGN KEY (LastModifier) REFERENCES [dbo].[User](ID);

ALTER TABLE [dbo].[PatternDevelopment]
	ADD CONSTRAINT FK_PatternDevelopment_Creator
		FOREIGN KEY (Creator) REFERENCES [dbo].[User](ID);

CREATE TABLE [dbo].[PatternDevelopmentHistory]
	(ID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	 PatternDevelopment int NOT NULL,
	 Modifier int NOT NULL,
	 ModifiedDate datetime2(7),
	 ChangeDescription nvarchar(250));

ALTER TABLE [dbo].[PatternDevelopmentHistory]
	ADD CONSTRAINT FK_PatternDevelopmentHistory_Modifier
		FOREIGN KEY(Modifier) REFERENCES [dbo].[User](ID);

ALTER TABLE [dbo].[PatternDevelopmentHistory]
	ADD CONSTRAINT FK_PatternDevelopmentHistory_PatternDevelopment
		FOREIGN KEY(PatternDevelopment) REFERENCES [dbo].[PatternDevelopment](ID);

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

CREATE PROC [dbo].[GetPatternDevelopments] 
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

ALTER PROCEDURE [dbo].[SPC_ViewPatternDetails]
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

CREATE PROC [dbo].[GetPatterDevelopmentHistory]
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

CREATE VIEW [dbo].[GetNonDevelopedPatterns]
AS
	SELECT p.Number AS PatternNumber	
	FROM [dbo].[Pattern] p
		LEFT JOIN [dbo].[PatternDevelopment] pd
			ON p.ID = pd.Pattern
	WHERE pd.ID IS NULL

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--