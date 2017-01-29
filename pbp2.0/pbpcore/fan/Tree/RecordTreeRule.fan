/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using haystack
using pbplogging

@Serializable
class RecordTreeRule
{
  Str name := "New Layer"

  //Watches...
  Watch[] rules := [,]
  //Parent Reference
  Tag? parentref
  //Action... WHAT MUST I DO NOWWW!!

  WatchType? watchTypes() {find(WatchType#) as WatchType}
  WatchTags? watchTags()   {find(WatchTags#) as WatchTags}
  WatchTagsExclude? watchTagsExclude()   {find(WatchTagsExclude#) as WatchTagsExclude}
  WatchTagVals? watchVals() {find(WatchTagVals#) as WatchTagVals}

  Watch? find(Type type)
  {
    return rules.find {it.typeof == type}
  }

  new make(|This| f)
  {
    f(this)
  }
  @Transient
  RecordTreeNode? apply(RecordTree parenttree, Record rectoexamine)
  {
    Bool pass := true
    //Must satisfy all rules?????? yes...
    rules.each |rule|
    {
      pass = pass.and(rule.check(rectoexamine))
    }
    if(pass == false){return null}
    if(parentref==null)
    {
      RecordTreeNode newroot := RecordTreeNode{parent=null; record = rectoexamine; children = [,]}
      parenttree.addRoot(newroot)
      parenttree.addData(newroot)
      return newroot
    }
      Tag? recTag := rectoexamine.get(parentref.name)
      Obj? parentRef := recTag!=null?recTag.val:Ref.nullRef
      RecordTreeNode? parentnode := parenttree.datamash[parentRef!=null?parentRef.toStr:""]
    if(parentnode != null)
    {
      parentnode.addChild(rectoexamine)
      parenttree.addData(parentnode.children.peek)
      return parentnode
    }
    return null
  }

}
