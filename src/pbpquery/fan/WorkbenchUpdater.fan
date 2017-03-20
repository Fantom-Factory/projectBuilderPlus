/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using pbpcore
using fwt
using projectBuilder

const class WorkbenchUpdater : Actor
{
  const Str tabHandler := Uuid().toStr
  const Str pbpHandler := Uuid().toStr
  const Watcher watcher
  new make(Tab tab, ProjectBuilder pbp, Watcher watcher) : super(ActorPool())
  {
    Actor.locals[tabHandler] = tab
    Actor.locals[pbpHandler] = pbp
    this.watcher = watcher
  }

  override Obj? receive(Obj? msg)
  {
      if(watcher.check)
      {
        Desktop.callAsync |->| {
          updateWorkbench()
        }
      }
    sendLater(1ms, null)
    return null
  }

  Void updateWorkbench()
  {
    pbp := Actor.locals[pbpHandler] as ProjectBuilder ?: throw Err("Invalid PBP sent to actor")

    temp := pbp.callback("getAuxWidgets")
    map := temp as Str:Obj? ?: throw Err("Callback(getAuxWidgets) must return [Str:Obj?] not $temp")


    /*
      Retrieve pbp, get index from current project, index project, render new workbench, save latest wb
    */
    RecordIndexer indexer := pbp.prj.getIndex()
    indexer.index
    Searcher searcher := Searcher(pbp, indexer)
    SearcherPane searcherPane := searcher.getPane

    map["latestwb"] = searcherPane

    /*
      Update Tab
    */
    tab := Actor.locals[tabHandler] as Tab
    if(tab != null)
    {
      tab.removeAll
      tab.add(searcherPane)
      tab.relayout
      tab.parent.relayout
    }
  }

}
