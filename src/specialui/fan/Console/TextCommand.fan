/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

@Serializable
class TextCommand
{
  Str text
  Str ts
  Str opts := ""
  Response[] children := [,]
  new make(|This| f)
    {
      f(this)
    }

  @Transient
  static TextCommand fromJson(Str:Obj? data)
  {
    return TextCommand
    {
      it.text = data["text"]
      it.ts = data["ts"]
      it.opts = data["opts"]
      it.children = [,]
    }
  }

  override Str toStr()
  {
    return text
  }

  @Transient
  Str toLongStr()
  {
    return "text: $text\nts: $ts\nopts: $opts"
  }
}

