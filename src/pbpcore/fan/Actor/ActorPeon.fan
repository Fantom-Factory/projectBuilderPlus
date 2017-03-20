/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent

const class ActorPeon : Actor
{
  const Configuration config
  const Str:Obj options

  new make(ActorPool pool, |This| f) : super(pool)
  {
    f(this)
  }

  override Obj? receive(Obj? msg)
  {
    //Interval before to avoid any possible errors from invoke
    if(options.containsKey("interval"))
    {
      sendLater(options["interval"],null)
    }
    toreturn := config.invoke(msg, options)

    return toreturn

  }

}
