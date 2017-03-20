/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using obix
using pbpcore
using pbpgui
using projectBuilder
using pbplogging

class AddToProjectCommand : Command
{
  ObixConnManager manager
  new make(ObixConnManager manager) : super.makeLocale(Pod.of(this), "addToProject")
  {
    this.manager = manager
  }

  override Void invoked(Event? e)
  {
    ObixTableModel obixModel := manager.obixTable.model
    PbpObixConn conn := (manager.tree.model as PbpObixTreeModel).conn
    ObixItem[] importantItems := [,]
    manager.tree.selected.each |node|
    {
      ObixItem? targetItem := node as ObixItem
      if(targetItem.obj.contract.toStr.contains("obix:Point"))
      {
        importantItems.push(targetItem)
      }
      if(targetItem.obj.contract.toStr.contains("obix:History"))
      {
        importantItems.push(targetItem)
      }
    }
    PbpWorkspace workspace := manager.pbp.asWorkspace
    Record[] recsToEdit := workspace.pointExplorer.getSelected

      if(manager.pbp.auxWidgets.containsKey("latestwb")){
      RecordSpace space := manager.pbp.auxWidgets["latestwb"]
      recsToEdit.addAll(space.getSelectedPoints)
      }

    ObixMapperWindow window := ObixMapperWindow(e.window, manager, importantItems, recsToEdit)
    ActorPeon searcher := ActorPeon(window.statusHandler.pool){
      config = SearchForHistoryConfig()
      options = ["streetcred":[Uri(conn.host),conn.user,conn.conn.plainPassword],"statusHandler":window.statusHandler]
    }
    importantItems.findAll |ObixItem item -> Bool|{return item.obj.contract.toStr.contains("obix:Point")}.each |point|
    {
      searcher.send(point.obj.normalizedHref)
    }
    recs := window.open as Record[]
    if(recs==null){return }
    resp := Dialog.openInfo(e.window,"Are you sure you would like to continue?",null,Dialog.yesNo)
    if(resp==Dialog.no){return}


    ProgressWindow progressWindow := ProgressWindow(e.window, window.statusHandler.pool)
    DatabaseThread dbthread := manager.pbp.currentProject.database.getThreadSafe(recs.size, progressWindow.phandler, window.statusHandler.pool)
    recs.each |rec|
    {
      dbthread.send([DatabaseThread.SAVE,rec])
    }
    progressWindow.open()

    window.statusHandler.pool.stop()
    window.statusHandler.pool.join()
    manager.pbp.currentProject.database.unlock()
    /*
    recs->each |rec|
    {
      manager.pbp.currentProject.database.save(rec)
    }
    */
    PbpWorkspace pbpwrapper := manager.pbp.asWorkspace
    pbpwrapper.pointExplorer.update(manager.pbp.currentProject.database.getClassMap(pbpcore::Point#))
    pbpwrapper.pointExplorer.refreshAll
    //DatabaseThread here
  }
}


