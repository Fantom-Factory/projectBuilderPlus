/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbplogging

** This is not a FWT tree which leads to confusion
** The actual Tree is under TemplateEditor.templateTreeStruct
@Serializable
class TemplateTree
{
  Str:TemplateTreeNode roots :=[:]
  TemplateType tType
  Str:TemplateTreeNode datamash := [:]

  new make(|This| f)
  {
    f(this)
  }

  @Transient
  Void update(Record rec)
  {
    Str id := rec.id.toStr
    if(roots.containsKey(id))
      roots[id].record = TemplateRecord.fromRecord(rec)
    if(datamash.containsKey(id))
      datamash[id].record = TemplateRecord.fromRecord(rec)
  }

  @Transient
  Void insert(Record rec)
  {
    tType.layers.each |rule|
    {
      rule.apply(this, rec)
    }
  }

  @Transient
  Void delete(Record rec)
  {
    Str firstId := rec.id.toStr
    Str[] toDelete := [,]
    TemplateTreeNode currentNode := datamash[firstId]

    currentNode.children.each |child|
    {
      toDelete.push(child.record.id.toStr)
    }

    while(toDelete.size > 0)
    {
      toDelete.each |deletenode|
      {
        datamash[deletenode].children.each |child|
        {
          toDelete.push(child.record.id.toStr)
        }
        if(datamash.containsKey(deletenode))
        {
          datamash.remove(deletenode)
        }
       toDelete.remove(deletenode)
      }
    }

    if(roots.containsKey(firstId))
    {
      roots.remove(firstId)
    }
    if(datamash.containsKey(firstId))
    {
      datamash.remove(firstId)
    }

    datamash.each |node|
    {
      TemplateTreeNode? targetNode := node.children.find|TemplateTreeNode hotnode -> Bool|{return hotnode.record.id.toStr==firstId}
      if(targetNode!=null)
      {
        node.children.remove(targetNode)
      }
    }
    Logger.log.debug(datamash.toStr)
  }

  @Transient
  Void walk( |TemplateTreeNode,TemplateTreeNode?,TemplateLayer->Void| func)
  {
    roots.each |root|
    {
      func.call(root,null,root.layer)
    }
    datamash.each |v,k|
    {
      TemplateTreeNode currentNode := v
      currentNode.children.each |child|
      {
        func.call(child, currentNode, child.layer)
      }
    }
  }

  @Transient
  Void addRoot(TemplateTreeNode node)
  {
    roots.set(node.record.id.toStr,node)
  }
  @Transient
  Void addData(TemplateTreeNode node)
  {
    datamash.add(node.record.id.toStr, node)
  }

}
