/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////



//This class is responsible for cleaning the lib, and then installing the intended version...
using concurrent

class Installer
{
  File installDirectory

  new make(RepoEnv env)
  {
   this.installDirectory = env.installDir
  }
/*
  public Void install(Program program)
  {
       Uri file := RepEnv.program.fileUri
       Uri installDirectory := installDirectory.uri
       Str filename := manager.filename
       Str ext := manager.ext
       //Save function here?
       //TODO: rethink this?
       Env.cur.addShutdownHook |->|
       {
         File? oldfile := File(installDirectory).listFiles.find | File f -> Bool | { return f.basename == filename }
         if(Env.cur.os ==  "win32")
         {
           Process restart := Process(["fan.exe",filename], Env.cur.homeDir+`bin/`) //I think the fact that we're going to use fan.exe is a safe assumption
           restart.run
         }
         else
         {
           Process restart := Process(["fan",filename], Env.cur.homeDir)
           restart.run
         }
       }
  }
*/
  public Void uninstall(File f)
  {
      f.delete
  }

  }


