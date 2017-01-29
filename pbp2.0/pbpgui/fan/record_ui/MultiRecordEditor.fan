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
using haystack
using concurrent

class MultiRecordEditor : PbpWindow
{
  Project parentProject
  Record[] targetRecords
  Tag[] combinedData
  Record? newRecord

  Change[] changelist := [,]
  Bool modded := false;

  Button saveButton := Button{
    text="Save";
    onAction.add |e| {
      modded = true;
      e.window.close
    }
  }
  Button closeButton := Button{
    text="Close"
    onAction.add |e| {
      e.window.close
    }
  }
  EdgePane mainWrapper := EdgePane()
  RecordEditPane editPane

  new make(Project parentProject, Record[] targetRecords, Window? parentWindow:=null) : super(parentWindow)
  {
    this.parentProject = parentProject
    this.targetRecords = targetRecords
    combinedData = RecordFactory.getCombinedData(targetRecords)
    Record proxyRecord := Record{
      data = combinedData
    }
    editPane = RecordEditPane(proxyRecord, parentProject)
  }

  override Obj? open()
  {

    icon = PBPIcons.pbpIcon16
    title = "Record Editor - Multiple Records"
    size = Size(550,590)
    mainWrapper.center = ScrollPane{it.content=editPane}
    mainWrapper.bottom = GridPane{
      numCols=2;
      halignPane=Halign.right;
      saveButton,
      closeButton,
    }
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
       Record modelRecord := editPane.getRec
       Tag[] tagsToEdit := modelRecord.data.findAll |tag -> Bool| {
          return tag.name != "id" && tag.name != "dis" && (tag.val != null && tag.val != "" && tag.val != Ref.nullRef)
        } //TODO: Refactor
       Tag[] tagsToRemove := [,]
       combinedData.each |tag|
       {
         if(!modelRecord.data.contains(tag))
         {
           tagsToRemove.push(tag)
         }
       }

       ActorPool newPool := ActorPool()
       ProgressWindow pwindow := ProgressWindow(e.window, newPool)
       ActorPeon(newPool){
         config=RecordUpdaterConfig()
         options=["phandler": pwindow.phandler]
       }.send(Unsafe([targetRecords, tagsToEdit, tagsToRemove, parentProject]))
       pwindow.open()
       newPool.stop()
       newPool.join()
      }
    }
    super.open()
    return [modded, editPane.getRec]
   }
}

const class RecordUpdaterConfig : Configuration {

  override Obj? invoke(Obj? msg, Str:Obj? options := [:]) {
    Obj[] params := ((Unsafe)msg).val
    Record[] recs := params[0]
    Tag[] tagsToEdit := params[1]
    Tag[] tagsToRemove := params[2]
    Project parentProject := params[3]
    totalSize := recs.size
    Actor phandler := options["phandler"]
    recs.each |rec, idx|
    {
      phandler.send([idx+1, totalSize, "${idx+1} / ${totalSize}  Records Processed"])

      if (idx == totalSize - 1) {
        phandler.send([idx+1, totalSize, "Done"])
      }

      Record newRec := rec
      
      tagsToEdit.each |tag|
      {
        newRec = newRec.set(tag)
      }

      tagsToRemove.each |tag|
      {
        newRec = newRec.remove(tag.name)
      }

      parentProject.database.save(newRec)
    }
    return null
  }

}
