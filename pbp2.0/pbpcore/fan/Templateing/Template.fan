/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbplogging

@Serializable
class Template
{
  Str name
  TemplateTree templateTree
  Str category := "Common"
  Str templateClass := ""

  new make(|This| f)
  {
    f(this)
  }

  Void save(File dir)
  {
    File f := dir.createFile(name+".template")
    try
    {
        f.out.writeObj(this, ["indent":2]).close
    }
    catch(Err e)
    {
      //TODO: Error Log Here
      Logger.log.err("Saving template failed $f", e)
    }
  }
}
