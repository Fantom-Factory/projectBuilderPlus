/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


@Serializable
const class SqlCol
{
  const Str name
  const Obj? parent
  const List children := [,]
  new make(|This| f)
  {
    f(this)
  }

  override Str toStr()
  {
    return name
  }
}
