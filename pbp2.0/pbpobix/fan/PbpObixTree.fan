/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx::Image
using pbpi

**
** PbpObixTree
** Display the tree for a sepcific Obix connection
**
class PbpObixTree : Tree
{
  new make() : super()
  {
    model = PbpObixTreeModel()
    multi=true
  }
}

class PbpObixTreeModel : TreeModel
{
  PbpObixConn? conn
  static const Uri[] excludes := [`watchService/`,`about/`,`/obix/config/Services/ObixNetwork/exports`,`batch/`]

  new make() : super() {}

  override Obj[] children(Obj node)
  {
    item := node as ObixItem
    fetched := conn.getItem(item.obj.normalizedHref)
    ObixItem[] items := [,]
    fetched.obj.list.each
    {
      if(it.href == null || ! excludes.contains(it.href))
        items.add(ObixItem(it, conn.getIcon(it)))
    }
    return items
  }

  override Obj[] roots()
  {
    if(conn == null)
      return [,]
    return [conn.getRoot]
  }

  override Str text(Obj node)
  {
    item := node as ObixItem
    return item.name
  }

  override Image? image(Obj node)
  {
    item := node as ObixItem
    return item.iconUri == null ? PBPIcons.obixDefault : Image(item.iconUri)
  }

  override Bool hasChildren(Obj node)
  {
    // TRy to only make expendable nodes for relvant items
    item := node as ObixItem
    return item.obj.elemName == "ref" || item.obj.elemName == "obj"
  }

  Void update(PbpObixConn conn)
  {
    this.conn = conn
  }
}
