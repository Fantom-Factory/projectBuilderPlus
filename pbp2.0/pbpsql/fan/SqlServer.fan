/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using sql

@Serializable
const class SqlServer
{
  const Str host
  const Str user
  const Str pass
  const SqlDatabase[] children
  const Obj? parent := null
  const SqlDatabase? targetBase := null

  new make(|This| f)
  {
    f(this)
  }


}
