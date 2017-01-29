/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore
using pbplogging

class TemplateTreeModel : TreeModel
{
  TemplateTree templateTree

  new make(TemplateTree tree)
  {
    this.templateTree = tree
  }

  Void updateRec(Record rec)
  {
    templateTree.update(rec)
  }

  Void addRec(Record node)
  {
    templateTree.insert(node)
  }

  Void deleteRec(Record node)
  {
    templateTree.delete(node)
  }

  override Obj[] roots()
  {
    rootList := [,]
    rootKeys := templateTree.roots.keys
    rootKeys.each |rootkey|
    {
      rootList.push(templateTree.datamash[rootkey])
    }
    return rootList
  }

  override Obj[] children(Obj node)
  {
    TemplateTreeNode treenode := node
    return templateTree.datamash[treenode.record.id.toStr].children
  }

  override Str text(Obj node)
  {
    TemplateTreeNode treenode := node
    return treenode.record.get("dis").val.toStr
  }
}
