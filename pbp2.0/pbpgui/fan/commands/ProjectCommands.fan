/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore
using pbpi
using concurrent


class ProjectCommands : Commands
{
  private PbpListener pbp
  private UseDisMacro useDisMacroBtn
  
  new make(PbpListener pbp)
  {
    this.pbp = pbp
    this.useDisMacroBtn = UseDisMacro(pbp)
  }

  override public ToolBar getToolbar()
  {
    ToolBar toolbar := ToolBar()
    toolbar.addCommand(AddProject(pbp))
    toolbar.addCommand(DeleteProject(pbp))
    toolbar.add(Button{mode=ButtonMode.sep})
    toolbar.add(Button{mode=ButtonMode.sep})
    toolbar.addCommand(Open())
    toolbar.addCommand(Save(pbp))
    toolbar.add(Button{mode=ButtonMode.sep})
    toolbar.add(Button{mode=ButtonMode.sep})
    toolbar.addCommand(Reset())
    toolbar.add(Button{mode=ButtonMode.sep})
    toolbar.add(useDisMacroBtn)
    return toolbar
  }

  Void notifyToolbar(Obj:Obj options) {
    useDisMacroBtn.updateStatusForProject(options.get("useDisMacro"))
  }

  static Command add(PbpListener pbp)
  {
    return AddProject(pbp)
  }

  static Command rem(PbpListener pbp)
  {
    return DeleteProject(pbp)
  }

  static Command open()
  {
    return Open()
  }

  static Command save(PbpListener pbp)
  {
    return Save(pbp)
  }

  static Command reset()
  {
    return Reset()
  }

}


class AddProject : Command
{
  private PbpListener pbp
  new make(PbpListener pbp) :  super.makeLocale(Pod.find("projectBuilder"),"projectAdd")
  {
    this.pbp = pbp
  }
  //TODO: Fill Implementation

  override Void invoked(Event? e)
  {
    ws := pbp.workspace as PbpWorkspace
    projectName := Dialog.openPromptStr(e.window,"What would you like to call this project?")//{title="Create Project"}
    if (projectName != null)
    {
        pbp.callback("setCurProject", [Project(projectName)])
        ws.projExplorer.update
        ws.projExplorer.refreshAll
    }
  }

}

class DeleteProject : Command
{
  private PbpListener pbp
  new make(PbpListener pbp) : super.makeLocale(Pod.find("projectBuilder"),"projectRem")
  {
    this.pbp = pbp
  }
  //TODO: Fill Implementation

  override Void invoked(Event? e)
  {
    ws := pbp.workspace as PbpWorkspace

    File[] selectedFiles := ws.projExplorer.getSelected

    resp := Dialog.openQuestion(e.window, "Are you sure you would like to delete ${selectedFiles.size} projects?", null, Dialog.yesNo)//{title="Delete Projects"} //TODO: fill in details here
    if (resp == Dialog.yes)
    {
      selectedFiles.each |file|
      {
        pbp.callback("removeProject", [file.basename])
        file.delete
      }

      pbp.callback("projectsRemoved", [selectedFiles])
    }

    return
  }

}

class Open : Command
{
  new makeLocale() : super.makeLocale(Pod.find("projectBuilder"),"projectOpen")
  {
  }
  //TODO: Fill Implementation
  /*
  override Void invoked(Event? e)
  {
    Int[] selected := PbpWorkspace(pbp).projectTable.selected
    resp := Dialog.openQuestion(e.window, "Compile this project into a pbp file?", null, Dialog.yesNo)//{title="Delete Projects"} //TODO: fill in details here
    if(resp == Dialog.yes)
    {
       PbpWriter(pbp.currentProject).compile()
    }
  }
  */

}

class Save : Command
{
  private PbpListener pbp
  
  new makeLocale(PbpListener pbp) : super.makeLocale(Pod.find("projectBuilder"),"projectSave")
  {
    this.pbp = pbp
  }
  //TODO: Fill Implementation

  override Void invoked(Event? e)
  {
    prj := pbp.prj
    PbpWorkspace ws := pbp.workspace

    resp := Dialog.openQuestion(e.window,
                                "Compile this project into a pbp file?",
                                null, Dialog.yesNo)
    //{title="Delete Projects"} //TODO: fill in details here

    useDisMacro := prj.projectConfigProps.get("useDisMacro", "false").toBool
    echo("setting useDisMacro to ${useDisMacro}")

    if (resp == Dialog.yes) {
      ActorPool newPool := ActorPool()
      ProgressWindow pwindow := ProgressWindow(Desktop.focus.window, newPool)
      Future dicts := ActorPeon(newPool){
        config = MakeGridFromRecsConfig()
        options = ["phandler": pwindow.phandler, "useDisMacro": useDisMacro]
      }.send(prj.database.getClassMap(Record#).vals.toImmutable)
      pwindow.open()
      newPool.stop()
      newPool.join()
      PbpWriter(prj).compile(dicts.get)
    }
  }
}


class Reset : Command
{
  new makeLocale() : super.makeLocale(Pod.find("projectBuilder"),"projectReset")
  {
  }
}

/*
class AddTreee : Command
{
  ProjectBuilder pbp
  new make(ProjectBuilder pbp) : super.makeLocale("addTree")
  {
    this.pbp = pbp
  }

  override invoked(Event? e)
  {
    TreeSelectorWindow(e.window).open()
  }
}
*/

class UseDisMacro : Button {

  private PbpListener pbp

  new make(PbpListener pbp) : super.make()
  {
    this.pbp = pbp
    this.text = "UseDisMacro"
    this.mode = ButtonMode.check
    
    onAction.add |Event e| {
      File[] selectedFiles := (pbp.workspace as PbpWorkspace).projExplorer.getSelected
      if (selectedFiles.size > 0) {
        selectedFiles.each |File filePath| {
          selectedProject := pbp.callback("getCurProject") as Project
          projectProps := selectedProject.projectConfigProps
          projectProps["useDisMacro"] = "${this.selected}"
          selectedProject.updateProjectProps(projectProps)
        }
      }
    }
  }

  Void updateStatusForProject(Bool status) {
    this.selected = status
  }
  
}
