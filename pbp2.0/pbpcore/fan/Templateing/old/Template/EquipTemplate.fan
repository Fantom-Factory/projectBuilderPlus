/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using xml

@Serializable

const class EquipTemplate : Template
{


  new make(|This| f) : super(f)
  {

  }

  override Record[] createRecs(Int repeat := 1)
  {
    Record[] recs := [,]
    repeat.times{
      Equip newequip := RecordFactory.getEquip
      this.tags.each |tag|
      {
        newequip.add(tag)
      }
      recs.push(newequip)
    }
    return recs
  }

}
