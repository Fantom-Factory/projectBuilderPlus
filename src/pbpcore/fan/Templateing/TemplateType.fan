/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbplogging

@Serializable
const class TemplateType : Logging
{
  const Str name
  const TemplateLayer[] layers := [,] //TODO: These are the rules that define this type!

  new make(|This| f)
  {
    f(this)
  }

  static TemplateType fromFile(File f)
  {
    InStream fin := f.in
    TemplateType ttype := fin.readObj
    fin.close
    return ttype
  }

  @Transient
  Void save(File dir)
  {
     File f := dir.createFile(name+".ttype")
     OutStream out := f.out
    try
    {
      out.writeObj(this)
    }
    catch(Err e)
    {
      err("Tempate save error", e)
    }
    finally
    {
      out.close
    }
  }
}

