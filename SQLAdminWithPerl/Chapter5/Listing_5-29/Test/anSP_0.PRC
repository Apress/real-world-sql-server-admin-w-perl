SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[anSP 0]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[anSP 0]
GO

create proc [anSP 0]
as
set nocount on

-- Comments in junk
/* More comments in junk */
EXEC pubs..reptq1

EXEC reptq2 'param /* not comments */ one', 'abc' 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

