/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent

const class Task
{
  const Str name
  const Int val
  const List parameters
  const Func job


  new make(|This| f)
  {
    f(this)

  }

  Future run()
  {
    //Run the job concurrently...
    return TaskWorker(this.job).send(parameters)
  }

}

const class TaskWorker : Actor
{
  const Func function
  new make(Func function) : super(ActorPool())
  {
    this.function = function
  }

  override Obj? receive(Obj? msg)
  {
    List parameters := msg
    try
    {
      return function.callList(msg)
    }
    catch(Err e)
    {
      return e
    }
  }
}

const class SyncTaskWorker : Actor
{
  //const Func function
  new make() : super(ActorPool()){}

  override Obj? receive(Obj? msg)
  {
    Func function := msg->get(0)
    List parameters := msg->get(1)
    try
    {
      return function.callList(msg)
    }
    catch(Err e)
    {
      return e
    }
  }
}


