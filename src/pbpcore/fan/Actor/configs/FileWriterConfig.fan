/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent

const class FileWriterConfig : Configuration
{
  override Obj? invoke(Obj? msg, Str:Obj? options := [:])
  {
    File file := options["destination"]
    file.writeObj(msg)
    return file
  }
}
