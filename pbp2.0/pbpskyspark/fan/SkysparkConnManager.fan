/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using gfx
using fwt
using projectBuilder
using pbpgui

class SkysparkConnManager : EdgePane, UiUpdatable
{
  SkysparkConnPool connPool := SkysparkConnPool() { private set }
  private Table connTable := Table()
  private SkysparkConnTableModel connTableModel
  private ToolBar toolbar := ToolBar()

  ProjectBuilder pbp { private set }

  new make(ProjectBuilder pbp)
  {
    this.pbp = pbp

    toolbar.addCommand(AddConnCommand(this,pbp))
    toolbar.addCommand(DeleteConnCommand(this,pbp))
    toolbar.addCommand(EditConnCommand(this,pbp))
    toolbar.addCommand(UploadProjectCommand(this,pbp))
    toolbar.addCommand(SyncSkysparkCommand(this,pbp))

    connTable.model = connTableModel = SkysparkConnTableModel(this)

    top = toolbar
    center = connTable
    right = Button(AddToProjectCommand(this, pbp))
  }
  
  override Void updateUi(Obj? obj := null)
  {
    connTableModel.update
    connTable.refreshAll
  }

  Void refreshAll()
  {
    connTable.refreshAll
  }

  Void update()
  {
    connTableModel.update
  }

  SkysparkConn[] getSelected()
  {
    return connTableModel.getRows(connTable.selected)
  }
}
