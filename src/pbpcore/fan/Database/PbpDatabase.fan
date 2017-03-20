/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using haystack
using pbplogging

**
**  Flat-Database System, key/value style. (Let the RecordTree system handle the relationship stuff)
**  TODO: Must refactor this in future to scale, this should be suffecient for our target market
class PbpDatabase
{
  ActorPeon fileWriter
  ActorPeon? changeHandler
  ActorPool dbActorPool := ActorPool()

  Project project
  Str:Obj? ramDb := [:]
  Bool started := false
  Bool lock := false

  new make(Project project)
  {
    this.project = project
    fileWriter = ActorPeon(dbActorPool)
      {
        config=DatabaseFileWriterConfig()
        options=["destination":project.dbDir+`project.db`]
      }
    if(!(project.changeDir+`${Date.today()}.changes`).exists)
    {
      project.changeDir.createFile("${Date.today()}.changes")
      (project.changeDir+`${Date.today()}.changes`).writeObj([,])
    }
    File destination := (project.changeDir +`${Date.today()}.changes`)
    changeHandler = ActorPeon(dbActorPool)
      {
        config=ChangeHandler()
        options=["destination":destination.uri]
      }
  }

  This startup()
  {
   if(!started)
   {
    if(!(project.dbDir+`project.db`).exists)
      {
        project.dbDir.createFile("project.db").writeObj([:])
      }
    else
      {
        ramDb = (project.dbDir+`project.db`).readObj
      }
    }
    return this
  }

  Void save(Record rec)
  {
    Record? oldRec := null
    if(ramDb[rec.typeof.name] == null)
    {
      ramDb[rec.typeof.name] = [rec.id.toStr:rec]
    }
    else
    {
      ramDb[rec.typeof.name]->set(rec.id.toStr,rec)
    }
    if(ramDb["Record"] == null)
    {
      ramDb["Record"] = [rec.id.toStr:rec]
    }
    else
    {
      oldRec = ramDb["Record"]->get(rec.id.toStr)
      ramDb["Record"]->set(rec.id.toStr,rec)
    }
    fileWriter.send(ramDb.ro)
    if(oldRec!=null)
    {
      Change change := Change{
        id = CID.MOD
        target = oldRec.id
        opts = [oldRec, rec]
      }
      changeHandler.send(change)
    }
    else
    {
      Change change := Change{
        id = CID.ADD
        target = rec.id
        opts = [rec]
        }
        changeHandler.send(change)
      }
    //Need to reindex
    project.indexer.reindex
    return
  }

  Void saveRecs(Record[] recs)
  {
    Change[] changes := Change[,]
    recs.each|rec|
    {
        Record? oldRec := null
        if(ramDb[rec.typeof.name] == null)
        {
          ramDb[rec.typeof.name] = [rec.id.toStr:rec]
        }
        else
        {
          ramDb[rec.typeof.name]->set(rec.id.toStr,rec)
        }
        if(ramDb["Record"] == null)
        {
          ramDb["Record"] = [rec.id.toStr:rec]
        }
        else
        {
          oldRec = ramDb["Record"]->get(rec.id.toStr)
          ramDb["Record"]->set(rec.id.toStr,rec)
        }

        if(oldRec!=null)
        {
          Change change := Change{
            id = CID.MOD
            target = oldRec.id
            opts = [oldRec, rec]
          }
          changes.add(change)
        }
        else
        {
          Change change := Change{
            id = CID.ADD
            target = rec.id
            opts = [rec]
            }
            changes.add(change)
        }
    }

    // commit ramDb to disk
    fileWriter.send(ramDb.ro)

    // commit all changes to disk
    changeHandler.send(changes)

    //Need to reindex
    project.indexer.reindex
    return
  }

  Void removeRec(Record rec)
  {
    ramDb[rec.typeof.name]->remove(rec.id.toStr)
    Record oldrec := ramDb["Record"]->remove(rec.id.toStr)
    fileWriter.send(ramDb.ro)
      //TODO: send change with REM id
      Change change := Change{
        id = CID.REMOVE
        target = rec.id
        opts = [rec]
        }
        changeHandler.send(change)
     //Need to reindex
    project.indexer.reindex
    return
  }

  Record? getById(Str id)
  {
    return ramDb["Record"]->get(id)
  }

  Map? getClassMap(Type type)
  {
    if(!ramDb.containsKey(type.name)){ramDb[type.name]=[:]}
    return ramDb[type.name]
  }

  DatabaseThread getThreadSafe(Int limit, Actor? phandler, ActorPool pool)
  {
    DatabaseThread dbthread := DatabaseThread(pool)
    {
      it.fileWriter = ActorPeon(pool)
      {
        config=DatabaseFileWriterConfig()
        options=["destination":project.dbDir+`project.db`]
      }
      it.ramDb = AtomicRef(this.ramDb.toImmutable)
      it.limit = limit
      it.phandler = phandler
    }
    project.dbDir.createFile("lock.db").writeObj(ramDb)
    this.fileWriter = ActorPeon(dbActorPool)
      {
        config=DatabaseFileWriterConfig()
        options=["destination":project.dbDir+`lock.db`]
      }
    lock = true //SET LOCK SO COMMITS DON'T HAPPEN SIMULTANEOUSLY
    return dbthread
  }

  DatabaseThread getSyncThreadSafe(Int limit, Actor? phandler, ActorPool pool)
  {
    project.dbDir.createFile("sync.db").writeObj(ramDb)
    project.dbDir.createFile("lock.db").writeObj(ramDb)
    DatabaseThread dbthread := DatabaseThread(pool)
    {
      it.fileWriter = ActorPeon(pool)
      {
        config=DatabaseFileWriterConfig()
        options=["destination":project.dbDir+`sync.db`]
      }
      it.ramDb = AtomicRef(this.ramDb.toImmutable)
      it.limit = limit
      it.phandler = phandler
    }
    lock = true //SET LOCK SO COMMITS DON'T HAPPEN SIMULTANEOUSLY
    return dbthread
  }

  Void unlock()
  {
    lock = false
    //Merge lock.db and project.db
    Map procDb  := (project.dbDir+`project.db`).readObj
    Map lockDb  := (project.dbDir+`lock.db`).readObj
    Map? syncDb := null
    if((project.dbDir+`sync.db`).exists)
    {
      syncDb = (project.dbDir+`sync.db`).readObj
    }
    if(syncDb==null)
    {
    Change change := Change{
      id=CID.BIGEDIT
      target = Ref.nullRef
      opts = [lockDb]
      }
      changeHandler.send(change)
    procDb.each |v,k|{
      //First layer is the archive directory so we have to check that both have em..
      if(!lockDb.containsKey(k))
      {
        lockDb.add(k,v)
      }
      else
      {
        Map brother := lockDb[k]
        Map lilbro := v
        lilbro.each |rec, id|
        {
          brother.set(id, rec)
        }
      }
    }
    ramDb = lockDb
    }
    else
    {
     Logger.log.debug("Taking from Sync")
     Change change := Change{
      id=CID.BIGEDIT
      target = Ref.nullRef
      opts = [procDb]
      }
      changeHandler.send(change)
     ramDb = syncDb
     (project.dbDir+`sync.db`).delete
    }

    this.fileWriter = ActorPeon(dbActorPool)
      {
        config=DatabaseFileWriterConfig()
        options=["destination":project.dbDir+`project.db`]
      }
    fileWriter.send(ramDb.ro)
    (project.dbDir+`lock.db`).delete
    //Need to reindex
    project.indexer.reindex
  }

}
