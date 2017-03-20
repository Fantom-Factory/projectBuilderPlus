/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent


const class ChangeProcessor : Actor
{
  const Actor[] observers
  const Log log
  new make(Actor[] observers, Log projectLog): super(ActorPool())
  {
    this.log = projectLog
    this.observers = observers
  }

  override Obj? receive(Obj? msg)
  {
    observers.each |observer|
    {
      observer.send(msg)
    }
    return null
  }

}
