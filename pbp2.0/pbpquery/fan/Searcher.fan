/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpgui
using fwt
using gfx
using pbpcore
using projectBuilder

class Searcher
{
  private RecordIndexer indexer
  internal ProjectBuilder pbp { private set }

  private Str[] history := [,]
  private Int hisIndex := 0

  new make(ProjectBuilder pbp, RecordIndexer indexer)
  {
    this.indexer = indexer
    this.pbp = pbp
  }

  Map query(Str query)
  {
    history.push(query)
    hisIndex = history.size - 1
    Str:Str recMap := indexer.search(query)
    Map maptoreturn := pbp.currentProject.database.getClassMap(Record#).findAll |V,K -> Bool| {
      return recMap.containsKey(K)
    }
    return maptoreturn
  }

  Window getWindow()
  {
    SearcherWindow window := SearcherWindow(Desktop.focus.window, this)
    return window
  }

  SearcherPane getPane()
  {
    SearcherPane pane := SearcherPane( this)
    return pane
  }

  ** Up history
  Str up(Str curText)
  {
    hisIndex -= 1
    if(hisIndex < 0) hisIndex = 0
    return history.size > hisIndex ? history[hisIndex] : curText
  }

  ** Down history
  Str down(Str curText)
  {
    hisIndex += 1
    if(hisIndex >= history.size) hisIndex = history.size - 1
    return (hisIndex>=0 && history.size > hisIndex) ? history[hisIndex] : curText
  }
}

