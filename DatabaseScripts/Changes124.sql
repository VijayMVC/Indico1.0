USE [Indico]
GO

-- Adding CoreRange Column to Pattern table.. 2015-02-13
ALTER TABLE [dbo].[Pattern] 
ADD IsCoreRange bit NOT NULL
DEFAULT '0'