SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.junkSP    Script Date: 07/11/2001 2:55:26 PM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[anSP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[anSP]
GO

/** More test code */

create procedure anSP
      @p1 varchar(20) = NULL,
      @p2 varchar(20) = NULL
as

set nocount on

select * from authors 
 where au_lname = @p1
   and au_fname = @p2

execute pubs..[anSP 0]

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

