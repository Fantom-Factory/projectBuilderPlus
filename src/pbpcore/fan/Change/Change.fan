/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using haystack

@Serializable
const class Change
{
  const CID? id
  const Ref? target
  const DateTime ts := DateTime.now
  const Obj[] opts := [,]

  new make(|This| f)
  {
    f(this)
  }

  override Str toStr()
  {
    return id.toStr + " " + target.toStr + " " + ts.toStr + opts.toStr
  }
}
