/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore
using pbpgui
using projectBuilder
using concurrent

class AddToProjectCommand : Command
{
  private SkysparkConnManager connManager
  private PbpListener pbpListener

  new make(SkysparkConnManager connManager, PbpListener pbpListener) : super()
  {
    this.connManager = connManager
    this.pbpListener = pbpListener
    this.icon = Image(`fan://pbpi/res/img/circleRight16.png`)
  }

  override Void invoked(Event? e)
  {
    //TODO: Needs to be refactored for speed
    //Prompt for target project/s, or if nothing exists.. new project.

    //1. Installed Project Selector... pbpgui
    File[] dirs := ProjectSelector(e.window, pbpListener).open()
    //2. Confirm selected connection...
     conn := connManager.getSelected.first
     resp := Dialog.openQuestion(e.window,"Would you like to contiue installing on ${dirs.size} projects?",null,Dialog.yesNo)
    if(resp == Dialog.yes)
    {
    //Alt, let them lazily connect to a different connection...
    //3. Download Recs via SkysparkConn.addRecsToProject
    //Task downloadTask := Task{}
    dirs.each |dir|
    {
      ActorPool newPool := ActorPool()
      ProgressWindow window := ProgressWindow(e.window, newPool)
      Record[] recs := conn.addRecsToProject

      Project? project
      if(dir.basename == connManager.pbp.currentProject.name)
      {
        project = connManager.pbp.currentProject
      }
      else
      {
        project = Project(dir.basename)
      }
      DatabaseThread dbthread := project.database.getThreadSafe(recs.size, window.phandler, newPool)
      recs.each |rec|
      {
        dbthread.send([DatabaseThread.SAVE,rec])
      }
      window.open()
      newPool.stop()
      newPool.join()
      project.database.unlock()
    }
      PbpWorkspace pbpwrapper := connManager.pbp.asWorkspace
      pbpwrapper.siteExplorer.update(connManager.pbp.currentProject.database.getClassMap(Site#))
      pbpwrapper.equipExplorer.update(connManager.pbp.currentProject.database.getClassMap(Equip#))
      pbpwrapper.pointExplorer.update(connManager.pbp.currentProject.database.getClassMap(pbpcore::Point#))
      pbpwrapper.siteExplorer.refreshAll
      pbpwrapper.equipExplorer.refreshAll
      //Save
      pbpgui::Save(connManager.pbp).invoked(e)
      //Persist Last Upload to enable syncing
      conn.persistLastUpload()
      pbpwrapper.pointExplorer.refreshAll
    //4. Install to each project..
    //Task installTask := Task{}
    //Tasklist tasklist := Tasklist(tasks)
    //Progress progress := Progress(tasklist).start
    //5.??Show results here??
    //NOTE: spgui -> Task Manager...
    //}
    }
  }

}
