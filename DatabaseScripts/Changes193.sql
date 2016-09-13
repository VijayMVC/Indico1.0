USE [Indico]
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

/****** Object:  StoredProcedure [dbo].[SPC_GetOrderClients]    Script Date: 6/7/2016 5:24:15 PM ******/
DROP PROCEDURE [dbo].[SPC_GetOrderClients]
GO

/****** Object:  StoredProcedure [dbo].[SPC_GetOrderClients]    Script Date: 6/7/2016 5:24:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[SPC_GetOrderClients](
@P_Distributor AS int 
)

AS
BEGIN

	SELECT  DISTINCT c.[ID]
					,c.[Name] AS Name 
			--FROM [dbo].[Order] o
			-- JOIN [dbo].[Client] c
			--	ON o.[Client] = c.[ID]
			FROM [dbo].[OrderDetail] od
			JOIN [dbo].VisualLayout vl
				ON od.VisualLayout = vl.ID
			 JOIN [dbo].[JobName] j
				ON vl.[Client] = j.[ID]
			JOIN [dbo].[Client] c
				ON j.[Client] = c.ID
			WHERE (@P_Distributor = 0 OR c.[Distributor] = @P_Distributor)
			ORDER BY c.Name
END



GO


--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

