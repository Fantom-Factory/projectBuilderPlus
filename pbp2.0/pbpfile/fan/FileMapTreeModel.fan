/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt

class FileMapNode 
{
  Str dis := ""
  FileMap? fileMap := null
  FileMapNode[] children := [,]
  FileMapNode? parent := null
  DateTime:Float values := [:]

  new make(Str dis, FileMapNode[] children := [,])
  {
    this.dis = dis
    children.each { this.add(it) }
  }

  new fromMap(FileMap map)
  {
    this.fileMap = map
    this.dis = "${map.dis} (${map.tsName},${map.valName})"
    if (map.pointDis != null)
      this.dis += " → ${map.pointDis}"
  }

  Void add(FileMapNode node)
  {
    node.parent = this
    children.push(node)
  }
}

class FileMapTreeModel : TreeModel
{
  private FileMapNode[] rootNodes := [,]

  new make(FileMap[] fileMaps := [,])
  {
    this.update(fileMaps)
  }

  override Obj[] roots()
  {
    return rootNodes
  }

  override Obj[] children(Obj node)
  {
    return (node as FileMapNode).children
  }

  override Str text(Obj node)
  {
    return (node as FileMapNode).dis
  }

  Void update(FileMap[] fileMaps)
  {
    rootNodes.clear
    fileMaps.each |map| {
      if (map.hasDiscriminator)
      {
        groupdis := "${map.discriminatorName} = ${map.discriminatorVal}"
        found := rootNodes.find |n| { n.dis == groupdis }
        if (found == null)
          rootNodes.add(FileMapNode(groupdis, [FileMapNode.fromMap(map)]))
        else
          found.add(FileMapNode.fromMap(map))
      }
      else
      {
        rootNodes.add(FileMapNode.fromMap(map))
      }
    }    
  }
}
