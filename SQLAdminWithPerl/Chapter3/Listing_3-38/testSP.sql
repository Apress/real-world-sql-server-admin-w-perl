use pubs
go
-- create proc
CREATE PROCEDURE [dbo].[place Order]
AS
/* created by: Linchi Shea */

-- EXEC another proce
EXEC @rc = "check Customer" 'Joe Blow', 
                            'Executive'  
GO
