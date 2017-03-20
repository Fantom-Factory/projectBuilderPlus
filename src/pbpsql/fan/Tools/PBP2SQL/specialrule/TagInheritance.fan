/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore

@Serializable
const class TagInheritance : SpecialRule
{
  new make(|This| f) : super(f)
  {

  }


  override Obj? processRule(Obj? msg)
  {
    List message := msg
    Tag[] tagstoInherit := options["inheritance"]
    Record parentRec := message[0]
    Record targetRec := message[1]

    tagstoInherit.each |tag|
    {
      Tag newtag := TagFactory.setVal(tag, parentRec.get(tag.name))
      targetRec = targetRec.set(newtag)
    }
    return targetRec
  }
}
