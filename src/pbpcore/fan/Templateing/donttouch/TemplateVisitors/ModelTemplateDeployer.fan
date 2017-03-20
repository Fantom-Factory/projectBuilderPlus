/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////




const class ModelTemplateDeployer : TemplateDeployer
{
  const Str[][] rows
  new make(Str[][]  rows)
  {
    this.rows = rows
  }
  override Int size()
  {
    return rows.size-1
  }
  override Obj? visit(Str:Obj params)
  {
    Record[] todeliver := [,]
    Template template := params["template"]
    Str:Obj options := params["opts"]
    Tag[] tags := [,]
    Tag[][] alltagstoadd := [,]
    rows.each |row, index|
    {
      if(index==0)
      {
        row.each|tagname|
        {
          tags.push(StrTag{name=tagname; val=""})
        }
      }
      else
      {
        Tag[] tagstoadd := [,]
        row.each |tagval, tindex|
        {
          tagstoadd.push(TagFactory.setVal(tags[tindex],tagval))
        }
        alltagstoadd.add(tagstoadd)
      }
    }
      alltagstoadd.each |taggroup|
      {
        Str:Obj replicatedRecs := TemplateEngine.replicateTemplateTree(template,options)
        Str:Record recMap := replicatedRecs["newRecs"]
        Str:Str newRefMap := replicatedRecs["newIdMap"]
        Str key := template.templateTree.roots.keys.first
        Str newKey := newRefMap.get(key)
        taggroup.each |tag|
        {
          recMap[newKey] = recMap[newKey].add(tag)
        }
        todeliver.addAll(recMap.vals)
      }
      return todeliver
    }
  }

