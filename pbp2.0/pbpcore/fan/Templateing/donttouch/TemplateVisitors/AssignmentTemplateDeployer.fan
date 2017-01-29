/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using haystack

const class AssignmentTemplateDeployer : TemplateDeployer
{
  const Record[] mapping
  const Int repeat
  new make(Record[] mapping, Int repeat := 1)
  {
    this.mapping = mapping
    this.repeat = repeat
  }
  override Int size()
  {
    return mapping.size*repeat
  }
  override Obj? visit(Str:Obj params)
  {
    Record[] todeliver := [,]
    Template template := params["template"]
    Str:Obj options := params["opts"]
    mapping.each |recid|
    {
      repeat.times |->|
      {
      Str:Obj replicatedRecs := TemplateEngine.replicateTemplateTree(template,options, recid)
      Str:Record recMap := replicatedRecs["newRecs"]
      Str:Str newRefMap := replicatedRecs["newIdMap"]
      Tag parentRef := template.templateTree.roots.vals.first.layer.parentref
      template.templateTree.datamash.each |node, key|
      {
        Str newKey := newRefMap.get(key)
        recMap[newKey] = recMap[newKey].add(TagFactory.setVal(parentRef, recid.id))
      }
      template.templateTree.datamash.each |node, key|
      {
        Str newKey := newRefMap.get(key)
        if(node.layer.root)
        {
          recMap[newKey] = recMap[newKey].add(StrTag{name="dis";val=recid.get("dis").val.toStr+"-"+recMap[newKey].get("dis").val.toStr})
        }
        else
        {
          recMap[newKey] = recMap[newKey].add(StrTag{name="dis";val=recid.get("dis").val.toStr+"-"+recMap[newKey].get("dis").val.toStr})
        }
      }
      todeliver.addAll(recMap.vals)
      }
    }
    return todeliver
  }
}
