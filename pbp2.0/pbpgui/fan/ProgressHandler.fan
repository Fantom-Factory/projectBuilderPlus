/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using concurrent
using pbplogging

** Actor used to pass progress report to ProgressWindow
** And also "Done" message to close the window
const class ProgressHandler : Actor
{
  const Str pbarHandler := Uuid().toStr
  const Str progressMsgHandler := Uuid().toStr
  const AtomicBool done := AtomicBool(false)

  new make(ProgressBar pbar, Label plabel, ActorPool pool) : super(pool)
  {
    Actor.locals[pbarHandler] = pbar
    Actor.locals[progressMsgHandler] = plabel
  }

  override Obj? receive(Obj? msg)
  {
    msgList := msg as Obj?[]
    Desktop.callAsync |->| {
      update(msgList[0], msgList[1], msgList[2])
    }
    return null
  }

  ** Mark as completed and that will close the progress window
  Void completed()
  {
    send([0,0,"Done"])
  }

  Void update(Int progress, Int progressMax, Str progressMessage)
  {
    pbar := Actor.locals[pbarHandler] as ProgressBar
    pmsg := Actor.locals[progressMsgHandler] as Label
    if(pbar!=null)
    {
      pbar.val = progress
      pbar.max = progressMax
    }
    if(pmsg!=null)
    {
      pmsg.text = progressMessage
      if(progressMessage == "Done")
      {
        (pmsg.parent.parent.parent as ProgressWindow).close
        while(done.val!=true)
        {
          done.getAndSet(true)
        }
      }
    }
  }
}
