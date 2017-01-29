/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using haystack

const class RecordController : Actor
{
  const Str dataHandle := Uuid().toStr
  const AtomicRef dataMap
  const Log log

  new make(AtomicRef dataMap, Log log) : super(ActorPool())
  {
    this.log = log
    this.dataMap = dataMap
  }

  override Obj? receive(Obj? msg)
  {
    //AtomicRef == msg then... change := fmsg.val ... at the end we set it back again with the new change.. which will have the previous value...
    Change change := msg
    try
    {
    switch(change.id)
    {
      case CID.REMOVETAG:
        Record newRec := getRec(change.target).remove(change.opts[0]->name)
        modRec(change.target, newRec)
        return true
      case CID.ADDTAG:
        Record newRec := dataMap.val->rw->get(change.target.toStr)->add(change.opts[0])
        newMap := dataMap.val->rw->set(change.target.toStr, newRec)
        dataMap.getAndSet(newMap.toImmutable)
        Actor.sleep(Duration(600))
        return true
      case CID.MODTAG:
        Record newRec := getRec(change.target).set(change.opts[0])
        modRec(change.target, newRec)
        return true
      case CID.MULTIADD:
        return true
      case CID.INIT:
        init(change.opts[0])
        return true
      case CID.ADD:
        add(change.opts[0])
        return true
      case CID.REMOVE:
        remove(change.target)
        return true
      case CID.GET:
        return getRec(change.target)
      case CID.MOD:
        //TODO: not sure what to do with this... update later can't think THAT far ahead.
        return true
      case CID.SAVE: //SAVE RECS CURRENTLY IN MEMORY TO FILE
        File homeDir := change.opts[0]
        /*
        dataMap.val->vals->each |rec|
        {
          FileUtil.createRecFile(homeDir,rec)
        }
        */
        return true
      default:
        //noop nofail noproblem
        return true
    }
    }
    catch(Err e)
    {
      log.err("Error processing record request",e)
      return false
    }
  }

  **
  ** Inits the data map to a new map, atomically
  **
  Void init(Map newMap)
  {
    dataMap.getAndSet(newMap)
  }

  **
  ** Adds a new record to the data map, atomically
  **
  Void add(Record newRec)
  {
    newMap := dataMap.val->rw->add(newRec.id.toStr, newRec)
    dataMap.getAndSet(newMap.toImmutable)
  }

  **
  ** Removes a target record from the data map, atomically
  **
  Void remove(Ref target)
  {
    newMap := dataMap.val->rw->remove(target.toStr)
    dataMap.getAndSet(newMap.toImmutable)
  }

  **
  **Get a record
  **
  Record? getRec(Ref target)
  {
   rec := dataMap.val->rw->get(target.toStr)
   return rec
  }

  **
  **Modify a record
  **
  Void modRec(Ref target, Record newRec)
  {
    newMap := dataMap.val->rw->set(target.toStr, newRec)
    dataMap.getAndSet(newMap.toImmutable)
  }

}


