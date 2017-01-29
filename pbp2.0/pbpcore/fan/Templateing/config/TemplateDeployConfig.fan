/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using pbplogging

const class TemplateDeployConfig : Configuration
{
  override Obj? invoke(Obj? msg, Str:Obj? options := [:])
  {
     Record newRec := msg
     try
     {
       while(options["dbthread"]->lock->val){}
      if(options["dbthread"]->counter->val->plus(1) == options["totalsize"])
      {
        options["dbthread"]->send([DatabaseThread.SAVE,newRec])
        options["dbthread"]->send([DatabaseThread.CLOSE,null])
      }
      else
      {
        options["dbthread"]->send([DatabaseThread.SAVE,newRec])
      }
     }
     catch(Err e)
     {
       Logger.log.err("Invoke error", e)
     }
     return null
  }
}
