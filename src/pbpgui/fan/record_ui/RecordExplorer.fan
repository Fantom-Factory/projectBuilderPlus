/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore
using concurrent
using pbplogging

class RecordExplorer : EdgePane,  UiUpdatable
{

  private ToolBar recordToolbar
  private Table recordTable
  private RecTableModel? recordTableModel
  private PaginationController paginationController := PaginationController()
  private LimitController limitController := LimitController()

  new make(PbpListener pbpListener) : super()
  {
    center = recordTable = Table(){multi=true}
    recordTable.model = BlankTableModel()
    top = recordToolbar = RecordCommands(pbpListener).getToolbar
    bottom = ButtonGrid{numCols=3; /*Button(ShowAll(this)),*/Label{text="Limit"},limitController,paginationController,}

    recordTable.onAction.add |e| { echo("ACTION") }
    recordTable.onSelect.add |e| { echo("SELECT") }
    recordTable.onPopup.add |e| { echo("POPUP") }
  }

  Void update(Map recMap)
  {
    if (recordTableModel == null) throw Err("Invalid state: setTableModel not called before update call.")

    recordTableModel.update(recMap)
  }

  Void refreshAll()
  {
    recordTable.refreshAll
  }

  Record[] getSelected()
  {
    return recordTableModel.getRows(recordTable.selected)
  }

  Void addOnTableAction(|Event e| f)
  {
    recordTable.onAction.add(f)
  }

  Void addOnPopupTableAction(|Event e| f)
  {
    recordTable.onPopup.add(f)
  }

  Void clearTableSelection()
  {
    recordTable.selected = [,]
  }

  Void sendMsgToModelController(Obj? msg)
  {
    recordTableModel.controller.send(msg)
  }

  Int getAuxRowsSize()
  {
    recordTableModel.auxRows.size
  }

  Obj? getPaginationFirstPage()
  {
    return paginationController.pages.first
  }

  Void addToolbarCommand(Command command)
  {
    recordToolbar.addCommand(command)
  }

  Void setTableModel(RecTableModel model)
  {
    model.table = recordTable
    recordTableModel = model
    recordTable.model = model
    recordTableModel.attachController(RecordExpPaginationHandler(this.limitController.limit, this.paginationController))
    recordTableModel.controller.send(recordTableModel.rows.size)
    recordTable.refreshAll
  }

  override Void updateUi(Obj? params := null)
  {
    if (params is Range)
    {
      recordTableModel.updateUi(params)
      recordTable.refreshAll
    }
  }
}

class LimitController : Text, UiCommunicator
{
  AtomicRef limit := AtomicRef(100)
  new make() : super()
  {
    this.text = "100"
    onAction.add |e|
    {
      if (Int.fromStr(this.text, 10, false) != null)
      {
        limit.getAndSet(Int.fromStr(this.text, 10, false))
        communicate(null)
        this.relayout
        this.parent.relayout
      }
    }
  }

  override Size prefSize(Hints hints:=Hints.defVal)
  {
    return Size(this.text.size * Desktop.sysFont.size.toInt + 11, super.prefSize(hints).h)
  }

  override Void communicate(Obj? params)
  {
    if (this.parent.parent is RecordExplorer)
    {
      recExp := this.parent.parent as RecordExplorer
      recExp.sendMsgToModelController(recExp.getAuxRowsSize)
      recExp.updateUi(recExp.getPaginationFirstPage)
      recExp.refreshAll
    }
  }
}


const class RecordExpPaginationHandler : Actor
{
  const Str pHandler := Uuid().toStr
  const AtomicRef limitController
  new make(AtomicRef limitController, PaginationController paginationController) : super(ActorPool())
  {
    this.limitController = limitController
    Actor.locals[pHandler] = paginationController
  }

  override Obj? receive(Obj? msg)
  {
    Desktop.callAsync |->|
    {
      updatePages(msg)
    }
    return null
  }

  Void updatePages(Obj? msg)
  {
    Int totalSize := msg
    Int pages := 1
    Int limit := limitController.val

    if (limit == 0) limit = 100 /* default page size */

    if (limit > totalSize)
    {
      limit = totalSize
    }

    if (totalSize >= limit)
    {
      pages = (totalSize / limit)
      if (totalSize - (limit * pages) > 0){
        pages++
      }
    }

    Range[] pageRanges := [,]
    if (pages > 1)
    {
      //Paginate
      pages.times |index|
      {
        start := index * limit
        end := start + limit - 1
        Range newRange := start..end
        pageRanges.push(newRange)
      }

      if ((pageRanges.last.last) != (totalSize - 1))
      {
        pageRanges[pages-1] = pageRanges[pages-1].first..totalSize-1
      }
    }
    else
    {
      pageRanges.push(0..(totalSize-1))
    }

    paginator := Actor.locals[pHandler] as PaginationController
    if (paginator != null)
    {
      paginator.updateUi(pageRanges)
    }
   }
}

