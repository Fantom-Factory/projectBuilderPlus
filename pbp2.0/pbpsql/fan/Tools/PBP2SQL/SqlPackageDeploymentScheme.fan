/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


@Serializable
const class SqlPackageDeploymentScheme
{
  const SqlPackage[] packages
  const Str:Str formMap
  new make(|This| f)
  {
    f(this)
  }

}
