SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[anotherSP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[anotherSP]
GO

create proc dbo."anotherSP"
    @p  varchar(20)
as
set nocount on

/* Comments inside "anotherSP" */
select * from employees
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

