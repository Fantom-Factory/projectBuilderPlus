/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////



const class RecordSerializerConfig : Configuration
{
  override Obj? invoke(Obj? msg, Str:Obj? options := [:])
  {
    Record rec := msg
    FileUtil.createRecFile(options["homeDir"], rec)
    /*
    if(options["collector"] != null)
    {
      options["collector"]->send(newfile, options)
    }
    */
    return null
  }
}
