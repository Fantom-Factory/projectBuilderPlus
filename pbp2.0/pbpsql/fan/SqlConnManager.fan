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
using pbpgui
using projectBuilder

class SqlConnManager
{
  Log log := Log.get("pbpsql")
  ProjectBuilder pbp

  new make(ProjectBuilder pbp)
  {
    this.pbp = pbp
  }
  **
  ** Build and return GUI view, Tree: (ToolBar,Tree)
  **
  Widget getGuiView(Watcher projectChangeWatcher)
  {

    SqlPool sqlPool := SqlPool.fromProject(pbp.currentProject)

    SqlGuiTable sqlTable := SqlGuiTable(pbp){
         model=SqlConnTableModel(sqlPool)
         onAction.add |e|
         {
          SqlConnTableModel sqlModel := (e.widget as SqlGuiTable).model
          SqlDBEditor.open(e.window,sqlModel.getConn((e.widget as SqlGuiTable).selected), pbp)
         }
       }

    UiUpdater(sqlTable, projectChangeWatcher).send(null)

    Button addConn := Button{image=PBPIcons.sqlAdd24
        onAction.add |e|{
          if(pbp.currentProject != null)
          {
            List creds := SqlLoginPrompt().open(e.window)
            if(creds[0] != true)
            {
              log.info("Sql Connection Added")
              (sqlTable.model as SqlConnTableModel).sqlPool.newSqlConn(creds[1].toStr,creds[2].toStr,creds[3].toStr,creds[4].toStr)
            }

            if((sqlTable.model as SqlConnTableModel).sqlPool.connPool.peek!=null){
               (sqlTable.model as SqlConnTableModel).sqlPool.connPool.peek.save(pbp.currentProject.name)
              }

            (sqlTable.model as SqlConnTableModel).update((sqlTable.model as SqlConnTableModel).sqlPool)
            sqlTable.refreshAll
          }
          else
          {
            Dialog.openInfo(e.window,"No project selected, please select a project.")
          }
        }
    }
    Button deleteConn := Button{image=PBPIcons.sqlRemove24
        onAction.add |e|{
            sqlModel := sqlTable.model as SqlConnTableModel
            sqlModel.getConn(sqlTable.selected).delete(pbp.currentProject.name)
            if(sqlModel.sqlPool.removeSqlConn(sqlModel.getConn(sqlTable.selected)) == true)
            {
               log.info("Sql Connection Removed")
            }
            (sqlTable.model as SqlConnTableModel).update((sqlTable.model as SqlConnTableModel).sqlPool)
            sqlTable.refreshAll
        }
    }
    Button editConn := Button{image=PBPIcons.sqlChange24
        onAction.add |e|{
            SqlConnWrapper connWrapper := (sqlTable.model as SqlConnTableModel).getConn(sqlTable.selected)
            connWrapper.delete(pbp.currentProject.name)
            SqlServer server := connWrapper.server
            List creds := SqlLoginPrompt(connWrapper.getDis,server.host,server.user,server.pass).open(e.window)
            connWrapper.dis = creds[1]
            connWrapper.server = SqlServer{
               it.host = creds[2]
               it.user = creds[3]
               it.pass = creds[4]
               children = [,]
               }
             connWrapper.save(pbp.currentProject.name)
             (sqlTable.model as SqlConnTableModel).update((sqlTable.model as SqlConnTableModel).sqlPool)
            sqlTable.refreshAll
            return
        }
    }
    ToolBar toolBar := ToolBar{
        addConn,
        deleteConn,
        editConn,
        }
    EdgePane wrapper := EdgePane{
        top = toolBar;
        center = InsetPane(1,1,1,1){
            content = sqlTable;
        }
    }
    return wrapper
  }
}

class SqlGuiTable : Table, UiUpdatable
{
  ProjectBuilder pbp

  new make(ProjectBuilder pbp, |This| f):super(f)
  {
    this.pbp = pbp
  }

  override Void updateUi(Obj? params := null)
  {
      SqlPool sqlPool := SqlPool.fromProject(pbp.currentProject)
      (model as SqlConnTableModel).update(sqlPool)
      refreshAll
  }
}

