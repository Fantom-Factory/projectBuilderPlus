/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


@Serializable
const class SqlPackageId
{
  const Str:Obj? idVal
  new make(|This| f)
  {
    f(this)
  }

  @Operator
  Obj? get(Str s)
  {
    return idVal[s]
  }
}
