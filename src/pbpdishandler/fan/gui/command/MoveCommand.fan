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

abstract class MoveCommand : Command
{
    private Table table

    new make(Table table, Str keyBase) : super.makeLocale(Pod.of(this), keyBase) { this.table = table }

    override Void invoked(Event? e)
    {
        FunctionTableModel model := table.model
        rowIdx := table.selected.first
        if (rowIdx != null)
        {
            selectedFile := model.getFile(rowIdx)
            if (moveFunction(model, rowIdx))
            {
                model.functionSortModel.save
                model.update
                table.refreshAll
                table.selected = [model.getFileIndex(selectedFile)]
            }
        }
    }

    abstract Bool moveFunction(FunctionTableModel model, Int rowIdx)
}


class MoveUpCommand : MoveCommand
{
    new make(Table table) : super.make(table, "moveUp") { }

    override Bool moveFunction(FunctionTableModel model, Int rowIdx)
    {
      return model.functionSortModel.moveFunctionUp(model.getFile(rowIdx).get(0))
    }
}

class MoveDownCommand : MoveCommand
{
    new make(Table table) : super.make(table, "moveDown") { }

    override Bool moveFunction(FunctionTableModel model, Int rowIdx)
    {
      return model.functionSortModel.moveFunctionDown(model.getFile(rowIdx).get(0))
    }
}
