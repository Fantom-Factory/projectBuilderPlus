/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using fwt
using gfx
using pbpi

class RecordEditor : PbpWindow
{
  Project parentProject
  Record targetRecord
  Record? newRecord

  Change[] changelist := [,]
  Bool modded := false;

  Button saveButton := Button{text="Save"; onAction.add|e|{modded = true; e.window.close}}
  Button closeButton := Button{text="Close"; onAction.add|e|{e.window.close}}
  EdgePane mainWrapper := EdgePane()
  RecordEditPane editPane

  new make(Project parentProject, Record targetRecord, Window? parentWindow:=null) : super(parentWindow)
  {
    this.parentProject = parentProject
    this.targetRecord = targetRecord
    editPane = RecordEditPane(targetRecord, parentProject)
  }

  override Obj? open()
  {

    icon = PBPIcons.pbpIcon16
    title = "Record Editor - ${targetRecord.id}"
    size = Size(550,590)
    mainWrapper.center = ScrollPane{it.content=editPane}
    mainWrapper.bottom = GridPane{numCols=2; halignPane = Halign.right; saveButton,closeButton,}
    content = mainWrapper
    //TODO: make new record here...
    onClose.add |e|
    {
    //TODO: Refactor notifaction...
    /*
      changelist.addAll(ChangeUtil.compareRecs(targetRecord, editPane.getRecs))
      if(modded)
      {
        changelist.each |change|
        {
          parentProject.changeProc.send(change)
        }
      }
      */
      if(modded)
      { //AUTO SAVE IT!
        FileUtil.createRecFile(parentProject, editPane.getRec)
      }
    }
    super.open()
    return [modded, editPane.getRec]
  }







}
