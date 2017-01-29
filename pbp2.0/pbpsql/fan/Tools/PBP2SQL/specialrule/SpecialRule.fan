/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////



const class SpecialRule
{
  const Str:Obj? options
  new make(|This| f)
  {
    f(this)
  }

  virtual Obj? processRule(Obj? msg){return null}

}
