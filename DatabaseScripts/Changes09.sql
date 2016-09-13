USE [Indico]
GO

/****** Object:  Table [dbo].[PriceRemarks]    Script Date: 10/09/2012 12:38:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PriceRemarks](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Price] [int] NOT NULL,
	[Remarks] [nvarchar](512) NOT NULL,
	[Creator] [int] NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_PriceRemarks] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[PriceRemarks]  WITH CHECK ADD CONSTRAINT [FK_PriceRemarks_Price] FOREIGN KEY([Price])
REFERENCES [dbo].[Price] ([ID])
GO
ALTER TABLE [dbo].[PriceRemarks] CHECK CONSTRAINT [FK_PriceRemarks_Price]
GO


--**--**--**--**----**--**----**--**----**--**----**--**----**--**----**--**----**--**----**--**----**--**----**--**----**--**--


