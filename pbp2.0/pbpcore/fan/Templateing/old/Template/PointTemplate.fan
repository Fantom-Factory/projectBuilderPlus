/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using xml

@Serializable

const class PointTemplate : Template
{


  new make(|This| f) : super(f)
  {

  }

  override Record[] createRecs(Int repeat := 1)
  {
    Record[] recs := [,]
    repeat.times{
      Point newpoint := RecordFactory.getPoint
      this.tags.each |tag|
      {
        newpoint.add(tag)
      }
      recs.push(newpoint)
    }
    return recs
  }

}
