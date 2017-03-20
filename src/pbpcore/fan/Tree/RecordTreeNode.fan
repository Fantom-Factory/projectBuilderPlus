/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


@Serializable
class RecordTreeNode
{
  @Transient
  RecordTreeNode? parent
  Record record
  RecordTreeNode[] children := [,]

  new make(|This| f)
  {
    f(this)
  }


@Transient
  Void addChild(Record rec)
  {
    children.add(
      RecordTreeNode{
        it.parent = this
        it.record = rec
        it.children = [,]
      })
      return
  }
@Transient
  override Str toStr()
  {
    return "${record.id} children: ${children}"
  }

}
