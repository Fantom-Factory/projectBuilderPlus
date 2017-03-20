/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using projectBuilder
using pbpcore
using concurrent
using pbpgui

class EngineWindow : Window
{
  File? currentFolder { private set }
  EnvHandler ehandle
  Table functionTable

  private Button btnNewFunction
  private Button btnEditFunction
  private Button btnDeleteFunction
  private Button btnMoveUp
  private Button btnMoveDown
  private Button btnMakeNavNameFunction
  private Button btnResetNavNameFunction
  private Button btnExecuteSelected

  new make(Window? parent, EnvHandler ehandle, ProjectBuilder pbp) : super(parent)
  {
    this.ehandle = ehandle
    currentFolder = ehandle.localEnv.listDirs.first
    functionTable = Table()
    {
      model = FunctionTableModel(currentFolder, pbp)
      multi = true
      onSelect.add |Event event|
      {
        table := event.widget as Table
        if (table == null) return

        selected := table.selected

        if (selected.size == 0)
        {
          btnNewFunction.enabled = true
          btnEditFunction.enabled = false
          btnDeleteFunction.enabled = false
          btnMoveUp.enabled = false
          btnMoveDown.enabled = false
          btnMakeNavNameFunction.enabled = false
          btnResetNavNameFunction.enabled = true
          btnExecuteSelected.enabled = false
        }
        else if (selected.size == 1)
        {
          btnNewFunction.enabled = true
          btnEditFunction.enabled = true
          btnDeleteFunction.enabled = true
          btnMoveUp.enabled = true
          btnMoveDown.enabled = true
          btnMakeNavNameFunction.enabled = true
          btnResetNavNameFunction.enabled = true
          btnExecuteSelected.enabled = true
        }
        else if (selected.size > 1)
        {
          btnNewFunction.enabled = true
          btnEditFunction.enabled = false
          btnDeleteFunction.enabled = false
          btnMoveUp.enabled = false
          btnMoveDown.enabled = false
          btnMakeNavNameFunction.enabled = true
          btnResetNavNameFunction.enabled = true
          btnExecuteSelected.enabled = true
        }
      }
    }

    title = "Display Name Handler - BETA"
    size = Size(577, 389)

    content = SashPane
    {
      EdgePane{
      top = Combo{items=ehandle.localEnv.listDirs
        onAction.add |e|
        {
          currentFolder = (e.widget as Combo).selected
          functionTable.model = FunctionTableModel(currentFolder, pbp)
        }
        }
        center=functionTable
        },
        GridPane{
          btnNewFunction = Button(NewFunction(functionTable)),
          btnEditFunction = Button(EditFunction(functionTable)),
          btnDeleteFunction = Button(DeleteFunction(functionTable)),
          Label() {text = "-------------------------"},
          btnMoveUp = Button(MoveUpCommand(functionTable)),
          btnMoveDown = Button(MoveDownCommand(functionTable)),
          Label() {text = "-------------------------"},
          btnMakeNavNameFunction = Button(MakeNavNameFunction(pbp, functionTable)),
          btnResetNavNameFunction = Button(ResetNavNameFunction(pbp)),
          Label() {text = "-------------------------"},
          btnExecuteSelected = Button(ExecuteFunction(pbp, functionTable)),
        },
    }

    functionTable.onSelect.fire(Event() {widget = functionTable})
  }

}
