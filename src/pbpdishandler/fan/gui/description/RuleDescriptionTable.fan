/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

class RuleDescriptionTable : DescriptionTable
{
  private DisRule[] rules
  private RuleTableModel tmodel

  new make(DisFunc func)
  {
  rules = func.rules
  tmodel = RuleTableModel(rules)
  top = Label{text=title(); font=Font{bold=true}}
  center = body()
  }

  override Str title()
  {
    return "Rule Ranking"
  }
  override TableModel tableModel()
  {
    return tmodel
  }

  override Obj[] getDescriptions()
  {
    return tmodel.rules
  }

  Void update(DisFunc func)
  {
    tmodel.rules = func.rules
  }

  Void refreshTables()
  {
    center.children.each |Widget w|
    {
      if (w.typeof==Table#)
      {
        (w as Table).refreshAll
      }
    }
  }
}

