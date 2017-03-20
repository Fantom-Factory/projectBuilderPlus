/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using util
using pbplogging

class Manager
{
  RepoEnv repoEnv
  RepoConn repoConn

  new make(|This| f)
  {
    f(this)
  }

  Void refreshRepo()
  {
    Logger.log.debug("started")
     InStream in := repoConn.requestToRepo(repoConn.repoUrl.toStr+"query?*")
     JsonInStream jstream := JsonInStream(in)
     Str:Obj? data := jstream.readJson
     in.close
     jstream.close
     if(!data.containsKey("pods"))
     {
       return
     }
     Map[] pods := data["pods"]
     pods.each |pod|
     {
         File baby := repoEnv.getPodDir(pod["pod.name"]).createFile(pod["pod.name"].toStr+"-"+pod["pod.version"].toStr+".baby")
         baby.writeObj(pod)
     }
  }

  Void refreshRepoAt(Str podname)
  {
     InStream in := repoConn.requestToRepo(repoConn.repoUrl.toStr+"query?${podname}")
     JsonInStream jstream := JsonInStream(in)
     Str:Obj? data := jstream.readJson
     in.close
     jstream.close
     if(!data.containsKey("pods"))
     {
       return
     }
     Map[] pods := data["pods"]
     pods.each |pod|
     {
       if(!File(repoEnv.getPodDir(pod["pod.name"]).uri+(pod["pod.name"].toStr+"-"+pod["pod.version"].toStr+".pod").toUri).exists)
       {
         File baby := repoEnv.getPodDir(pod["pod.name"]).createFile(pod["pod.name"].toStr+"-"+pod["pod.version"].toStr+".baby")
         baby.writeObj(pod)
       }
     }
  }

//returns null if fail
  File? downloadPod(File targetfile)
  {
    if(targetfile.ext == "pod")
    {
      return targetfile
    } //Case if already downloaded
    if(targetfile.ext == "baby")
    {
      Map data := targetfile.readObj
      InStream podIn := repoConn.getVersion(Program{name=data["pod.name"]; version=Version.fromStr(data["pod.version"])})
      Str path := data["pod.name"].toStr+"-"+data["pod.version"].toStr+".pod"
      try
      {
        File newFile := targetfile.rename(path)
        OutStream newFileOut := newFile.out
        podIn.pipe(newFileOut)
        podIn.close
        newFileOut.close
      }
      catch(Err e)
      {}
      return targetfile
    }
    return null //means something failed
  }

   File? downloadLatestPod(File targetfile)
  {
    if(targetfile.ext == "pod")
    {
      return targetfile
    } //Case if already downloaded
    else
    {
      Version:File versions := [:]
      targetfile.listFiles.findAll |File f->Bool| {return f.ext=="baby"}.each |pod|
      {
        echo(pod)
        versions.add(Version.fromStr(pod.basename.split('-')[1]),pod)
      }
      Version? maxVersion := versions.keys.max
      if(maxVersion==null){return null}
      File latestPod := versions[maxVersion]
      Map data := latestPod.readObj
      InStream podIn := repoConn.getVersion(Program{name=data["pod.name"]; version=Version.fromStr(data["pod.version"])})
      File newFile := targetfile.createFile(data["pod.name"].toStr+"-"+data["pod.version"].toStr+".pod")
      OutStream newFileOut := newFile.out
      podIn.pipe(newFileOut)
      podIn.close
      newFileOut.close
      return newFile
    }
    return null //means something failed
  }

  Void installPod(File targetfile)
  {
    Str podname := targetfile.basename.split('-')[0]
    Str podversion := targetfile.basename.split('-')[1]
    Str filename := repoEnv.installDir.toStr+podname+".pod"
    echo(filename)
    targetfile.copyTo(File(filename.toUri), ["overwrite":true])
  }

  Void installLatestPod(File targetfile)
  {
    Str podname := targetfile.basename.split('-')[0]
    Version[] versions := [,]
    targetfile.parent.listFiles.findAll |File f->Bool| {return f.ext=="pod"}.each |pod|
    {
      versions.push(Version.fromStr(pod.basename.split('-')[1]))
    }
    if(!versions.isEmpty)
    {
      Version maxVersion := versions.max
      installPod(targetfile.parent+(podname+"-"+maxVersion.toStr+".pod").toUri)
    }
  }


  **
  ** Direct Approach
  **
  /*
  Void buildRepoFiles()
  {

  }
  */

}


