/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using xml

@Serializable

const class SiteTemplate : Template
{


  new make(|This| f) : super(f)
  {

  }

  override Record[] createRecs(Int repeat := 1)
  {
    Record[] recs := [,]
    repeat.times{
      Site newsite := RecordFactory.getSite
      this.tags.each |tag|
      {
        newsite.add(tag)
      }
      recs.push(newsite)
    }
    return recs
  }

}
