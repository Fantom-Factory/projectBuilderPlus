/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using xml
using haystack

const class Template : Templateing
{

  const Tag[] tags

  virtual Record[] createRecs(Int repeats := 1)
  {
    Record[] recs := [,]
    repeats.times{
      Record rec := Record
      {
        data = tags
      }
     recs.push(rec)
    }
    return recs
  }


  new make(|This| f) : super(f)
  {
    f(this)
  }

  override XElem toXml()
  {
    XElem root := XElem("Template"){XAttr("name",this.name),XAttr("desc",this.desc),XAttr("type",this.typeof.toStr),}
    tags.each |tag|
    {
      root.add(tag.toXml)
    }
    return root
  }

}
