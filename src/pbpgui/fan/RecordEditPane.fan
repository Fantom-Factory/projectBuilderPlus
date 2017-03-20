/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using pbpcore
using concurrent

class RecordEditPane : GridPane
{
  AtomicBool saveStatus := AtomicBool(false)
  Watcher watcher := Watcher()
  UiUpdater? saveStatusWatcher
  SmartBox[] editables := [,]
  Tag[] tags
  Record rec
  Project? selectedProject

  new make(Record rec, Project? selectedProject := null)
  {
    this.rec = rec
    this.tags = rec.data
    Tag[] priority := [,]
    Tag[] normal := [,]
    TagService tagServ := Service.find(TagService#)
    tags.each |tag| {
      if (tagServ.containsKey(tag.name))
      {
        priority.push(tag)
      }
      else
      {
        normal.push(tag)
      }
    }
    this.selectedProject = selectedProject
    
    priority.addAll(normal).findAll|Tag t->Bool|{return t.name != "id"}.each |tag|
    {
      editables.push(SmartBox(tag, this.selectedProject) {
          deleteButton.onAction.add |e|
          {
            Widget smartbox := e.widget.parent
            smartbox.parent.remove(smartbox)
            editables.remove(smartbox)
            this.relayout
            this.repaint
          }
        })
      editables.peek.addWatcher(saveStatus,watcher)
    }
    numCols = 1;
    addAll(editables)
  }

  Void addTag(Tag tag)
  {
    editables.push(SmartBox(tag, this.selectedProject) {
        deleteButton.onAction.add |e|
        {
          Widget smartbox := e.widget.parent
          smartbox.parent.remove(smartbox)
          editables.remove(smartbox)
          this.relayout
          this.repaint
        }
      })
    editables.peek.addWatcher(saveStatus,watcher)
    add(editables.peek)
    relayout
    parent.relayout
  }

  Void addAllTags(Tag[] tags)
  {
    tags.each |tag|
    {
      addTag(tag)
    }
  }

  Record getRec()
  {
    f := Field.makeSetFunc( [Record#id: rec.id, Record#data: editables.reduce(Tag[,]) |Tag[] newlist,v| {return newlist.push(v.getTag)}.toImmutable])
    return rec.typeof.make([f])
  }

  Void exchangeRec(Record rec)
  {
    if(saveStatus.val == false)
    {
      resp := Dialog.openQuestion(this.window,"You have unsaved changes, would you like to save?",null,Dialog.yesNo)
      if(resp==Dialog.yes)
      {
        if(this.window.typeof == TemplateEditor#)
        {
          TemplateEditor te := this.window
          te.saveCurrentNode
        }
      }
    }
    editables.clear
    removeAll
    this.saveStatus.getAndSet(true)
    this.watcher.set
    this.rec = rec
    this.tags = rec.data
    tags.each |tag|{
      editables.push(SmartBox(tag, this.selectedProject) {
        deleteButton.onAction.add |e|
        {
          Widget smartbox := e.widget.parent
          smartbox.parent.remove(smartbox)
          editables.remove(smartbox)
          this.saveStatus.getAndSet(false)
          this.watcher.set
          this.relayout
          this.repaint
        }
      })
      editables.peek.addWatcher(saveStatus,watcher)
    }
    numCols = 1;
    addAll(editables)
    relayout
  }

  Widget getSaveStatusLabel()
  {
    SaveStatusLabel newSaveStatus := SaveStatusLabel(this.saveStatus)
    saveStatusWatcher = UiUpdater(newSaveStatus, this.watcher)
    saveStatusWatcher.send(null)
    return newSaveStatus
  }

}
