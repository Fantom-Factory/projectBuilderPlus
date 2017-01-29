/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


**
** ConnProvider extensions
** To be iplemented by extensions((PbpConnExt) that provide connections
**
mixin ConnProvider
{
  abstract Str name // a unique name

  abstract Conn[] conns()
}
