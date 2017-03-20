/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using pbpcore
using pbpgui
using gfx
using fwt

class ObixMapperWindow : PbpWindow
{
  Str sessionId := Uuid().toStr
  Bool cancel := false
  ObixConnManager manager

  ObixMapperTable table
  ObixMapperTableModel model
  ObixStatusHandler statusHandler

  EdgePane mainWrapper := EdgePane{}
  SashPane centerWrapper := SashPane{}

  Str:Record recsToEdit := [:]
  new make(Window parentWin, ObixConnManager manager, ObixItem[] items, Record[] recsToEdit) : super(parentWin)
  {
    ActorPool newPool := ActorPool()
    model = ObixMapperTableModel(items)
    table = ObixMapperTable{it.model=this.model}
    this.manager = manager
    statusHandler = ObixStatusHandler(this.table, model.refMap, newPool)
    this.recsToEdit.addList(recsToEdit, |Record rec -> Str| {
      return rec.id.toStr
    })
  }

  override Obj? open()
  {
    Table recTable := Table{it.model=RecTableModel(recsToEdit,manager.pbp.currentProject)}
    centerWrapper.add(EdgePane{center=table; right=Button(AddObixTagsToRecord(table,recTable));})
    centerWrapper.add(recTable)
    mainWrapper.center = centerWrapper
    mainWrapper.bottom = ButtonGrid{numCols=2; Button(Dialog.ok), Button{text="Cancel"; onAction.add|e|{cancel=true; e.window.close}}}
    content=mainWrapper
    size = Size(1321,644)
    title = "Obix Mapper - Session Id "+sessionId
    super.open()
    if(cancel)
    {
      return null
    }
    return (recTable.model as RecTableModel).rows
  }





}
