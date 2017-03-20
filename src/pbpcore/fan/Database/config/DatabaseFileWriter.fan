/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using pbplogging

const class DatabaseFileWriterConfig : Configuration
{
  override Obj? invoke(Obj? msg, Str:Obj? options := [:])
  {
    File file := options["destination"]
    //TODO:
    try
    {
      File fileold := file.parent.createFile(file.name+".old")
      file.copyTo(fileold,["overwrite":true])
    }
    catch(Err e)
    {
      Logger.log.err("invoke error", e)
    }
    file.writeObj(msg, ["skipErrors":true])
    return file
  }
}
