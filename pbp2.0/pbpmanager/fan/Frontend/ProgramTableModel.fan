/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx


class ProgramTableModel : TableModel
{
  RepoEnv repoEnv
  File[] rows := [,]
  const Str[] cols := ["Name","Version","Downloaded","Installed"]
  const Int NAME_COL:=0
  const Int VERSION_COL:=1
  const Int DOWNLOADED_COL:=2
  const Int INSTALLED_COL:=3

  new make(RepoEnv repoEnv)
  {

    this.repoEnv = repoEnv
    repoEnv.repoDir.listDirs.each|dir|
    {
      dir.listFiles.each|file|
      {
        rows.push(file)
      }
    }
  }

  File[] getRows(Int[] selected)
  {
    File[] toReturn := [,]
    selected.each |index|
    {
      toReturn.push(rows[index])
    }
    return toReturn
  }

  Void update()
  {
    rows.clear
    repoEnv.repoDir.listDirs.each|dir|
    {
      dir.listFiles.each|file|
      {
        rows.push(file)
      }
    }
  }

  override Int numCols()
  {
    return cols.size
  }

  override Int numRows()
  {
    return rows.size
  }

  override Str header(Int col)
  {
    return cols[col].toStr
  }

  override Str text(Int col, Int row)
  {
    switch(col)
    {
      case NAME_COL:
        return rows[row].basename.split('-')[0]
      case VERSION_COL:
        return rows[row].basename.split('-')[1]
      case DOWNLOADED_COL:
        return rows[row].ext=="baby"?false.toStr:true.toStr
      case INSTALLED_COL:
        return repoEnv.isPodInstalled(rows[row].basename.split('-')[0],rows[row].basename.split('-')[1]).toStr
      default:
        return ""
    }
  }

}
