/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


@Serializable
const class SqlPackage
{
  const SqlPackageRule[] rules
  const SqlPackageId id
  new make(|This| f)
  {
    f(this)
  }
}
