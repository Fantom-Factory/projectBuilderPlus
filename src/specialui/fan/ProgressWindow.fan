/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpgui
using concurrent

class ProgressWindow
{
  Tasklist tasklist
  ProgressBar pbar
 // Label status
  Table taskTable
  ProgressWindowUpdater worker
  new make(Tasklist tasklist)
  {
    this.tasklist = tasklist
    this.pbar = tasklist.progress.getProgressBar
    //this.status = tasklist.progress.getStatusLabel
    taskTable = Table {model = TaskTableModel(tasklist)}
    worker = ProgressWindowUpdater(taskTable)
  }


  Void open(Window? parent)
  {
     InsetPane contentBox := InsetPane()
     EdgePane contentWrapper := EdgePane()
     GridPane buttonWrapper := GridPane()
     EdgePane bigWrapper := EdgePane()
     Button closeButton := Button{
       text = "Close"
       onAction.add |e|{
         e.window.close
         //need to send tasklist.kill here...
       }
     }
     buttonWrapper = ButtonGrid{
     numCols = 1
     closeButton,
     }
     contentWrapper = EdgePane{
       center = pbar
       bottom = taskTable
     }
     bigWrapper = EdgePane{
       center = contentWrapper
       bottom = buttonWrapper
     }

     contentBox = InsetPane{
       content = bigWrapper
     }

     Window(parent)
     {
       content = contentBox
       onActive.add |e| {
       while(!tasklist.isDone)
       {
         tasklist.updateProgress
         worker.send(["update"])
       }
        tasklist.updateProgress

       }
     }.open
  }


}


internal class TaskTableModel : TableModel
{
  const Str taskname := "Task Name"
  const Str status := "Status"
  const Str result := "Result"
  Task[] rows
  Str[] cols
  Tasklist tasklist
  override Int numRows
  override Int numCols

  new make(Tasklist tasklist)
  {
    this.tasklist = tasklist
    rows = tasklist.getTasks
    cols = [taskname, status, result]
    numRows = rows.size
    numCols = cols.size
  }
  override Str header(Int col)
  {
    return cols[col]
  }
  override Str text(Int col, Int row)
  {
    switch(header(col))
    {
      case taskname:
        return rows[row].name
      case status:
        if(tasklist.progressChart[rows[row]])
        {
          return "Done"
        }
        else
        {
          return "Working"
        }
      case result:
        if(tasklist.taskProgress[rows[row]].get->get.typeof == Err#)
        {
          return "Operation Unsuccessful ${tasklist.taskProgress[rows[row]].get->get->cause}"
        }
        else
        {
          return "Success"
        }
      default:
        return ""
    }
  }

}

const class ProgressWindowUpdater : Actor
{
  const Str tableHandle := Uuid().toStr
 // const Str labelHandle := Uuid().toStr
  const Str update := "update"

  new make(Table table) : super(ActorPool())
  {
    Actor.locals[tableHandle] = table
  }

  override Obj? receive(Obj? msg)
  {
    if(msg->get(0) == "update")
    {
     Desktop.callAsync |->| { updateTable() }
     //Desktop.callAsync |->| { updateLabel(msg->get(1)) }
    }
    return null
  }

  Void updateTable()
  {
    table := Actor.locals[tableHandle] as Table
    if(table != null)
    {
      table.refreshAll
    }
  }
/*
  Void updateLabel(Str msg)
  {
    label := Actor.locals[labelHandle] as Label
    if(label != null)
    {
      label.text = "Running... ${msg}"
    }
  }
  */
}
