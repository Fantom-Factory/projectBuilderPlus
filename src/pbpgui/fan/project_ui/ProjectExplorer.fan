/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore

class ProjectExplorer : EdgePane
{
  private ToolBar projectToolbar
  private Table projectTable
  private ProjTableModel projectTableModel
  private Bool useDisMacro
  
  new make(File projectDir, PbpListener pbpListener) : super()
  {
    projectCommands := ProjectCommands(pbpListener)
    this.projectToolbar = projectCommands.getToolbar
    
    this.projectTable = Table() { it.multi = true }
    this.projectTable.model = this.projectTableModel = ProjTableModel(projectDir)
    
    this.center = projectTable
    this.top = projectToolbar
    
    this.addOnTableSelectHandler |Event e| {
      selectedProjects := getSelected()
      if (selectedProjects.size > 0) {
        configFile := File("${selectedProjects.first}/config.props".toUri)
        useDisMacro := configFile.readProps().get("useDisMacro", "false").toBool
        this.useDisMacro = useDisMacro
        projectCommands.notifyToolbar(["useDisMacro": useDisMacro])
      }
    }
  }
  
  Void update()
  {
    projectTableModel.update
  }
  
  Void refreshAll()
  {
    projectTable.refreshAll
  }
  
  File[] getSelected()
  {
    return projectTableModel.getRows(projectTable.selected)
  }
  
  Void addOnTableSelectHandler(|Event| f)
  {
    projectTable.onSelect.add(f)
  }
}
