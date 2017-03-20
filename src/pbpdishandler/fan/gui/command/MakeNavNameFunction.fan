/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using projectBuilder

class MakeNavNameFunction : Command {

  private ProjectBuilder pbp
  private Table functionTable

  new make(ProjectBuilder pbp, Table functionTable) : super.makeLocale(Pod.of(this), "MakeNavNameFunction") {
    this.pbp = pbp
    this.functionTable = functionTable
  }

  override Void invoked(Event? e) {
    Str:Str projectConfigProps := pbp.currentProject.projectConfigProps
  
    functionTableModel := functionTable.model as FunctionTableModel
    functionNames := functionTable.selected.map |idx->Str| {
      (functionTableModel.getFile(idx).get(0) as File).uri.toStr
    }

    projectConfigProps["makeNavNameFunction"] = functionNames.join(",")
    pbp.currentProject.updateProjectProps(projectConfigProps)
  }
  
}
