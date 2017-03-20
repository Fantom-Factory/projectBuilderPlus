/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using xml
using util
using pbplogging

@Serializable
class RecordTree
{
  @Transient
  Project? parentproject
  Str? treename
  Str:RecordTreeNode datamash := [:]
  RecordTreeNode[] roots := [,]
  RecordTreeRule[] rules := [,]
  RecordTreeNode? latestNode
  new make( |This|? f)
  {
    f(this)
  }

  Void insert(Record rec)
  {
    rules.each |rule|
    {
     rule.apply(this, rec)
    }
  }

  @Transient
  Str[] recursiveDel(Record rec)
  {
    Str firstId := rec.id.toStr
    Str[] toDelete := [,]
    Str[] toReturn := [,]
    RecordTreeNode? currentNode := datamash[firstId]
    if(currentNode==null){return [,]}
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
          toReturn.push(deletenode)
          datamash.remove(deletenode)
        }
       toDelete.remove(deletenode)
      }
    }
    RecordTreeNode? rootNode := roots.find |RecordTreeNode r -> Bool| {return r.record.id.toStr== firstId}
    if(rootNode != null)
    {
      roots.remove(rootNode)
    }
    if(datamash.containsKey(firstId))
    {
      toReturn.push(firstId)
      datamash.remove(firstId)
    }

    datamash.each |node|
    {
      RecordTreeNode? targetNode := node.children.find|RecordTreeNode hotnode -> Bool|{return hotnode.record.id.toStr==firstId}
      if(targetNode!=null)
      {
        node.children.remove(targetNode)
      }
    }
    Logger.log.debug(datamash.toStr)
    return toReturn
  }

  Void reset()
  {
    datamash = [:]
    roots = [,]
  }

  Void scanProject()
  {
    rules.each |rule|
    {
      WatchType? typeWatcher := rule.rules.find|Watch w -> Bool| {return w.typeof == WatchType#}
      if(typeWatcher != null)
      {
        Map? maptoscan := parentproject.database.getClassMap(typeWatcher.typetowatch)
        if(maptoscan != null)
        {
          maptoscan.vals.each |val|
          {
            rule.apply(this,val) //TODO: Temp replace with a smarter approach
          }
        }
      }
      else
      {
         parentproject.database.getClassMap(Record#).vals.each|val|
          {
            if(!datamash.containsKey((val as Record).id.toStr))
            {
              rule.apply(this,val) //TODO: Temp replace with a smarter approach
            }
          }
       }
    }
  }


  Void addRoot(RecordTreeNode node)
  {
    roots.add(node)
  }

  Void addData(RecordTreeNode node)
  {
    recId := node.record.id.toStr
    if (!datamash.containsKey(recId)) {
      datamash.add(recId, node)
      latestNode = datamash.vals.peek
    }
  }
//TODO: Hide in a util function
  Void save(File? dir := null)
  {
   File? treefile := null
    if(dir!=null)
    {
      treefile = dir.createFile(treename+".tree")
    }
    else
    {
      treefile = parentproject.treeDir.createFile(treename+".tree")
    }

    /*
    OutStream treefileout := treefile.out
    zip := Zip.write(treefileout)

    rules.each |rule|
    {
      out := zip.writeNext(`rules/${Uuid().toStr}.rule`)
      out.writeObj(rule)
      out.close
    }

    XElem projectInfo := XElem("tree"){XAttr("name",treename),}
    XDoc doc := XDoc(projectInfo)
    treeinfoout := zip.writeNext(`info.xml`)
    doc.write(treeinfoout)

    datamashfile := zip.writeNext(`datamash.struct`)
    datamashfile.writeObj(datamash)
    datamashfile.close

    rootsfile := zip.writeNext(`roots.struct`)
    rootsfile.writeObj(roots)
    rootsfile.close

    treeinfoout.close
    zip.close
    */
     treefile.writeObj(this)
  }
  /*
  **
  ** Save's the tree in Json format to the correct project directory
  **
  Void save()
  {
    map := ["root":root]


    targetfileout.close
  }
  */
  //TODO: Hide in a util function
  static RecordTree fromFile(File treefile, Project parentProject)
  {
  /*
    RecordTreeRule[] rules := [,]
    zip := Zip.open(treefile)
    File[] rulefiles := zip.contents.vals.findAll |File f->Bool|{return f.ext == "rule"}
    rulefiles.each |file|
    {
      rulein := file.in
      rules.push(rulein.readObj)
      rulein.close
    }
    File treeinfo := zip.contents[`/info.xml`]
    treeinfoin := treeinfo.in
    XParser parser := XParser(treeinfoin)
    XDoc doc := parser.parseDoc
    Str treename := doc.root.get("name")
    treeinfoin.close
    map := [:]
    root := [,]

    if(zip.contents.containsKey(`/datamash.struct`))
    {
      File mapstruct := zip.contents[`/datamash.struct`]
      mapstructin := mapstruct.in
      map = mapstructin.readObj
    }

    if(zip.contents.containsKey(`/roots.struct`))
    {
      File rootstruct := zip.contents[`/roots.struct`]
      rootstructin := rootstruct.in
      root = rootstructin.readObj
    }
    return RecordTree{
      it.treename = treename
      it.rules = rules
      it.parentproject = parentProject
      it.datamash = map
      it.roots = root
    }
    */
    RecordTree treetoread := treefile.readObj
    treetoread.parentproject=parentProject
    return treetoread
  }




}
