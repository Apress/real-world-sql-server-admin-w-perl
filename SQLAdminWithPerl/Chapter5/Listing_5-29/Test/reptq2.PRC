SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[reptq2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[reptq2]
GO


CREATE PROCEDURE reptq2 AS
select type, pub_id, titles.title_id, au_ord,
   Name = substring (au_lname, 1,15), ytd_sales
from titles, authors, titleauthor
where titles.title_id = titleauthor.title_id AND authors.au_id = titleauthor.au_id
   AND pub_id is NOT NULL
order by pub_id, type
COMPUTE avg(ytd_sales) BY pub_id, type
COMPUTE avg(ytd_sales) BY pub_id


GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

