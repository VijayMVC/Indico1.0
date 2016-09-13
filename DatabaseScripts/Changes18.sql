--**-- DELETE VISUALLAYOUT --**----**----**----**----**----**----**----**--
DELETE [Indico].[dbo].[VisualLayout]
GO
--**----**----**----**----**----**----**----**----**----**----**--

--**-- DELETE USERS --**----**----**----**----**----**----**----**--

DELETE FROM [Indico].[dbo].[User]
      WHERE [Company] = 2 AND [Username] != 'f_admin' 
						  AND [Username] != 'FCoordinator' 
						  AND [Username] != 'FPattern'
						  
GO
--**----**----**----**----**----**----**----**----**----**----**--

