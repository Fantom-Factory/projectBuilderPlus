/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbplogging
using concurrent
using pbpcore

class Main
{
  static const AtomicBool updatesAvail := AtomicBool(false)
  static const AtomicBool restart := AtomicBool(false)
  static const AtomicRef updateMap := AtomicRef(Str:Bool[:].toImmutable)
  static const ActorPool mainActorPool := ActorPool()
  static const Watcher helpMenuWatcher := Watcher()



  // Copy logs to a file.
  static const Logger logger := Logger
  {
    dir = Env.cur.workDir
    filename = "projectbuilder-{YYMM}.log"
  }

  Void main()
  {
    Log.addHandler |logrec| {logger.append(logrec)}

    try
    {
      Logger.log.info("Starting pbp ...")

		// SLIMER - don't bother looking for updates anymore!
//      ActorPeon(Main.mainActorPool)
//      {
//        config=CheckForUpdatesConfig()
//        options=["interval":15min]
//      }.send(null)

      ProjectBuilder.start()

      while (restart.val)
      {
        helpMenuWatcher.status.getAndSet(false)
        restart.getAndSet(false)
        updatesAvail.getAndSet(false)
        updateMap.getAndSet(Str:Bool[:].toImmutable)

        ProjectBuilder.start()
      }
    }
    catch(IOErr e)
    {
      Logger.log.err("Uncatched PBP error", e)
      return
    }

  }
}
