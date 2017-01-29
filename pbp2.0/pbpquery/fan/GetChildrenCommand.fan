/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using fwt

class GetChildrenCommand : Command
{
  private PbpListener pbp

  new make(PbpListener pbp) : super()
  {
    this.pbp = pbp
  }

  override Void invoked(Event? event)
  {
    Map auxwidgets := pbp.callback("getAuxWidgets")
    if(auxwidgets.containsKey("latestwb"))
    {
      SearcherPane searcherpane := auxwidgets["latestwb"]
      RecordTreeNode[] nodes := (event.widget as Tree).selected
      Str totalQuery := ""
      nodes.each |node|
      {
        Str id := node.record.id.toStr
        Str query := "(\""+id+"\""+ "AND NOT id:" + "\""+id+"\")"
        totalQuery = addQuery(totalQuery, query)
      }
      searcherpane.newQuery(totalQuery)
    }
  }

  private Str addQuery(Str orig, Str newpart)
  {
    if(orig.size > 0)
    {
    return orig + "OR" + newpart
    }
    else
    {
    return newpart
    }
  }
}

