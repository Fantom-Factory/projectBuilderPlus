/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent

const class CollectorConfig : Configuration
{
  const Str id := Uuid().toStr
  override Obj? invoke(Obj? msg, Str:Obj? options := [:])
  {
    AtomicRef? collection := options["collection"]
    List oldlist := collection.val
    List newlist := oldlist.rw.push(msg)
    collection.getAndSet(newlist.toImmutable)
    return newlist
  }
}
