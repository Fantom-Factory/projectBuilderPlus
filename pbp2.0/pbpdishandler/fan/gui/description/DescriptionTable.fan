/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

abstract class DescriptionTable : EdgePane
{
  abstract Str title()
  abstract TableModel tableModel()
  abstract Obj[] getDescriptions()
  virtual Widget body()
  {
    table := Table{model=tableModel()}
    movableModel := table.model as MovableModel

    return SashPane{
      weights = [3,1]
      table,
      GridPane{numCols=1;
      Button{
        text="Move Up";
        onAction.add |e|
        {
            moveUp(table, movableModel)
        }
        },
      Button{
        text="Move Down";
        onAction.add |e|
        {
            moveDown(table, movableModel)
        }
        },
      }
    }
  }

  private Void moveUp(Table table, MovableModel movableModel)
  {
          if(table.selected.isEmpty){return}
          Int prev := table.selected.first
          movableModel.moveup(table.selected)
          table.refreshAll
          sel := (prev-1)%table.model.numRows()
          table.selected = [sel >= 0 ? sel : 0]
          if((prev-1)<0){table.selected=[table.model.numRows-1]}
  }

  private Void moveDown(Table table, MovableModel movableModel)
  {
          if(table.selected.isEmpty){return}
          Int prev := table.selected.first
          movableModel.movedown(table.selected)
          table.refreshAll
          table.selected = [(prev+1)%table.model.numRows()]

  }
}
