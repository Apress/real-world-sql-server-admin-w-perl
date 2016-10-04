USE pubs
GO

CREATE PROC dbo.[orderSP] @p  varchar(20)
as
   /* EXEC dbo.reptq1 */ select * from authors
GO

CREATE PROCEDURE/* abc*/checkSP @p1 varchar(20)
as
   EXECUTE pubs.dbo.reptq1
GO
/*** comments ***/
CREATE PROC cutSP
as
   -- Comments in cutSP
   EXEC dbo.reptq1
   EXEC checkSP 'param one' 
   Execute myProc 'adhfklas'
   EXEC dbo.orderSP
GO

CREATE PROC reptq1 AS EXEC [reptq2 - Exec]
GO

CREATE PROCEDURE "reptq2 - Exec" AS
   select au_lname from authors
GO

/* CREATE PROC dba.spTry
   as EXEC reptq1  */
GO     

CREATE PROCEDURE dbo.loadSP
as
   declare @rc int
   EXEC pubs.dbo.checkSP 'my login'   -- EXEC reptq2
   EXECUTE [dbo].[cutSP] 'param one', 'param 2'
   EXEC @rc = orderSP 'abc'
   --     EXECute dbo.loadSP
   EXEC ('master..sp_lock')
   EXECute reptq1
GO
