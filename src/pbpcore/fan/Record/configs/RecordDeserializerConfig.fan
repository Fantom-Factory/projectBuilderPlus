/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////



const class RecordDeserializerConfig : Configuration
{

  override  Obj? invoke(Obj? msg, Str:Obj? options := [:])
  {
    Record newRec := Record.fromFile(msg)
    if(options["collector"] != null)
    {
      options["collector"]->send(newRec, options)
    }
    return newRec
  }
}
