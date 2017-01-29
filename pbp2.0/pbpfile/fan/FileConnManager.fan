/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpi
using pbpgui
using projectBuilder

class FileConnManager : UiUpdatable
{
  Log log := Log.get("pbpfile")

  ProjectBuilder pbp

  **
  ** Holds connection objects. For one project at a time.
  **
  PbpFileConn[] conns := PbpFileConn[,]

  **
  ** Constructor
  **
  new make(ProjectBuilder pbp)
  {
    this.pbp = pbp
  }
  
  private Table connTable := Table { 
    model = FileConnTableModel() 

    // On conn select, update filemap list
    onSelect.add |e| {
      if(!connTable.selected.isEmpty)
      {
        c := conns[connTable.selected.first]
        updateTree(c)
      }
    }
  }

  **
  ** Update tree for newly selected conn
  **
  private Void updateTree(PbpFileConn conn)
  {
    (fileMapTree.model as FileMapTreeModel).update(conn.fileMaps)
    fileMapTree.refreshAll

    //TODO: Expand not working
    // Expand all
    fileMapTree.model.roots.each {
      fileMapTree.setExpanded(it, true)
    }
  }

  private Tree fileMapTree := Tree { 
    model = FileMapTreeModel() 
    onPopup.add |e| { 
      e.popup = makePopup(((e.widget as Tree).selected.first as FileMapNode)?.fileMap)
    }
  }

  private Menu makePopup(FileMap? fileMap)
  {
    if (fileMap != null)
    {
      return Menu {
        MenuItem { 
          text = "Link to Point"; 
          onAction.add |e| { 
            w := LinkWindow(e.window, pbp.currentProject, fileMap)
            w.onClose.add {              
              echo(w.selectedPoint)
              if (w.selectedPoint != null)
              {
                //TODO update tree
                conn := this.conns[connTable.selected.first]
                
                newFileMaps := FileMap[,]
                conn.fileMaps.each |map| {
                  if (fileMap.dis == map.dis)
                    newFileMaps.add(FileMap.makeCopy(fileMap) {
                      pointRef = w.selectedPoint.get("id").val
                      pointDis = w.selectedPoint.get("dis").val
                    })
                  else
                    newFileMaps.add(FileMap.makeCopy(map))
                }

                newConn := PbpFileConn.makeCopy(conn, newFileMaps) 
                conn.deleteFromProject(pbp.currentProject.name) // delete old
                newConn.saveToProject(pbp.currentProject.name)  // save new with new values
                updateUi
                //TODO: Update main point table
              }
            }
            w.open
          }
        },
      }
    }
    else
      return Menu()
  }


  **
  ** Build and return GUI view, Tree: (ToolBar,Tree)
  **
  Widget getGuiView()
  {
    Button addConn := Button {
      image = PBPIcons.fileAdd24
      onAction.add |e| {
        if(pbp.currentProject == null)
        {
          Dialog.openWarn(e.window, "No project selected, please select a project.")
          return
        }

        win := ImportWindow(e.window)
        win.onClose.add {
          c := win.getConn
          if (c != null)
          {
            c.saveToProject(pbp.currentProject.name)
            updateUi
          }          
        }
        win.open
      }
    }

    Button deleteConn := Button {
      image = PBPIcons.fileRemove24
      onAction.add |e| {
        if(pbp.currentProject == null)
        {
          Dialog.openWarn(e.window, "No project selected, please select a project.")
          return
        }

        if(connTable.selected.isEmpty)
        {
          Dialog.openWarn(e.window, "No file selected, please select a file.")
          return
        }

        c := this.conns[connTable.selected.first]
        yesNo := Dialog.openQuestion(e.window,
                                 "Are you sure you can to delete connection to file ${c.fileName}?",
                                 Dialog.yesNo)
        if (yesNo == Dialog.yes)
        {
          c.deleteFromProject(pbp.currentProject.name)
          updateUi
        }
      }
    }

    Button editConn := Button {
      image = PBPIcons.fileChange24
      onAction.add |e| {
        if(pbp.currentProject == null)
        {
          Dialog.openWarn(e.window, "No project selected, please select a project.")
          return
        }

        if(connTable.selected.isEmpty)
        {
          Dialog.openWarn(e.window, "No file selected, please select a file.")
          return
        }
        
        conn := this.conns[connTable.selected.first]
        win := ImportWindow.makeForEdit(e.window, conn)

        win.onClose.add {
          c := win.getConn
          if (c != null)
          {
            newConn := PbpFileConn.makeCopy(c)
            c.deleteFromProject(pbp.currentProject.name)   // delete old
            newConn.saveToProject(pbp.currentProject.name) // save new with new values
            updateUi
          }
        }
        win.open
      }
    }

    ToolBar toolBar := ToolBar {
      addConn,
      deleteConn,
      editConn,
    }

    EdgePane wrapper := EdgePane {
      top = toolBar
      center = InsetPane(1,1,1,1) {
        content = SashPane {
          orientation = Orientation.vertical
          connTable,
          fileMapTree
        }
      }
    }
    
    // Register ourself so we can change view when project changes
    UiUpdater(this, pbp.getProjectChangeWatcher).send(null)

    return wrapper
  }

  override Void updateUi(Obj? obj := null)
  {
    if(pbp.currentProject != null)
    {
      this.conns = PbpFileConn.loadFromProject(pbp.currentProject.name)

      (connTable.model as FileConnTableModel).update(this.conns)
      connTable.refreshAll

      if (this.conns.size == 1)
      {
        connTable.selected = [0]
        updateTree(this.conns.first)
      }
      else
      {
        // Reset file maps
        (fileMapTree.model as FileMapTreeModel).update([,])
        fileMapTree.refreshAll
      }
    }
  }
  
}
