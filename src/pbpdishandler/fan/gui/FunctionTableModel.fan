/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using projectBuilder
using pbpcore
using concurrent
using pbpgui

class FunctionTableModel : TableModel
{
  private List rows
  FunctionSortModel functionSortModel { private set }
  Str[] cols := ["Name"]
  File folder { private set }

  private ProjectBuilder projectBuilder

  new make(File folder, ProjectBuilder projectBuilder)
  {
    this.projectBuilder = projectBuilder
    this.folder = folder
    this.functionSortModel = FunctionSortModel(folder)
    this.functionSortModel.load
    this.functionSortModel.save
    this.rows = this.getFunctionList
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
    rowInfo := rows[row] as List

    if (col == 0) {
      return (rowInfo.get(0) as File).basename
    }

    colInfo := rowInfo.get(col)
    return colInfo ? colInfo.toStr : ""
  }

  override Str header(Int col)
  {
    return cols[col]
  }

  List getFile(Int row)
  {
    return rows[row]
  }

  Int getFileIndex(List selected)
  {
    return rows.index(selected)
  }

  Void update()
  {
    functionSortModel.load
    //rows = functionSortModel.getFunctionList
    rows = getFunctionList
  }

  DisFunc[] getRows(Int[] selected)
  {
    DisFunc[] toreturn := [,]
    selected.each |select|
    {
      row := rows[select] as List
      toreturn.push((row[0] as File).readObj)
    }

    toreturn.each |disFunc|
    {
        disFunc.applies.each |disApply|
        {
            if (disApply is DisApplyTag) (disApply as DisApplyTag).projectBuilder = projectBuilder
        }
    }

    return toreturn
  }

  List getFunctionList() {
    rowList := [,]
    rows := this.functionSortModel.getFunctionList
    projectConfigProps := projectBuilder.currentProject.projectConfigProps
    navNameFunctions := projectConfigProps.get("makeNavNameFunction")
    if (navNameFunctions != null) {
      if (!this.cols.contains("NavName Function")) {
        this.cols.add("NavName Function")
      }
    }
    
    rows.each |row| {
      isNavNameFunction := false
      if (navNameFunctions != null) {
        isNavNameFunction = navNameFunctions.contains(row.pathStr)
      }
      rowList.add([row, isNavNameFunction])
    }
    
    return rowList
  }
}
