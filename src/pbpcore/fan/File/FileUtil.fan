/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using xml

class FileUtil
{
  static const File projectDirectory := Env.cur.homeDir + `projects/` //TODO: ability to change this?
  static const File templateDir := Env.cur.homeDir+`resources/templates/`
  static const File envTreeDir := Env.cur.homeDir+`resources/trees/`

  static File getTagDir()
  {
    return Env.cur.homeDir+`resources/tags/`
  }

  static File[] getSortedTagFiles()
  {
    files := getTagDir.listFiles.findAll|File f->Bool|
    {
      return f.ext=="taglib"
    }
    def := getDefaultTaglib
    files.sort |File a, File b -> Int|
    {
      if(def != null && b.name == def)
        return 1
      return a.name <=> b.name
    }
    return files
  }

  static Str? getDefaultTaglib()
  {
    f := getTagDir+`tags.props`
    if( ! f.exists ) return null
    try
    {
      props := f.readProps()
      return props["default"]
    }catch(Err e) {}
    return null
  }

  static File getTemplateDir()
  {
    return Env.cur.homeDir+`resources/templates/`
  }

  static File getTagPriorityFile()
  {
    File file := Env.cur.homeDir+`etc/projectBuilder/priorityTag.map`
    if(file.exists)
    {
      return file
    }
    else
    {
      file.create
      file.writeObj([:])
      return file
    }
  }

  static Void newProject(Str projectName)
  {
    //makes the new dir for this
    File pDir := projectDirectory.createDir(projectName)
    pDir.createDir("conns")
    pDir.createDir("trees")
    pDir.createDir("weatherRef")
    pDir.createDir("logs")
    pDir.createDir("indexes")
    pDir.createDir("db").createDir("change")
    pDir.createFile("pw.p").writeObj([:])
    pDir.createFile("config.props")
  }

  static Bool exists(Str projectName)
  {
    return getProjectHomeDir(projectName).exists
  }

  static File getProjectHomeDir(Str projectName)
  {
    return (projectDirectory+(projectName+"/").toUri)
  }


  static File getIndexDir(Str projectName)
  {
    return getProjectHomeDir(projectName)+`indexes/`
  }


  static File getTreeDir(Str projectName)
  {
    return getProjectHomeDir(projectName)+`trees/`
  }

  static File getLogDir(Str projectName)
  {
    return getProjectHomeDir(projectName)+`logs/`
  }

  static File getDbDir(Str projectName)
  {
    return getProjectHomeDir(projectName)+`db/`
  }

  static File getChangeDir(Str projectName)
  {
    return getDbDir(projectName)+`change/`
  }

  static File getConnDir(Str projectName)
  {
    return getProjectHomeDir(projectName)+`conns/`
  }

  static Void createRecFile(Project project, Record rec)
  {
    project.database.save(rec)
  }

  static Void createRecFiles(Project project, Record[] recs)
  {
    project.database.saveRecs(recs)
  }

  static File getTempSiteDir()
  {
    return (getTempProjectHomeDir+`sites/`).create
  }

  static File getWeatherDir(Str projectName)
  {
    return getProjectHomeDir(projectName)+`weatherRef/`
  }

  static File getTempEquipDir()
  {
    return (getTempProjectHomeDir+`equips/`).create
  }

  static File getTempPointDir()
  {
    return (getTempProjectHomeDir+`points/`).create
  }

  static File getTempProjectHomeDir()
  {
    return (Env.cur.homeDir+`etc/projectBuilder/temp/`).create

  }

  static Void cleanTempDir()
  {
    (Env.cur.homeDir+`etc/projectBuilder/temp/`).delete
  }


  static Void createConnFile(File homeDir, Conn conn)
  {
    OutStream recStream := getConnDir(homeDir.basename).createFile(conn.dis+"."+conn->ext).out
    XDoc(conn.toXml).write(recStream)
    recStream.close
  }

  static File? findConnFile(File homeDir, Conn conn)
  {
    return getConnDir(homeDir.basename).listFiles.find |File f->Bool|{return f.basename == conn.dis}
  }


}
