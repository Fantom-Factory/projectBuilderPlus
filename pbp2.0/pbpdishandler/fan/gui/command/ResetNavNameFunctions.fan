/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using projectBuilder

class ResetNavNameFunction : Command {

  private ProjectBuilder pbp

  new make(ProjectBuilder pbp) : super.makeLocale(Pod.of(this), "ResetNavNameFunction") {
    this.pbp = pbp
  }

  override Void invoked(Event? e) {
    projectConfigProps := pbp.currentProject.projectConfigProps
    projectConfigProps.remove("makeNavNameFunction")
    pbp.currentProject.updateProjectProps(projectConfigProps)
  }
  
}
