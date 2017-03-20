/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore

class TemplateTypeTableModel : AbstractTemplateTableModel
{
  new make()
  {
    rows = templateDir.listFiles.findAll|File f->Bool| {return f.ext == "ttype"}
    cols = ["Name"]
  }

  override Void update()
  {
    rows = templateDir.listFiles.findAll|File f->Bool| {return f.ext == "ttype"}
  }

  override File[] getRows(Int[] selected)
  {
    toreturn := [,]
    selected.each |index|
    {
      toreturn.push(rows[index])
    }
    return toreturn
  }

  override Str text(Int col, Int row)
  {
    return rows[row].basename
  }
}
