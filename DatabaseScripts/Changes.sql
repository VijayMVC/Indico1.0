USE Indico
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  View [dbo].[ReturnClientsDetailsView]    Script Date: 10/27/2016 1:02:55 PM ******/
DROP VIEW [dbo].[ReturnClientsDetailsView]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_ViewClientsDetails]    Script Date: 10/27/2016 1:02:27 PM ******/
DROP PROCEDURE [dbo].[SPC_ViewClientsDetails]
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_JobNameDetails]    Script Date: 10/27/2016 12:35:02 PM ******/
DROP PROCEDURE [dbo].[SPC_JobNameDetails]
GO

/****** Object:  StoredProcedure [dbo].[SPC_JobNameDetails]    Script Date: 10/27/2016 12:15:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_JobNameDetails]
(
	@P_SearchText AS NVARCHAR(255) = '',	
	@P_Distributor AS NVARCHAR(64) = ''
)
AS
BEGIN 
	SET NOCOUNT ON	
	DECLARE @Is_Distributor bit;
	DECLARE @Distributor_ID int;
	
	IF @P_Distributor LIKE '%DIS%'
		BEGIN
		SET @Is_Distributor = 1
		SET @Distributor_ID = CONVERT(INT, REPLACE(@P_Distributor,'DIS','' ))	
		END
	ELSE 
		BEGIN 
			IF(@P_Distributor LIKE '%COD%')
			SET @Is_Distributor = 0
			SET @Distributor_ID = CONVERT(INT, REPLACE(@P_Distributor,'COD','' ))
	END

	SELECT 			
			j.[ID] AS ID,
			j.[Name] AS Name,
			c.[Name] AS ClientName,	
			d.[Name] AS DistributorName,			
			ISNULL(j.[Address], '') AS 'Address',
			ISNULL(j.[Name], '') AS NickName,
			ISNULL(j.[City], '') AS City,
			ISNULL(j.[State], '') AS 'State',
			ISNULL(j.[PostalCode], '') AS PostalCode,			   
			ISNULL(j.[Country], 'Australia')AS Country,			     
			ISNULL(j.[Phone], '') AS Phone,
			ISNULL(j.[Email], '') AS Email,
			u.[GivenName] + ' ' + u.[FamilyName] AS Creator,
			j.[CreatedDate] AS CreatedDate  ,
			um.[GivenName] + ' ' + um.[FamilyName] AS Modifier,
			j.[ModifiedDate] AS ModifiedDate,
			CONVERT(bit, (SELECT CASE WHEN (EXISTS(SELECT TOP 1 (v.[Client]) FROM [dbo].[VisualLayout] v WHERE v.[Client] = j.[ID])) THEN 1 ELSE 0 END)) AS HasVisualLayouts			
	FROM [dbo].[JobName] j
		LEFT OUTER JOIN [dbo].[Client] c
			ON j.[Client] = c.[ID]
		LEFT OUTER JOIN [dbo].[Company] d
			ON c.[Distributor] = d.[ID]	
		JOIN [dbo].[User] u
			ON j.[Creator] = u.[ID]
		JOIN [dbo].[User] um
			ON j.[Modifier] = um.[ID]
	WHERE (@P_SearchText = '' OR
			j.[Name] LIKE '%' + @P_SearchText + '%' OR
			c.[Name] LIKE '%' + @P_SearchText + '%' OR
			d.[Name] LIKE '%' + @P_SearchText + '%' 
			)
			AND (@P_Distributor = '' OR ( 
									(@Is_Distributor = 1 AND d.[ID] = @Distributor_ID ) OR
									(@Is_Distributor = 0 AND d.[Coordinator] = @Distributor_ID)
									)
					)
END

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--