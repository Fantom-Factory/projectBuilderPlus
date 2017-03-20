/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


@Serializable
class Program
{
  Str name
  Version version
  //Str dependencies

  new make(|This| f)
  {
    f(this)
  }

  override Str toStr()
  {
    return "${name} ${version}"
  }

}
