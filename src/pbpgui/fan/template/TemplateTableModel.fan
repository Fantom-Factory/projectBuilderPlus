/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore

class TemplateTableModel : AbstractTemplateTableModel
{
  new make()
  {
    rows = templateDir.listFiles.findAll|File f->Bool| {return f.ext == "template"}
    cols = ["Name", "Category", "Class"]
  }

  override Void update()
  {
    rows = templateDir.listFiles.findAll|File f->Bool| {return f.ext == "template"}
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
    switch(col)
    {
      case 0:
        return rows[row].basename
      case 1:
        return (rows[row].readObj as Template).category.toStr
      case 2:
        return (rows[row].readObj as Template).templateClass.toStr
      default:
        return ""
    }
  }
}
