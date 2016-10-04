SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.reptq1    Script Date: 07/11/2001 2:55:27 PM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[reptq1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[reptq1]
GO


CREATE PROCEDURE reptq1 AS
select pub_id, title_id, price, pubdate
from titles
where price is NOT NULL
order by pub_id
COMPUTE avg(price) BY pub_id
COMPUTE avg(price)


GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

