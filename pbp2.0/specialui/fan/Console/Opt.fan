/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////



class Opt
{
  Str[] opts
  new make(|This| f)
  {
    f(this)
  }

  @Transient
  virtual Str getDis()
  {
    return opts.toStr
  }

}
