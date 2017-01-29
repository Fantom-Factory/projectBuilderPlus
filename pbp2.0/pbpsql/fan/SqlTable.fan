/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


@Serializable
const class SqlTable
{
  const Str name
  const SqlCol[] children
  const Obj? parent
  new make(|This| f)
  {
    f(this)
  }

}
