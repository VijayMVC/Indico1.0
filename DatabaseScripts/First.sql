USE [Indico] 
GO

DECLARE @ID AS int
DECLARE @COUNT AS int
DECLARE @Distributor AS int
DECLARE @VisualID AS int

DECLARE updatedistributor CURSOR FAST_FORWARD FOR 

SELECT  DISTINCT c.[ID]
FROM [dbo].[Client] c
	JOIN [dbo].[VisualLayout] v
		ON c.[ID] = v.[Client]
WHERE  c.[Distributor] != v.[Distributor]
GROUP BY c.[ID], c.[Distributor]
ORDER BY c.[ID]

OPEN updatedistributor 
	FETCH NEXT FROM updatedistributor INTO @ID
	WHILE @@FETCH_STATUS = 0 
	BEGIN 	
			SET @VisualID = (SELECT  MAX(v.[ID]) FROM [dbo].[VisualLayout] v WHERE v.[Client] = @ID)
			
			IF ((SELECT  v.[Distributor] FROM [dbo].[VisualLayout] v WHERE v.[ID] = @VisualID) IS NOT  NULL) 
				BEGIN
					SET @Distributor = (SELECT v.[Distributor] FROM [dbo].[VisualLayout] v WHERE v.[ID] = @VisualID)
							
					UPDATE [dbo].[Client] SET [Distributor] = @Distributor WHERE [ID] = @ID
				END
			ELSE
				BEGIN
					SET @VisualID = (SELECT  MIN(v.[ID]) FROM [dbo].[VisualLayout] v WHERE v.[Client] = @ID)
					SET @Distributor = (SELECT v.[Distributor] FROM [dbo].[VisualLayout] v WHERE v.[ID] = @VisualID)
						
					UPDATE [dbo].[Client] SET [Distributor] = @Distributor WHERE [ID] = @ID
				END	
		FETCH NEXT FROM updatedistributor INTO @ID
	END 
	
CLOSE updatedistributor 
DEALLOCATE updatedistributor		
GO

