
SET NOCOUNT ON

DECLARE @VisualLayout TABLE(
	[Name] [nvarchar](64) NULL,
	[Description] [nvarchar](512) NULL,
	[Pattern] [int] NULL,
	[FabricCode] [int]  NULL,
	[Client] [int] NULL,
	[Coordinator] [int] NULL,
	[Distributor] [int]  NULL,
	[NNPFilePath] [nvarchar](512) NULL
	)

DECLARE @Id AS int
DECLARE @ProductNumber  AS nvarchar(255)
DECLARE @PatternId AS int
DECLARE @ResolutionProfileID AS int
DECLARE @ColourProfileID AS int
DECLARE @ContactID AS int 
DECLARE @PrinterID AS int
DECLARE @DateCreated AS DATETIME
DECLARE @Notes  AS nvarchar(255)
DECLARE @FabricCodesID AS int
DECLARE @EmployeeID AS int
DECLARE @DistributorID AS int
DECLARE @found AS bit
DECLARE VisualLayoutCursor CURSOR FAST_FORWARD FOR 
	SELECT	op.[ID]
      ,op.[ProductNumber]
      ,op.[PatternID]
      ,op.[ResolutionProfileID]
      ,op.[ColourProfileID]
      ,op.[ContactID]
      ,op.[Notes]
      ,op.[DateCreated]
      ,op.[FabricCodesID]
      ,op.[DistributorID]
      ,op.[EmployeeID]
      ,op.[PrinterID] 
	FROM OPS.dbo.tbl_Product op
	ORDER BY op.[ProductNumber], op.[DateCreated]
OPEN VisualLayoutCursor 
	FETCH NEXT FROM VisualLayoutCursor INTO @Id, @ProductNumber, @PatternId, @ResolutionProfileID, @ColourProfileID,												@ContactID, @Notes, @DateCreated, @FabricCodesID, @DistributorID, 
											@EmployeeID, @PrinterID
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	
		SET @found = 1 
		
		IF (EXISTS(SELECT ID FROM OPS.dbo.tbl_Pattern WHERE ID = @PatternId)
			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_Contact WHERE ID = @ContactID)
			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_FabricCodes WHERE ID = @FabricCodesID)
			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_Distributor WHERE ID = @DistributorID)
			AND EXISTS(SELECT ID FROM OPS.dbo.tbl_Employee WHERE ID = @EmployeeID))
		BEGIN
			INSERT INTO @VisualLayout (Name , [Description] , Pattern , FabricCode , Client , Coordinator ,													 Distributor , NNPFilePath )
			VALUES (@ProductNumber, @Notes,
				 (SELECT TOP 1 ID FROM Indico.dbo.Pattern ip WHERE ip.Number = (
						SELECT TOP 1 opa.PatternNumber 
						FROM OPS.dbo.tbl_Pattern opa
						WHERE opa.ID = @PatternId)),
				(SELECT TOP 1  ID FROM Indico.dbo.FabricCode iif WHERE iif.Name = (
						SELECT TOP 1 ofa.Name 
						FROM OPS.dbo.tbl_FabricCodes ofa
						WHERE ofa.ID = @FabricCodesID)),
				(SELECT TOP 1 ID FROM Indico.dbo.Client ic WHERE ic.Name =(
						SELECT TOP 1  oc.CompanyName
						FROM OPS.dbo.tbl_Contact oc									
						WHERE oc.ID = @ContactID)),
				(SELECT TOP 1 ID FROM Indico.dbo.[User] iu WHERE iu.ID = (
						 SELECT TOP 1 ie.ID 
						 FROM OPS.dbo.tbl_Employee ie
						 WHERE ie.ID = @EmployeeID)),
				(SELECT TOP 1 ID FROM Indico.dbo.Company ic WHERE ic.Name = ( 
						 SELECT TOP 1 od.CompanyName
						 FROM OPS.dbo.tbl_Distributor od
						 WHERE od.ID = @DistributorID)),
				NULL)		
		END
			  
		FETCH NEXT FROM VisualLayoutCursor INTO @Id, @ProductNumber, @PatternId, @ResolutionProfileID, @ColourProfileID,												@ContactID, @Notes, @DateCreated, @FabricCodesID, @DistributorID, 
												@EmployeeID, @PrinterID	
END 


INSERT INTO Indico.dbo.VisualLayout 
SELECT * FROM @VisualLayout WHERE Coordinator IS NOT NULL

CLOSE VisualLayoutCursor 
DEALLOCATE VisualLayoutCursor
	

GO

