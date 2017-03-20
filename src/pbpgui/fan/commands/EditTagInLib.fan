/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt

class EditTagInLib : Command
{
  private TagEditor tageditor
  new make(TagEditor tageditor) : super.makeLocale(Pod.of(this), "editTagsInLib")
  {
    this.tageditor = tageditor
  }

  override Void invoked(Event? e)
  {
    tageditor.tagExp.getSelected.each |tag|
    {
      tageditor.tageditpane.add(EditTagMaker(tag))
    }
    tageditor.tageditpane.relayout
    tageditor.tageditpane.parent.relayout
    tageditor.tageditpane.parent.parent.relayout
  }
}
