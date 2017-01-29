/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

class ChangeUtil
{
  static Change[] compareRecs(Record oldRec, Record newRec,
                              Bool? useDisMacro := false)
  {
    Change[] changes := [,]
    Tag[] newtags := [,]
    Tag[] deltags :=  [,]
    //Make it easier to compare... make maps!
    Str:Obj? oldDataMap := [:]
    Str:Obj? newDataMap := [:]

    if (useDisMacro) {
      if (oldRec.typeof == Equip# || oldRec.typeof == Point#) {
        oldRec = oldRec.remove("dis")
      }
      if (newRec.typeof == Equip# || newRec.typeof == Point#) {
        newRec = newRec.remove("dis")
      }
    }

    oldRec.data.each |tag|
    {
      oldDataMap.add(tag.name, tag)
    }

    newRec.data.each |tag|
    {
      newDataMap.add(tag.name, tag)
    }

    //Find removed tags
    //Find modded tags
    //Find added tags
    newDataMap.each |val,key|
    {
       if(!oldDataMap.containsKey(key))
      {
        newtags.push(val)
      }
       else
      {
        if(oldDataMap.get(key)->val.toStr != val->val.toStr)
        {
         changes.push(ChangeFactory.getModTagChange(oldRec.id,val))
        }
      }
    }

    oldDataMap.each |val,key|
    {
      if(!newDataMap.containsKey(key)){deltags.push(val)}
    }

    newtags.each |tag|
    {
      changes.push(ChangeFactory.getNewTagChange(oldRec.id,tag))
    }

    deltags.each |tag|
    {
      changes.push(ChangeFactory.getDelTagChange(oldRec.id,tag))
    }

    return changes
  }

}
