/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent

const class TagService : Service
{
  private const AtomicRef priorityMap := AtomicRef([:].toImmutable)
  private const File priorityMapFile

  new make(File priorityMapFile)
  {
    this.priorityMapFile = priorityMapFile
  }

  override Void onStart()
  {
    priorityMap.getAndSet(priorityMapFile.readObj.toImmutable)
  }

  override Void onStop()
  {
    priorityMapFile.writeObj(priorityMap.val)
  }

  Void addTagPriority(Tag tag)
  {
    Map newMap := (priorityMap.val as Obj:Obj?).rw.set(tag.name, tag)
    priorityMap.getAndSet(newMap.toImmutable)
  }

  Void removeTagPriority(Tag tag)
  {
    Map newMap := (priorityMap.val as Obj:Obj?).rw
    newMap.remove(tag.name)
    priorityMap.getAndSet(newMap.toImmutable)
  }

  Bool containsKey(Obj key)
  {
    return (priorityMap.val as Obj:Obj?).containsKey(key)
  }

}
