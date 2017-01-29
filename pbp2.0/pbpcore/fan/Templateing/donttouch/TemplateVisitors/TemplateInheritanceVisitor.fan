/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using haystack

const class TemplateInheritance : Visitor
{

  //params -- Keys:
  // "parent" -- Parent Record
  // "target" -- Target Record
  // "layer" -- Template Layer with da Rules
  override Obj? visit(Str:Obj params)
  {
    Record? siteRecord := params["site"]
    Record? parentRecord := params["parent"]
    Record targetRecord := params["target"]
    TemplateLayer layer := params["layer"]
    Str:Str newRecMap := params["newRecMap"]
    if(parentRecord != null)
    {
      Tag parentTag := TagFactory.setVal(layer.parentref, parentRecord.id)
      targetRecord = targetRecord.add(parentTag)
      Tag[] tagstoadd := [,]
      layer.inheritance.each |tag|
      {
        newtag := parentRecord.get(tag.name)
        if(newtag == null && siteRecord!=null)
          newtag = siteRecord.get(tag.name)
        if(newtag!=null && newtag.typeof == RefTag#)
        {
          if(!newRecMap.containsKey(newtag.val.toStr))
          {
            newRecMap.add(newtag.val.toStr,Ref.gen().toStr)
          }
          newtag = TagFactory.setVal(newtag, Ref.fromStr(newRecMap[newtag.val.toStr]))
        }
        if(newtag!=null){tagstoadd.push(newtag)}

      }
      if(tagstoadd.size > 0)
      {
        targetRecord = targetRecord.addAll(tagstoadd)
      }
      targetRecord = targetRecord.add(StrTag{name="dis"; val=parentRecord.get("dis").val.toStr+"-"+targetRecord.get("dis").val.toStr})
    }
    return targetRecord
  }

}
