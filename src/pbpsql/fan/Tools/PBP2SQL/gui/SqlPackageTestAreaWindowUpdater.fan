/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


using concurrent
using fwt
using pbpcore
using gfx
using pbplogging

const class SqlPackageTestAreaWindowUpdater : Actor, Logging
{
  const Str testAreaHandler := Uuid().toStr
  const Watcher watcher
  new make(SqlPackageTestAreaWindow window, Watcher watcher, ActorPool pool) : super(pool)
  {
    this.watcher = watcher
    Actor.locals[testAreaHandler] = window
  }

  override Obj? receive(Obj? msg)
  {

    if(watcher.check())
    {
      info("Updating TestAreaWindow")
      Desktop.callAsync |->|
      {
        updateWindow
      }
    }
    sendLater(10ms, null)
    return null
  }

  Void updateWindow()
  {

      window := Actor.locals[testAreaHandler] as SqlPackageTestAreaWindow
      if(window!=null)
      {
        window.notifyChange()
      }

  }
}
