/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using xml
using web
using fwt
using obix
using pbpgui
using concurrent

**
** Map Skyspark(Obix) items into proper Niagara fields
** ObixHis -> BooleanCovRef
**
class ObixToNiagara
{
  ActorPool pool
  Window win

  new make(Event e)
  {
    pool = ActorPool()
    win = e.window
  }

  Void doMapping(Project prj, PbpObixConn conn)
  {
    ProgressWindow progress := ProgressWindow(win, pool)
    ObixToNiagaraActor(pool).send(Unsafe([prj, conn, progress.phandler]))
    progress.open
    pool.stop
    pool.join
  }
}

const class ObixToNiagaraActor : Actor
{
  new make(ActorPool pool) : super(pool) {}

  override Obj? receive(Obj? msg)
  {
    try
    {
      Obj[] params := ((Unsafe)msg).val
      Project prj := params[0]
      PbpObixConn conn := params[1]
      ProgressHandler progress := params[2]
      points := getHistoryPoints(conn, progress)
      if(points == null) return null

      size := prj.database.ramDb.size + 1
      cpt := 0
      prj.database.ramDb.each |v, k|
      {
        // yuk
        obj := v as Obj:Obj?
        obj.vals.each
        {
          if(it.typeof.fits(Record#))
          {
            Record? rec := it as Record
            his := rec.get("obixHis")?.val?.toStr
            if(his != null)
            {
              points.each |pv, pk|
              {
                if( ! pk.isEmpty && his.endsWith(pk + "/"))
                  map(conn, rec.id.id, pv)
              }
            }
          }
        }
        cpt++
        progress.send([cpt, size, "Mapping - $cpt / $size"])
      }
      progress.completed
    }
    catch(Err e)
    {
      e.trace
    }
    return null
  }

  ** Map the Obix Cov point value to the skyspark record
  private Void map(PbpObixConn conn, Str recId, Str point)
  {
    target := point[-1] == '/' ? point[0..-2] : point
    target += "Ref/ref/"
    try
    {
      item := conn.getItem(conn.lobby.href.parent + target.toUri)
      item.obj.val = recId
      echo("Setting $item.obj.href val to : $item.obj.val")
      conn.client.write(item.obj)
    }
    catch(ObixErr err){echo(err)}
  }

  ** querying Obix for HistoryPath items
  ** Return point uri keyed by point path
  private [Str:Str]? getHistoryPoints(PbpObixConn conn, ProgressHandler progress)
  {
    qUri := conn.lobby.href.parent + `/obix/config/Drivers/Config/obix/ObixQuery/query`
    wc := WebClient(qUri)
    if( ! conn.user.isEmpty)
      wc.reqHeaders["Authorization"] = "Basic " + "$conn.user:$conn.conn.plainPassword".toBuf.toBase64
    wc.postStr(Str<|<str val="bql:select * from basTemplateMavi:HistoryPath"/>|>)
    if(wc.resCode == 100) wc.readRes  // 100 -continue handling
    if(wc.resCode > 400)
    {
      Dialog.openWarn(null, "Obix query failed.", wc.resIn.readAllStr)
      return null
    }

    // parse the xml and create historyPoints list
    historyPoints := [:]
    doc := XParser(wc.resIn).parseDoc
    size := doc.root.elems.size + 1
    cpt := 0
    doc.root.elems.each
    {
      val := it.attr("val", false)
      if(val != null)
      {
        item := conn.getItem(conn.lobby.href.parent + `/$val.val.toUri`)
        if(item.obj.has("path"))
          historyPoints[item.obj.get("path").val] = val.val
      }
      cpt++
      progress.send([cpt, size, "Finding points - $cpt / $size"])
    }

    return historyPoints
  }
}
