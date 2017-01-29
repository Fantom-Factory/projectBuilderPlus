/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using fwt
using gfx

class Progress
{
  ProgressBar pbar
  ProgressUpdateActor worker
  Tasklist tasklist

   new make(Tasklist tasklist)
  {
    this.tasklist = tasklist
    pbar = ProgressBar()
    worker = ProgressUpdateActor(pbar)
  }

  Void updateProgress()
  {
    worker.send(["update",tasklist.getProgress()])
  }

  ProgressBar getProgressBar()
  {
    return pbar
  }
}

const class ProgressUpdateActor : Actor
{
const Str pbarHandler := Uuid().toStr
const Str updateMsg := "update"

new make (Obj? pbar) : super(ActorPool())
{
  Actor.locals[pbarHandler] = pbar
}
override Obj? receive(Obj? msg)
{
  Str cmd := msg->get(0)
  Int newVal := msg->get(1)
  if(cmd == updateMsg)
  {
    Desktop.callAsync |->| {updateProgress(newVal)}
  }
  return null
}

Void updateProgress(Int newVal)
{
  pbar := Actor.locals[pbarHandler] as ProgressBar
  if(pbar != null)
  {
    pbar.val = newVal
    pbar.repaint
  }
}

}
