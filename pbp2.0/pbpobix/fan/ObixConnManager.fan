/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpi
using projectBuilder
using pbpcore
using concurrent
using pbpgui
using haystack
using pbpskyspark

**
** ObixConnManager
**
class ObixConnManager
{
  Log log := Log.get("obix")
  private Str:PbpObixConn connections := Str:PbpObixConn[:]

  PbpObixTree tree := PbpObixTree()
  ObixConnTable obixTable

  ProjectBuilder pbp

  new make(ProjectBuilder pbp)
  {
    this.pbp = pbp
    obixTable = ObixConnTable(this, connections.vals)
  }

  Void clearConnections()
  {
    connections.clear
  }

  Void addConnection(Str key, PbpObixConn conn)
  {
    connections[key] = conn
  }

  PbpObixConn[] getConnections()
  {
    return connections.vals
  }

  **
  ** Build and return GUI view, Tree: (ToolBar,Tree)
  **
  Widget getGuiView()
  {
    Button addConn := Button{image=PBPIcons.obixTabAdd24
      onAction.add |e|{
        if(pbp.currentProject == null)
        {
          Dialog.openWarn(null, "No project selected, please select a project.")
          return
        }

        d := ObixLoginPrompt.open(e.window)
        if(d["cancelled"] != "true")
        {
          log.info("Obix Connection Added : "+d["dis"])
          conn := PersistConn.makeNew(
            d["dis"],
            d["pass"],
            [
              "host":d["host"],
              "user":d["user"],
              "record":ObixConnRecord{
                  data=[
                    MarkerTag{name="obixConn"; val="obixConn"},
                    UriTag{name="obixLobby"; val=d["host"].toStr.toUri},
                    StrTag{name="username"; val=d["user"].toStr},
                    StrTag{name="dis"; val=d["dis"].toStr}
                    ]
                }
            ]
          )
          pbpcore::SecureManifest.savePassword(pbp.currentProject.name,conn.params["record"],d["pass"])
          pbp.currentProject.database.save(conn.params["record"])
          connections[d["dis"]] = PbpObixConn(conn)
          connections[d["dis"]].conn.saveToProject(pbp.currentProject.name, "obixConn")
        }
        obixTable.update(connections.vals)
        obixTable.refreshAll
      }
    }
    Button deleteConn := Button{image=PBPIcons.obixTabRemove24
      onAction.add |e|{
        ObixTableModel obixModel := obixTable.model
        if( ! obixTable.selected.isEmpty)
        {
          key := obixModel.getConnection(obixTable.selected.first).conn.name
          connections.remove(key)

          rec := obixModel.getConnection(obixTable.selected.first).conn.params["record"]
          if(rec != null)
            pbpcore::SecureManifest.removePassword(pbp.currentProject.name, rec)
          PersistConn.deleteFromProject(pbp.currentProject.name, key, "obixConn")
          pbp.currentProject.database.removeRec(obixModel.getConnection(obixTable.selected.first).conn.params["record"])
          obixTable.update(connections.vals)
          obixTable.refreshAll
        }
      }
    }
    Button editConn := Button{image=PBPIcons.obixTabEdit24
      onAction.add |e|{
        ObixTableModel obixModel := obixTable.model
        if( ! obixTable.selected.isEmpty)
        {
          //echo("selected: $obixTable.selected.first")
          //echo("conns: $connections.keys")
          //obixModel.connections.each{echo("ModConn: $it.conn.name")}
          key := obixModel.getConnection(obixTable.selected.first).conn.name
          //echo("key: $key")
          PbpObixConn conn := connections[key]
          d := ObixLoginPrompt.open(e.window, ["dis":conn.conn.name, "host":conn.host, "user":conn.user, "pass":conn.conn.plainPassword])
          if(d["cancelled"] != "true")
          {
            connections.remove(conn.conn.name)
            c := PersistConn.makeNew(
            d["dis"],
            d["pass"],
            [
              "host":d["host"],
              "user":d["user"],
              "record":ObixConnRecord{
                  id = conn.conn.params["record"]->id
                  data=[
                    MarkerTag{name="obixConn"; val="obixConn"},
                    UriTag{name="obixLobby"; val=d["host"].toStr.toUri},
                    StrTag{name="username"; val=d["user"].toStr},
                    StrTag{name="dis"; val=d["dis"].toStr}
                    ]
                }
            ])
            connections[d["dis"]] = PbpObixConn(c)
            connections[d["dis"]].conn.saveToProject(pbp.currentProject.name, "obixConn")
          }
          obixTable.update(connections.vals)
          obixTable.refreshAll
        }
      }
    }
    Button importConn := Button{image=PBPIcons.obixImport24
      onAction.add |e|{
        importConn(e)
      }
    }
    ToolBar toolBar := ToolBar{
      addConn,
      deleteConn,
      editConn,
      importConn,
    }
    EdgePane wrapper := EdgePane{
      top = toolBar
      center = SashPane(){
        orientation = Orientation.vertical
        obixTable,
        EdgePane{center=tree;
          right=Button(pbpobix::AddToProjectCommand(this))},
      }
    }
    return wrapper
  }

  ** Import Obix conns from Skyspark
  Void importConn(Event e)
  {
    if(pbp.currentProject == null)
    {
      Dialog.openWarn(null, "No project selected, please select a project.")
      return
    }

    Str[] connNames := [,]
    skysparkConns := pbp.skysparkConns
    combo := Combo {items = skysparkConns}
    result := Dialog(null)
    {
      body = EdgePane
      {
        top = Label{it.text="Pick a conn"};
        center = combo
      }
      commands = Dialog.okCancel
    }.open

    if(result != null)
    {
      skysparkConn := skysparkConns.find {it === combo.selected} as SkysparkConn

      // Now get all obix conns in skyspark for this conn
      newPool := ActorPool()
      ProgressWindow pwindow := ProgressWindow(e.window, newPool)

      Actor(newPool) |Obj? msg -> Obj?|
      {
        try
        {
          Obj[] params := ((Unsafe)msg).val
          skyspark := params[0] as SkysparkConn
          ProjectBuilder pbp := params[1]
          ProgressHandler progress := params[2]
          skyspark.connect
          ConnData[] conns := skyspark.getObixConns
          conns.each |c, index|
          {
            echo("Obix Connection imported : "+c.get("dis"))
            conn := PersistConn.makeNew(
              c.get("dis"),
              "DummyPass",
              [
                "host":c.get("lobby"),
                "user":c.get("user"),
                "record":ObixConnRecord{
                    id = Ref.fromStr(c.get("id").toStr)
                    data=[
                      MarkerTag{name="obixConn"; val="obixConn"},
                      UriTag{name="obixLobby"; val=c.get("lobby").toUri},
                      StrTag{name="username"; val=c.get("user")},
                      StrTag{name="dis"; val=c.get("dis")},
                      RefTag{name="id"; val=Ref.fromStr(c.get("id").toStr)}
                      ]
                  }
              ]
            )
            progress.send([index+1, conns.size+1, ""])
            pbpcore::SecureManifest.savePassword(pbp.currentProject.name,conn.params["record"],"DummyPass")
            pbp.currentProject.database.save(conn.params["record"])
            PbpObixConn(conn).conn.saveToProject(pbp.currentProject.name, "obixConn")
          }
          progress.send([conns.size+1, conns.size+1, "Done"])
        }catch(Err err) {err.trace}
        return null
      }.send(Unsafe([skysparkConn, pbp, pwindow.phandler]))


      pwindow.open
      newPool.stop
      newPool.join
      //Persist Last Upload to enable syncing
      skysparkConn.persistLastUpload()
      obixTable.update(connections.vals)
      obixTable.refreshAll
    }
  }

}

const class ImportObixActor : Actor
{
  new make(ActorPool pool) : super(pool) {}

  override Obj? receive(Obj? msg)
  {
    Obj[] params := ((Unsafe)msg).val
    skyspark := params[0] as SkysparkConn
    ProjectBuilder pbp := params[1]
    skyspark.connect
    ConnData[] conns := skyspark.getObixConns
    conns.each |c|
    {
      echo("Obix Connection imported : "+c.get("dis"))
      conn := PersistConn.makeNew(
        c.get("dis"),
        "DummyPass",
        [
          "host":c.get("lobby"),
          "user":c.get("user"),
          "record":ObixConnRecord{
              data=[
                MarkerTag{name="obixConn"; val="obixConn"},
                UriTag{name="obixLobby"; val=c.get("lobby").toUri},
                StrTag{name="username"; val=c.get("user")},
                StrTag{name="dis"; val=c.get("dis")}
                ]
            }
        ]
      )
      pbpcore::SecureManifest.savePassword(pbp.currentProject.name,conn.params["record"],"DummyPass")
      pbp.currentProject.database.save(conn.params["record"])
      //connections[c.get("dis")] = PbpObixConn(conn)
      PbpObixConn(conn).conn.saveToProject(pbp.currentProject.name, "obixConn")
    }
    return null
  }
}

