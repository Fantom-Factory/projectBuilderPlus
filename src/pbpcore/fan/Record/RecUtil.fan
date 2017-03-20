/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using haystack
using concurrent

class RecUtil
{
  static Obj modRec(Record rec, Str tagName, Tag? newTag:=null){
    newTags := Tag[,]
    if(newTag!=null)
    {
      newTags.add(newTag)
    }
    newTags.addAll(rec.data.findAll |Tag t -> Bool| {return t.name != tagName})

    return newRec(rec, newTags)
  }

  static Obj removeTags(Record rec, Str[] dropTags)
  {
    newTags := Tag[,]
    newTags.addAll(rec.data.findAll |Tag t -> Bool| {return ! dropTags.contains(t.name)})
    return newRec(rec, newTags)
  }

  static Obj newRec(Record rec, Tag[] newTags)
  {
  switch(rec.typeof){
    case Site#:
      Site newSite := Site{
        it.data = newTags
        it.id = rec.id
      }
      return newSite
    case Equip#:
      Equip newEquip := Equip{
        it.data = newTags
        it.id = rec.id
      }
      return newEquip
    case Point#:
      Point newPoint := Point{
        it.data = newTags
        it.id = rec.id
      }
      return newPoint
    default:
        setFunc := Field.makeSetFunc([Record#id: rec.id, Record#data: newTags.toImmutable])
        return rec.typeof.make([setFunc])
    }
  }
}
