/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpi
using pbpcore

**
**  To select trees from the local environment
**
class TreeManagerWindow : PbpWindow
{
  Table treeTable

  new make(Window? parent, PbpListener pbp, TableModel model,TabPane tabs) : super(parent)
  {
    treeTable = Table{it.model = model}
    title = "Tree Manager"
    size = Size(577, 389)
    content = SashPane
    {
      EdgePane{
          center=treeTable
        },
        GridPane{
          Button(AddTreeFunction(pbp, treeTable)),
          Button(RemoveTreeFunction(pbp, treeTable)),
          Button(NewTreeFunction(pbp, treeTable)),
          Button(EditTreeFunction(pbp, treeTable)),
          Button(DeleteTreeFunction(pbp, treeTable)),
        },
    }
  }
}


class TreeSelectorTableModel : TableModel
{
  File[] rows := [,]
  Str[] cols := ["Name","Type"]
  File treeDir
  Str ext := "tree"
  new make(File treeDir)
  {
    this.treeDir = treeDir
    rows = treeDir.listFiles.findAll|File f->Bool| {return f.ext == this.ext}
  }

  override Int numCols()
  {
    return cols.size
  }

  override Int numRows()
  {
    return rows.size
  }

  override Str text(Int col, Int row)
  {
    switch(col)
    {
      case 0:
        return rows[row].basename
      case 1:
        return rows[row].ext
      default:
        return ""
    }
  }

  override Str header(Int col)
  {
    return cols[col]
  }

  Void update()
  {
    rows = treeDir.listFiles.findAll|File f->Bool| {return f.ext == this.ext}
  }

  File getRow(Int[] selected)
  {
    return rows[selected.first]
  }


}


