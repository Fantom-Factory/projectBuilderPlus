/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent

**
**
**
const class Watcher
{
  const AtomicBool status := AtomicBool()

  Bool check()
  {
    return status.getAndSet(false)
  }

  Void set()
  {
    status.compareAndSet(false,true)
  }

}
