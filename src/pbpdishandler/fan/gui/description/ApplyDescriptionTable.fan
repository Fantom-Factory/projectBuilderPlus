/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

class ApplyDescriptionTable : DescriptionTable
{
  private DisApply[] applies
  private ApplyTableModel tmodel

  new make(DisFunc func)
  {
  applies = func.applies
  tmodel = ApplyTableModel(applies)
  top = Label{text=title(); font=Font{bold=true}}
  center = body()
  }

  override Str title()
  {
    return "Apply Ranking"
  }

  override TableModel tableModel()
  {
    return tmodel
  }

  override Obj[] getDescriptions()
  {
    return tmodel.applies
  }

  Void update(DisFunc func)
  {
    tmodel.applies = func.applies
  }

  Void refreshTables()
  {
    center.children.each |Widget w|
    {
      if(w.typeof==Table#)
      {
        (w as Table).refreshAll
      }
    }

  }
}
