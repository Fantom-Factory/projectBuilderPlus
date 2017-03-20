/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


using concurrent
using haystack

class Project
{
  //File directories..should i set here or have a utility...
  File homeDir
  File weatherDir
  File connDir
  File treeDir
  File indexDir
  File dbDir
  File changeDir
  File? projectFile
  private File? projectConfigFile
  Str:Str? projectConfigProps

  RecordTree[] rectrees := [,]
  RecordTree? displayTree
  RecordIndexer indexer
  PbpDatabase database

  Str name
  Bool mod := false
  ChangeProcessor? changeProc
  private RecordController? recControl

  **
  **  This dataMap contains all records that are currently being worked on. So not all Rec's have to be loaded at once when a project is open.
  **
  const AtomicRef dataMap := AtomicRef([:].toImmutable)

  **
  **  This is the the log for this project..., it's recControl and changeProc have access to it as well...
  **
  const Log projectLog := Log.get("projLog_${this.name}")

  //Tree[] trees := [,]

  new make(Str name, Bool fullstart := true)
  {
    this.name = name

    if (!FileUtil.exists(name)) {
      FileUtil.newProject(name)
    }

    homeDir = FileUtil.getProjectHomeDir(name)
    connDir = FileUtil.getConnDir(name)
    treeDir = FileUtil.getTreeDir(name)
    indexDir = FileUtil.getIndexDir(name)
    weatherDir = FileUtil.getWeatherDir(name)
    changeDir = FileUtil.getChangeDir(name)
    dbDir = FileUtil.getDbDir(name)

    this.projectConfigFile = File("${homeDir}/config.props".toUri)
    this.projectConfigProps = projectConfigFile.readProps()

    database = PbpDatabase(this)
    indexer = RecordIndexer(this)

    if(fullstart)
    {
    recControl = RecordController(dataMap, projectLog)
    changeProc = ChangeProcessor([recControl], projectLog)

    treeDir.listFiles.findAll |File f->Bool| {return f.ext == "tree"}.each |treefile|
      {
        RecordTree rectree := RecordTree.fromFile(treefile, this)
        if(rectree.treename != "Display_Name")
        {
          rectrees.push(rectree)
        }
        else
        {
          displayTree = rectree
        }
      }

      database.startup
    }
  }

 **//TODO: Add try/catch ?
 ** Add a record to this project's registry.
 **
  Void add(Record rec)
  {
    FileUtil.createRecFile(this,rec)
    changeProc.send(Change{
      id=CID.ADD
      target=rec.id
      opts=[rec]
      }
      )
   //  while(get(rec.id)==null){}
     return
  }

 **//TODO: Add try/catch ?
 ** Get a record with a Ref.. (from memory)
 **
  Record? get(Ref target)
  {
    Future result := recControl.send(Change{
      id=CID.GET
      it.target=target
      opts=[,]
      }
      )
      while(result.isDone){}
      return result.get
  }

  **//TODO: Add try/catch ?
  ** Save Rec's in memory...
  **
  Void save()
  {
    dataMap.val->vals->each |rec|
    {
      FileUtil.createRecFile(this,rec)
    }
  }

  RecordIndexer getIndex() {
    return indexer = RecordIndexer(this)
  }
  override Str toStr()
  {
    return this.name
  }

  Void updateProjectProps(Str:Str props) {
    this.projectConfigFile.writeProps(props)
    this.projectConfigProps = props
  }

}
