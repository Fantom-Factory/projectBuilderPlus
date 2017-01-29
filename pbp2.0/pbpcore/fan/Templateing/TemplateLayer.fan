/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using haystack
using pbplogging

@Serializable
const class TemplateLayer
{
/*Watches
  1. Tags
  2. Tags and Vals
  3. Parent Reference
  4. Tags to Inherit
  5. Kind //TODO: Later!
*/
  const Bool root
  public const Str name := ""
  const Watch[] rules := [,]
  //Parent Reference
  const Tag? parentref := null
  //Inheritance
  const Str:Tag inheritance := [:]
  //Action... WHAT MUST I DO NOWWW!!
  const Str:Obj? options := [:]
  new make(|This| f)
  {
    f(this)
  }

  Str getName()
  {
    return this.name
  }

  **  Need to construct a record based on the watches... TemplateLayer's should have
  **  WatchTags, WatchTagVals, WatchType
  **
  Record getNewRec(Record? parentRec := null)
  {
    Record? rec := null
    WatchType watchType := rules.find |Watch w->Bool|{return w.typeof==WatchType#}
    Type type := watchType.typetowatch
    Tag[] tags := [,]

    rules.each |rule|
    {
      if(rule.typeof.fields.find|Field f->Bool|{return f.name=="tagstowatch"} != null)
      {
        tags.addAll(rule->tagstowatch)
      }
    }

    switch(type)
    {
      case Site#:
        rec = RecordFactory.getSite()
      case Equip#:
        rec = RecordFactory.getEquip()
      case Point#:
        rec = RecordFactory.getPoint()
      default:
        rec = Record{data=[StrTag{it.name="dis"; val="New Record"}]}
    }

    tags.each |tag|
    {
      rec = rec.add(tag)
    }
    if(parentRec!=null)
    {
      rec = rec.add(parentref.setVal(parentRec.id))
    }
    return rec
  }

  @Transient
  TemplateTreeNode? apply(TemplateTree parenttree, Record rectoexamine)
  {
    Bool pass := true
    //Must satisfy all rules?????? yes...
    rules.each |rule|
    {
      pass = pass.and(rule.check(rectoexamine))
    }
   // Logger.log.debug(pass.toStr)
    if(pass == false){return null}
   // Logger.log.debug(parentref.toStr)
    if(root)
    {
      //TODO: This part needs some refactoring?
      TemplateTreeNode newroot := TemplateTreeNode{parent=null; layer = this; record = TemplateRecord.fromRecord(rectoexamine); children = [,]}
      parenttree.roots.add(newroot.record.id.toStr,newroot)
      parenttree.addData(newroot)
      return newroot
    }

      Tag? recTag := rectoexamine.get(parentref.name)
      Obj? parentRef := recTag!=null?recTag.val:Ref.nullRef
      TemplateTreeNode? parentnode := parenttree.datamash[parentRef!=null?parentRef.toStr:""]
    if(parentnode != null)
    {
      parentnode.record.data.findAll |Tag t ->Bool| {return inheritance.containsKey(t.name)}
      rectoadd := rectoexamine.add(recTag)
      parentnode.addChild(rectoadd, this)
      parenttree.addData(parentnode.children.peek)
      if(parenttree.roots.containsKey(parentnode.record.id.toStr)){
        parenttree.addRoot(parentnode)
        parenttree.datamash.set(parentnode.record.id.toStr,parentnode)
        }
      return parentnode
    }
    return null
  }

}
