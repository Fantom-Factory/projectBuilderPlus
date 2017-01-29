/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore
using pbpgui

class AddObixTagsToRecord : Command
{
  Table obixTable
  Table recTable
  new make(Table obixTable, Table recTable) : super.makeLocale(Pod.of(this), "addObixTagsToRec")
  {
    this.obixTable = obixTable
    this.recTable = recTable
  }

  override Void invoked(Event? e)
  {
    Tag[] tags := [,]
    ObixItem selectedObixItem := (obixTable.model as ObixMapperTableModel).getRow(obixTable.selected)
    if(selectedObixItem.isHis)
    {
      tags.push(UriTag{it.name="obixHis"; val=selectedObixItem.obj.normalizedHref.pathOnly})
    }
    if(selectedObixItem.isPoint)
    {
      tags.push(UriTag{it.name="obixCur"; val=selectedObixItem.obj.normalizedHref.pathOnly})
      if(((obixTable.model as ObixMapperTableModel).refMap.val as Map).containsKey(selectedObixItem.obj.normalizedHref.pathOnly))
      {
        Obj? tocheck := ((obixTable.model as ObixMapperTableModel).refMap.val as Map).get(selectedObixItem.obj.normalizedHref.pathOnly)
        if(tocheck.typeof == Uri#)
        {
          tags.push(UriTag{it.name="obixHis"; val=tocheck})
        }
      }
    }
    ObixMapperWindow mapWin := e.window
    tags.push(RefTag
    {
      it.name="obixConnRef";
      echo("mw: ${mapWin.manager.tree.model->conn->conn->params}")
      val = (mapWin.manager.tree.model as PbpObixTreeModel).conn.conn.params.get("record")->id
    })
    Str:Record recMap := [:]
    (recTable.model as RecTableModel).rows.each |row|
    {
      recMap.add(row.id.toStr,row)
    }
    Record[] newRecs := [,]
    recTable.selected.each |selection|
    {
      Record rec := (recTable.model as RecTableModel).getRow(selection)
      tags.each |tag|
      {
        rec = rec.add(tag)
      }
      /*
      Map recMap := recTable.model->currentProject->database->getClassMap(pbpcore::Point#)->set(rec.id, rec)
      recTable.model->update(recMap)
      recTable.refreshAll
      */
      newRecs.add(rec)
    }
    newRecs.each |rec|
    {
      recMap.set(rec.id.toStr,rec)
    }
    (recTable.model as RecTableModel).update(recMap)
    recTable.refreshAll
  }
}

