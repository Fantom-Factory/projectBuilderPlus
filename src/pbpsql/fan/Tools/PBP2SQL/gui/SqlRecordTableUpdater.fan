/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using pbpcore
using fwt
using pbplogging
using pbpgui

const class SqlRecordTableUpdater : Actor, Logging
{
  const Watcher watcher
  const AtomicRef rows
  const AtomicBool enabled
  const Str tableId := Uuid().toStr
  const Str:Obj? options

  new make(ActorPool pool, Table table, Watcher watcher, AtomicRef rows, Map options) : super(pool)
  {
    Actor.locals[tableId] = table
    this.watcher = watcher
    this.rows = rows
    this.options = options
    this.enabled = options["enabler"]
  }

  override Obj? receive(Obj? msg)
  {
    if(watcher.check() && enabled.val)
    {
      debug("updating")
      try
      {
      Desktop.callAsync |->|
      {
        updateTable()
      }
      }
      catch(Err e)
      {
      err("{this.typeof.name} Error",e)
      }
    }
    sendLater(10ms, null)
    return null
  }

  Void updateTable()
  {
    debug("trying to update")

    table := Actor.locals[tableId] as Table
    if(table!=null)
    {
      SqlPackage package := options["package"]
      SqlRow[] sqlrows := rows.val
      Str:Record recMap := [:]
      sqlrows.each |row|
      {
        Record? rec := SqlPackageUtil.getRec(package, row)
        if(rec!=null && !recMap.containsKey(rec.id.toStr))
        {
          recMap.add(rec.id.toStr,rec)
        }
      }
      (table.model as RecTableModel).update(recMap)
      table.refreshAll
    }
  }

}
