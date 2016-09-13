
USE [Indico]
GO

-- Updating Price records -- 

DECLARE @RowCount INT
DECLARE @Price  INT
DECLARE @IndimanPrice  INT

DECLARE  @tmpUpdatingPrice TABLE( 
	[PriceID] INT, 
	[IndimanCost] FLOAT
	)

INSERT INTO @tmpUpdatingPrice
  SELECT DISTINCT (SELECT TOP 1 ID FROM [dbo].[Price] 
					WHERE [Pattern] = np.[PatternID] AND [FabricCode] = np.[FabricID]
					) AS [PriceID],
					np.[IndimanCost] 
			FROM [dbo].[NewPrices] np											

SELECT TOP 1 
           @Price = [PriceID]
           ,@IndimanPrice = [IndimanCost]
  FROM @tmpUpdatingPrice


SET @RowCount = @@ROWCOUNT

WHILE @RowCount <> 0
  BEGIN
	
	UPDATE [dbo].[PriceLevelCost]
	SET IndimanCost = @IndimanPrice
	WHERE Price = @Price
	
	DELETE FROM @tmpUpdatingPrice 
     WHERE [PriceID] = [PriceID]
	
	SELECT TOP 1 
               @Price = [PriceID]
               ,@IndimanPrice = [IndimanCost]
      FROM @tmpUpdatingPrice	
  
   SET @RowCount = @@ROWCOUNT

  END
  
  
  -- SELECT   *
  --FROM [dbo].[Price] p
  --where (select count (id) from [dbo].[Price] pt 
		--	where p.pattern = pt.pattern and p.fabriccode = pt.fabriccode) > 1
