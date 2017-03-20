/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using fwt
using gfx

const class ObixStatusHandler : Actor
{
  const AtomicRef statusMap
  const Str tableHandle := Uuid().toStr

  new make(ObixMapperTable table, AtomicRef statusMap, ActorPool pool) : super(pool)
  {
    Actor.locals[tableHandle] = table
    this.statusMap = statusMap
  }

  override Obj? receive(Obj? msg)
  {
    if(msg.typeof.fits(List#) && msg != null)
    {
      //Case of adding a new reference
      List newRef := msg
      oldMap := statusMap.getAndSet(statusMap.val->rw->set(newRef[0], newRef[1]).toImmutable)
      if(statusMap.val->get(newRef[0]) != newRef[1])
      {
        send(msg)
        return null
      }
      Desktop.callAsync |->|
      {
        updateTable
      }
    }
    return null
  }

  Void updateTable()
  {
    table := Actor.locals[tableHandle] as ObixMapperTable
    if(table != null)
    {
      table.refreshAll
    }
  }
}
