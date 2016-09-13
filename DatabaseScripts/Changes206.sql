USE Indico;
GO
--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
-- set pocket type null in all vls added after 2016-06-01 (not direct sale)
UPDATE vl SET PocketType = NULL 
	FROM [dbo].[VisualLayout] vl
		INNER JOIN [dbo].[JobName] jn
			ON vl.Client = jn.ID
		INNER JOIN [dbo].[Client] cl
			ON jn.Client = cl.ID
		INNER JOIN [dbo].[Company] dis
			ON cl.Distributor = dis.ID
WHERE vl.CreatedDate > '2016-06-01' AND dis.Name NOT LIKE 'BLACKCHROME%' AND vl.PocketType IS NOT NULL

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--