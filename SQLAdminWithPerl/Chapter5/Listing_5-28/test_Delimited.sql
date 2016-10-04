use pubs
go
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.another 'Junk SP    Script Date: 07/11/2001 2:55:26 PM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[another ''Junk SP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[another 'Junk SP]]]
GO

create proc dbo."another 'Junk SP]"
    @p  varchar(20)
as
set nocount on

/* Comments inside "another 'Junk SP" */
select * from employees

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.junkSP    Script Date: 07/11/2001 2:55:26 PM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[junkSP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[junkSP]
GO

/** More test code */

create procedure/* abc*/junkSP
      @p1 varchar(20) = NULL,
      @p2 varchar(20) = NULL
as

set nocount on

select * from authors 
 where au_lname = @p1
   and au_fname = @p2

execute master..sp_who

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

use [test db]
go
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.junkSP_0    Script Date: 07/11/2001 2:55:27 PM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[junkSP_0]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[junkSP_0]
GO

create proc [junkSP_0]
as
set nocount on

-- Comments in junk
/* More comments in junk */
EXEC master..sp_lock
                                  EXEC [master]..[sp_who]
EXEC junkSP 'param /* not comments */ one', 'abc'   Execute myProc 'adhfklas -- not comments neither'

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

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

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.reptq2    Script Date: 07/11/2001 2:55:27 PM ******/
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

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.strang procedure    Script Date: 07/11/2001 2:55:27 PM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[strang procedure]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[strang procedure]
GO

/* Just some test TSQL code */

/**** this is the comments that have all kinds of embedded stuff. 
  create procedure [dba].sp_depends
  as                /****   this is comments inside /**/ sjdf **/
     select * from "junk table"
     select * from [another junk 'table']
     select * from "more junk 'table' and [table]"  /***k adsj /* kljf dsa */ fasd f*/
***/

create procedure "dbo".[strang procedure]
as
set nocount on

declare @rc int

EXEC master..sp_who 'my login'      -- EXEC [not really proc execution]

select * from abo."more weird table" where name = 'ndafd  EXEC master..sp_who dnafldsj "kls daf [klsadfj]fdsa'

EXECUTE junkSP/*** embedded comments ***/'param one', 'param 2'

EXEC @rc = "another 'Junk SP]" 'abc xyz'     -- "djaf ads "  klsdaf fads 'abcdefg'

--     EXECute pubs.[Junk "DB"].[Junk Proc]

EXEC (N'master..sp_lock')

declare @sql varchar(255), @db sysname
set @sql = 'master.dbo.sp_helpdb'
set @db = 'pubs'
EXEC @rc = @sql @db

EXECute junk

-- turn the following on/off for demo
--EXEC dbo.junkSP_0
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
