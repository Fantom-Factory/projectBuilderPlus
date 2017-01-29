/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using spui
using pbplogging

class SqlConsole : ConsoleManager
{
  override Str name := "Sql Session"
  override File sessionDirectory := Env.cur.homeDir + `etc/console/`
  override List options := [,]
  override Opt opt

  override Func job := |SqlConnWrapperActor actor, List l->Void|
  {
    actor.send(l)
  }

  const Str queryIns := "query"
  SqlConnWrapperActor worker

  new make(SqlConnWrapper conn)
  {  //instruction,server,statment
    if(sessionDirectory.listDirs.find |File f ->Bool| {return f.basename == "" + conn.server.user+"@"+conn.getDis} == null)
    {
      sessionDirectory.createDir("" + conn.server.user+"@"+conn.getDis)
      sessionDirectory = File(sessionDirectory.uri + (conn.server.user+"@"+conn.getDis+"/").toUri)
    }
    else
    {
      sessionDirectory = File(sessionDirectory.uri + (conn.server.user+"@"+conn.getDis+"/").toUri)
    }
    worker = conn.worker
    options.addAll([queryIns, conn.server])
    opt = SqlOpt{opts=[conn.targetDbName]}
  }

  override Void process(List parameters)
  {
    //echo(parameters.toStr)
    job.callList([worker ,[,].addAll(options).addAll(parameters)])
  }

  Console getConsole()
  {
    return(Console(this))
  }
}
