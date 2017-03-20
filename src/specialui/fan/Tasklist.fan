/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using fwt
using gfx

class Tasklist
{
  private Task[] tasks
  Task:Bool progressChart := [:]
  Task:Future taskProgress := [:]
  Int totalVal := 0
  Progress progress

  new make(Task[] tasks := [,])
  {
   this.tasks = tasks
   this.tasks.each |task|
   {
     progressChart.add(task,false)
     totalVal = totalVal + task.val
   }
   progress = Progress(this)
  }

  Void add(Task task)
  {
    tasks.push(task)
    progressChart.add(task,false)
    totalVal = totalVal + task.val
  }

  Void start(Window? parent := null)
  {
    tasks.each |task|
    {
      taskProgress.add(task,task.run())
    }
    ProgressWindow(this).open(parent)
  }

  Future[] response()
  {
    return taskProgress.vals
  }

  Bool isDone()
  {
    Bool done := true
    taskProgress.each |future,task|
    {
      if(!future.isDone)
      {
        done = false
      }
      else if(future.isDone)
      {
        progressChart[task] = true
      }
    }
    return done
  }

  Int getProgress()
  {
    Int progress := 0
    progressChart.findAll |Bool status -> Bool| {return status == true}.keys.each |task|
    {
      progress = progress + task.val
    }
    return ((progress/totalVal)*100).toInt
  }

  Void updateProgress()
  {
    progress.updateProgress
  }

 Task[] getTasks()
 {
   return tasks.ro // return read-only copy...
 }

}
