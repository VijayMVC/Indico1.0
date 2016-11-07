USE Indico
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--

-- access to clone orders for direct sales (Indico Coordinators)

INSERT INTO [dbo].[MenuItemRole] VALUES( 												
											(	SELECT ID
												FROM [dbo].[MenuItem]
												WHERE [Page] = (	SELECT ID
																	FROM [dbo].[Page]
																	WHERE name = '/CloneOrder.aspx'
																) 																	
												),
												(	SELECT ID FROM [dbo].[Role]
													WHERE [Description] = 'Indico Coordinator'	
												)
										)
GO

--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--
