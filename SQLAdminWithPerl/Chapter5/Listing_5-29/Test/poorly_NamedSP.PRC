SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[poorly NamedSP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[poorly NamedSP]
GO

/* Just some test TSQL code */

/**** this is the comments that have all kinds of embedded stuff. 
  create procedure [dba].sp_checkOrder
  as                /****   this is comments inside /**/ still comments **/
     select * from "order table"
     select * from [another order 'table']
     select * from "more order 'table' and [table]"  /*** some wierd names /* nested comment */ end */
***/

create procedure "dbo".[poorly NamedSP]
as
set nocount on

declare @rc int

EXEC pubs..checkName 'custmer name'      -- EXEC [not really proc execution]

select * from abo."more weird table" where name = 'ndafd  EXEC master..sp_who dnafldsj "kls daf [klsadfj]fdsa'

EXECUTE anotherSP /*** embedded comments ***/ 'param one', 'param 2'

EXEC @rc = "anSP 0" 'abc xyz'     -- "comments "  more comments'

--     EXECute pubs.[test "DB"].[test Proc]

EXEC (N'pubs..spOrder')

EXECute reptq1

-- turn the following on/off for demo
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

