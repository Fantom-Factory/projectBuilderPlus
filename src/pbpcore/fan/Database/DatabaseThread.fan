/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using pbplogging

const class DatabaseThread : Actor, Logging
{
  const static Str SAVE := "SAVE"
  const static Str GETBYID := "GETBYID"
  const static Str GETCLASSMAP := "GETCLASSMAP"
  const static Str CLOSE := "CLOSE"
  const static Str REMOVE := "REMOVE"

  const ActorPeon fileWriter
  const AtomicRef ramDb
  const Actor? phandler
  const Int limit
  const AtomicInt counter := AtomicInt()

  new make(ActorPool pool, |This| f) : super(pool)
  {
    f(this)
  }

  override Obj? receive(Obj? msg)
  {
    List command := msg
    switch(command[0])
    {
      case SAVE:
        save(command[1])
        return true
      case GETBYID:
        return getById(command[1])
      case GETCLASSMAP:
        return getClassMap(command[1])
      case REMOVE:
        removeRec(command[1])
        return true
      case CLOSE:
        close()
        return true
      default:
        return null
    }
  }

  Void save(Record rec)
  {
    Str:Obj? xramDb := ramDb.val->rw
    try
    {
    if(xramDb[rec.typeof.name] == null)
    {
      xramDb[rec.typeof.name] = [rec.id.toStr:rec]
    }
    else
    {
      xramDb[rec.typeof.name] = xramDb[rec.typeof.name]->rw->set(rec.id.toStr,rec)
    }
    if(xramDb["Record"] == null)
    {
      xramDb["Record"] = [rec.id.toStr:rec]
    }
    else
    {
      xramDb["Record"] = xramDb["Record"]->rw->set(rec.id.toStr,rec)
    }
      while(ramDb.val.hash != xramDb.toImmutable.hash)
      {
        ramDb.getAndSet(xramDb.toImmutable)
      }
      //Counting here...
      Int oldVal := counter.val
      Int newVal := oldVal+1
      counter.getAndSet(newVal)
      while(counter.val != newVal)
      {
        counter.getAndSet(newVal)
      }
      if(phandler!=null){phandler.send([counter.val, limit, counter.val.toStr + "/" + limit.toStr + " Records"])}
      if(limit == counter.val)
      {
        debug("closing")
        close()
      }
    }
    catch(Err e)
    {
      err("Save error", e)
    }
    return
  }

  Void removeRec(Record rec)
  {
    Str:Obj? xramDb := ramDb.val->rw
    try
    {
      Map newmap1 := xramDb[rec.typeof.name]->rw
      Map newmap2 := xramDb["Record"]->rw
      newmap1.remove(rec.id.toStr)
      newmap2.remove(rec.id.toStr)
      xramDb.set(rec.typeof.name,newmap1)
      xramDb.set("Record",newmap2)
    while(ramDb.val.hash != xramDb.toImmutable.hash)
      {
        ramDb.getAndSet(xramDb.toImmutable)
      }
      //Counting here...
      Int oldVal := counter.val
      Int newVal := oldVal+1
      counter.getAndSet(newVal)
      while(counter.val != newVal)
      {
        counter.getAndSet(newVal)
      }
      if(phandler!=null){phandler.send([counter.val, limit, counter.val.toStr + "/" + limit.toStr+ "Records"])}
      if(limit == counter.val)
      {
        debug("closing")
        close()
      }
    return
     }
    catch(Err e)
    {
      Logger.log.err("RemoveRec Error", e)
    }
  }

  Record getById(Str id)
  {
    Map ramDb := this.ramDb.val
    return ramDb["Record"]->get(id)
  }

  Map? getClassMap(Type type)
  {
    Map ramDb := this.ramDb.val
    if(!ramDb.containsKey(type.name)){ramDb[type.name]=[:]}
    return ramDb[type.name]
  }

  Void close()
  {
    fileWriter.send(this.ramDb.val->ro)
    phandler.send([counter.val, limit, "Done"])
  }
}
