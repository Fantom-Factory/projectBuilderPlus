/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent


class Util
{
  static Void getAsyncThread(Func f)
  {
    UtilWorker(f).send(null)
  }

}

const class UtilWorker : Actor
{

const Func f
new make(Func f) : super(ActorPool())
{
  this.f = f
}

override Obj? receive(Obj? msg)
{
  f.call
}

}
