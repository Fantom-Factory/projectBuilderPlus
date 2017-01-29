/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


@Serializable
class TemplateTreeNode
{
  @Transient
  TemplateTreeNode? parent
  TemplateRecord record
  TemplateLayer layer
  TemplateTreeNode[] children := [,]

  new make(|This| f)
  {
    f(this)
  }


@Transient
  Void addChild(Record rec, TemplateLayer layer)
  {
    children.add(
      TemplateTreeNode{
        it.parent = this
        it.record = TemplateRecord.fromRecord(rec)
        it.children = [,]
        it.layer = layer
      })
      return
  }

  TemplateTreeNode dupNewRec(Record rec)
  {
    return TemplateTreeNode{
      it.record = rec
      it.parent = this.parent
      it.layer = this.layer
      it.children = this.children
    }
  }
}
