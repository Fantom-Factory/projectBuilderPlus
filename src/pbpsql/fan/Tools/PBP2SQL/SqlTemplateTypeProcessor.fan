/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using concurrent
using fwt

class SqlTemplateTypeProcessor : SqlProcessor
{

  TemplateType templateType
  new make(TemplateType templateType)
  {
    this.templateType = templateType
  }

  override SqlPackageEditPane[] getEditPanes(AtomicRef listRef)
  {
    toReturn := [,]
    templateType.layers.each |layer|
    {
      Str:Obj? options := [:]
      Tag? parentRef := layer.parentref
      Str:Tag tagstomap := [:]
      layer.rules.each |rule|
      {
        switch(rule.typeof)
        {
          case WatchTags#:
            (rule as WatchTags).tagstowatch.each|tag|
            {
              tagstomap.set(tag.name,tag)
            }
          case WatchTagVals#:
            (rule as WatchTagVals).tagstowatch.each|tag|
            {
              tagstomap.set(tag.name,tag)
            }
          case WatchType#:
            RecordFactory.getRecByType((rule as WatchType).typetowatch).data.each |tag|
            {
              tagstomap.set(tag.name,tag)
            }
            options.add("type", (rule as WatchType).typetowatch)
          }
      }
     Str name := layer.name
     toReturn.push(SqlPackageEditPane(name, parentRef, tagstomap.vals, listRef, options))
    }
    return toReturn
  }

  override SqlPackage processEditPane(SqlPackageEditPane editPane)
  {
    SqlPackageRule[] rules := [,]
    editPane.blobs.each|blob|
    {
      SqlPackageRule? rule :=blob.processRule
      if(rule!=null)
      {
        rules.push(rule)
      }
    }
    if(editPane.parentRef!=null)
    {
    return SqlPackage{
      it.rules = rules
      id= SqlPackageId{
        idVal =[
          "name":editPane.name,
          "type":editPane.options["type"],
          "uniqueCol":editPane.pbpidselector.text,
          "parentRef":editPane.parentRef,
          "parentCol":editPane.parentpbpidselector.text,
          "useParentCol":editPane.parentMapSqlColButton.selected,
          "mapLater":editPane.parentMapLaterButton.selected
          ]
       }
    }
    }
    else
    {
    return SqlPackage{
      it.rules = rules
      id= SqlPackageId{
        idVal =[
          "name":editPane.name,
          "type":editPane.options["type"],
          "uniqueCol":editPane.pbpidselector.text
          ]
       }
    }
    }
  }
}


