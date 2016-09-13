USE [Indico]
GO

------------ Update Distributor column ------------------

UPDATE dca
SET dca.Distributor = c.Distributor 
FROM [dbo].[DistributorClientAddress] dca
LEFT OUTER JOIN [dbo].[JobName] j
	ON dca.Client = j.id
LEFT OUTER JOIN [dbo].[Client] c
	ON j.Client = c.ID 
WHERE dca.Client IS NOT NULL AND dca.Distributor IS NULL	

GO

------------------------------

			





