/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt

class DeleteTagFromLib : Command
{
  private TagEditor tageditor
  new make(TagEditor tageditor) : super.makeLocale(Pod.of(this),"delTagFromLib")
  {
    this.tageditor = tageditor
  }

  override Void invoked(Event? e)
  {
    TagExplorer explorer := tageditor.tagExp
    explorer.getSelected.each |tag|
    {
      explorer.tagTableModel.tagLib.tags.remove(tag)
    }
    explorer.tagTableModel.tagLib.write
    explorer.tagTableModel.update(explorer.tagTableModel.tagLib.tagLibFile)
    explorer.tagTable.refreshAll
  }
}

