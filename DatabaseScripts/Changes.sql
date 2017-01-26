USE Indico
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_GetOrderDetailIndicoPrice]    Script Date: 1/26/2017 1:31:47 PM ******/
DROP PROCEDURE [dbo].[SPC_GetOrderDetailIndicoPrice]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetOrderDetailIndicoPrice]    Script Date: 1/26/2017 1:31:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPC_GetOrderDetailIndicoPrice]
(
	@P_Order AS int
)
AS 

BEGIN	
	SELECT 	
		  od.[ID] AS OrderDetail
		  ,ot.[Name] AS OrderType
		  ,ISNULL(vl.[NamePrefix] + ''+ ISNULL(CAST(vl.[NameSuffix] AS NVARCHAR(64)), ''),'') AS VisualLayout
		  ,ISNULL(od.[VisualLayout],0) AS VisualLayoutID		  
		  ,ISNULL(p.Number, (SELECT Number FROM Pattern WHERE ID = od.[Pattern])) AS Pattern 
		  ,ISNULL(p.ID, od.[Pattern]) AS PatternID
		  ,ISNULL(fc.ID, od.FabricCode) AS FabricID
		  ,ISNULL(fc.[Name], (SELECT Name FROM FabricCode WHERE ID = od.FabricCode)) AS Fabric 		  
		  ,od.[Order] AS 'Order'
		  ,ISNULL(od.[Label],0) AS Label
		  ,ISNULL(ods.[Name], 'New') AS 'Status'
		  ,ISNULL(od.[Status],0) AS StatusID 
		  ,ISNULL((SELECT SUM(odq.[Qty]) FROM [dbo].[OrderDetailQty] odq WHERE odq.[OrderDetail] = od.[ID]), 0) AS Quantity
		  ,ISNULL(od.[EditedPrice], 0.00) AS DistributorEditedPrice		 
		  ,od.Surcharge 
		  ,ISNULL(od.DistributorSurcharge,0) AS DistributorSurcharge
		  ,od.VisualLayoutNotes
		  ,od.EditedPriceRemarks
		  ,od.FactoryInstructions
		  ,vl.IsEmbroidery
		  ,od.IsRepeat
		  ,rf.Name AS ResolutionProfile
		  ,pt.Name AS PocketType
	FROM [dbo].[Order] o
		LEFT OUTER JOIN [dbo].[OrderDetail] od
		ON o.[ID] = od.[Order]
		LEFT OUTER JOIN [dbo].[OrderType] ot 
			ON od.[OrderType] = ot.[ID]	
		LEFT OUTER JOIN [dbo].[OrderDetailStatus] ods
			ON  od.[Status] = ods.[ID]		
		LEFT OUTER JOIN [dbo].[VisualLayout] vl 
			ON od.[VisualLayout] = vl.[ID]	
		LEFT OUTER JOIN [dbo].[Pattern] p
			ON vl.[Pattern] = p.[ID]
		LEFT OUTER JOIN [dbo].[FabricCode] fc
			ON vl.[FabricCode] = fc.[ID]
		LEFT OUTER JOIN [dbo].[ResolutionProfile] rf
			ON vl.[ResolutionProfile] = rf.[ID]	
		LEFT OUTER JOIN [dbo].[PocketType] pt
			ON vl.[PocketType] = pt.[ID]
	WHERE od.[Order] = 56883	
END 

GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--