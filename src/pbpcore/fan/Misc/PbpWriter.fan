/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using haystack
using concurrent

class PbpWriter
{
  Project project
  new make(Project project)
  {
    this.project = project
  }

  Void compile(Dict[] dicts)
  {
    Grid grid := Etc.makeDictsGrid(["commit":"add"], dicts)
    if((project.homeDir+`${project.name}.pbp`).exists)
    {
        File pbpfile := (project.homeDir+`${project.name}.pbp`)
    //1 copy contents of zip to historical data for later use (sync)
        File tempDir := FileUtil.getConnDir(project.name).createDir("${Uuid().toStr}temp")
        tempDir.deleteOnExit
        pbpin := pbpfile.in
        zipRead := Zip.read(pbpin)
        File? entry
        Str:File files := [:]
        while((entry = zipRead.readNext()) != null)
        {
          File newfile := tempDir.createFile(entry.basename)
          OutStream newfileout := newfile.out
          entry.in.pipe(newfileout)
          newfileout.close
          files.add(entry.uri.toStr, newfile)
        }
        zipRead.close
        pbpin.close

        pbpout := pbpfile.out
        zipWrite := Zip.write(pbpout)
        files.each |v,k|
        {
          if(k.toUri != `/project.upload` && k.toUri!= `/current.db`)
          {
            OutStream newout := zipWrite.writeNext(k.toUri)
            v.in.pipe(newout)
            newout.close
          }
        }
        out := zipWrite.writeNext(`project.upload`)
        ZincWriter(out).writeGrid(grid)
        out.close
        out2 := zipWrite.writeNext(`current.db`)
        out2.writeObj(project.database.ramDb)
        out2.close
        zipWrite.close
        pbpout.close
    }
    else
    {
    File pbpfile := project.homeDir.createFile(project.name+".pbp")
    OutStream pbpfileout := pbpfile.out
    zip := Zip.write(pbpfileout)
    out := zip.writeNext(`project.upload`)
    ZincWriter(out).writeGrid(grid)
    out.close
    out2 := zip.writeNext(`current.db`)
    out2.writeObj(project.database.ramDb)
    out2.close
    zip.close
    pbpfileout.close
    }
  }
}

const class MakeGridFromRecsConfig : Configuration
{
  override Obj? invoke(Obj? msg, Str:Obj? options := [:])
  {
    Record[] recs := msg
    Dict[] dicts := [,]
    Int totalSize := recs.size
    Actor? phandler := options["phandler"]
    recs.each |rec, index| {
      if (options["useDisMacro"] && (rec.typeof == Equip# || rec.typeof == Point#)) {
        rec = rec.remove("dis")
      }
      
      dicts.push(rec.getDict())

      if (phandler != null) {
        phandler.send([index+1, totalSize, "${index+1} / ${totalSize}  Records Processed"])
      }
    }
    
    if (phandler != null) {
      phandler.send([totalSize, totalSize, "Done"])
    }

    return dicts.toImmutable
  }
}
