/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore

@Serializable
const class SqlPackageRule
{
  const SpecialRule[] specialRules
  //Sql Col -> Mapping, Mapping -> filter /if no filter -> goes to Tag map
  const Str:Str mapping //colname:tagid
  const Str:SqlFilter filter //colname:Filter
  const Str:Tag[] tagmap //tagid:tag

  new make(|This| f)
  {
    f(this)
  }
}
