/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


@Serializable
const class WatchTagVals : Watch
{
  const Tag[] tagstowatch := [,]

  new make(|This| f)
  {
    f(this)
  }
  @Transient
  override Bool check(Obj rec)
  {
    pass := true
    tagstowatch.each |tag|
    {
      check := (rec as Record).data.find|Tag t->Bool|{return t.val == tag.val}
      if(check == null)
      {
        pass = false
      }
    }
    return pass
  }
}
