/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using concurrent
using pbpgui
using pbpcore

**
** ObixConnTable
** Shows a table(list) of Obix connections
**
class ObixConnTable : Table, UiUpdatable
{
  ObixConnManager manager

  new make(ObixConnManager manager, PbpObixConn[] connections) : super()
  {
    this.manager = manager
    model = ObixTableModel(connections)
    onAction.add |e|
    {
      conn := (model as ObixTableModel).getConnection(e.index)
      a := Actor(ActorPool()) |msg|
      {
        try
        {
          PbpObixConn c := (msg as Unsafe).val
          c.connect
        } catch (Err err)
        {
          return err
        }
        return null
      }

      f := a.send(Unsafe(conn))
      while(! f.isDone) {Actor.sleep(100ms)}
        Err? err := f.get as Err
      if(err != null)
        Dialog.openWarn(null, "Obix connection failed", err)
      else
      {
        (manager.tree.model as PbpObixTreeModel).update(conn)
        manager.obixTable.refreshAll
        manager.tree.refreshAll
      }
    }
  }
  
  override Void updateUi(Obj? obj := null)
  {
        manager.clearConnections
        (model as ObixTableModel).clear

        if (manager.pbp.currentProject != null)
        {

            //update via current project's conn folder
            PbpObixConn[] connections := [,]
            PersistConn.loadFromProject(manager.pbp.currentProject.name, "obixConn").each
            {
                connections.add(PbpObixConn(it))
                manager.addConnection(it.name, connections[-1])
            }
            (model as ObixTableModel).update(connections)
        }

        refreshAll
  }

  Void update(PbpObixConn[] connections)
  {
    (model as ObixTableModel).update(connections)
  }
}

class ObixTableModel : TableModel
{
  private PbpObixConn[] connections := [,]
  const Int desktopFontSize := Desktop.sysFont.size.toInt
  override Int numRows := 0
  override Int numCols := 2

  new make(PbpObixConn[] connections) : super()
  {
    update(connections)
  }

  override Image? image(Int col, Int row)
  {
    if(col==1)
    {
      if(connections[row].lobby != null)
      {
        return Image(`fan://icons/x16/check.png`)
      }
    }
    return null
  }

  override Int? prefWidth(Int col)
  {
    Int startingsize := header(col).size* desktopFontSize+10
    Int prefsize := startingsize
    connections.each |row, index|
    {
      Str field := text(col, index)
      if(field.size* desktopFontSize > prefsize)
      {
        prefsize = field.size* desktopFontSize
      }
    }
    return prefsize
  }

  override Str text(Int col, Int row)
  {
    col ==1 ? (connections[row].lobby!=null? "Connected":"Not Connected" ): connections[row].conn.name

  }

  override Str header(Int col)
  {
    return col == 0 ? "Name" : "Status"
  }

  Void update(PbpObixConn[] connections)
  {
    this.connections = connections.sort |a, b| {return a.conn.name.compareIgnoreCase(b.conn.name)}
    numRows = connections.size
  }

  Void clear()
  {
    connections.clear
  }

  PbpObixConn getConnection(Int idx)
  {
    return connections[idx]
  }
}
