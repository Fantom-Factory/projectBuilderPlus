/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


@Serializable
const class WatchType : Watch
{
  const Type? typetowatch

  new make(|This| f)
  {
    f(this)
  }
  @Transient
  override Bool check(Obj rec)
  {
   return rec.typeof.fits(typetowatch)
  }

}
