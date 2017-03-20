/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using pbplogging

const class ChangeHandler : Configuration
{
  **
  **  Recieve a Change, save the change, (TODO: send if off)
  **
  override Obj? invoke(Obj? msg, Str:Obj? options := [:])
  {
    try
    {
     File file := File(options["destination"])
     List changeStack := file.readObj
     // check if we are persisting single change or batch
     change := msg as Change
     if(change != null)
         changeStack.push(change)
     else
     {
         changes := msg as Change[]
         changeStack.addAll(changes)
     }
     file.writeObj(changeStack)
     return null
     }
     catch(Err e)
     {
     Logger.log.err("Change handler error", e)
     return null
     }
  }
}


