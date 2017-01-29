/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using haystack
using pbplogging

class SqlPackageUtil
{

  static Record? getRec(SqlPackage package, SqlRow row)
  {
    //later will be checking for unique Id...
    //Use database service to store recs?
    if(row.data.containsKey(package.id["uniqueCol"]))
    {
      Type? type := package.id["type"]
      Record rec := RecordFactory.getRecByType(type)
      package.rules.each |rule|
      {
      rule.mapping.each |v, k|
      {
        if(row.data.containsKey(k))
          {
            if(rule.filter.containsKey(v))
            {
              if(rule.filter[v].filter(row.data[k].toStr))
              {
                Tag[] tags := rule.tagmap[v]
                tags.each|tag|
                {
                  rec = rec.add(TagFactory.setValFromStr(tag, row.data[k]))
                }
              }
            }
            else
            {
              Tag[] tags := rule.tagmap[v]
              tags.each|tag|
              {
                rec = rec.add(TagFactory.setValFromStr(tag, row.data[k]))
              }
            }
          }
        }
      }
      rec = rec.add(StrTag{name="pbpid"; val=row.data[package.id["uniqueCol"]]})
      if(package.id.idVal.containsKey("parentRef"))
      {
        if(package.id["useParentCol"])
        {
          parentCol := package.id["parentCol"]
          if(row.data.containsKey(parentCol))
          {
            rec = rec.add(StrTag{name="pbpparentid";val=package.id["parentRef"]->name.toStr+":::"+row.data.get(parentCol)})
          }
        }
      }
      return rec
    }
    else
    {
      return null
    }
  }

  static Str:Obj getDict(SqlPackage package, SqlRow row)
  {
    try
    {
    Str targetId := ""
    Str:Obj dictMap := ["ts":"","val":""]
    package.rules.each |rule|
    {
      rule.mapping.each |tagname, sqlcol|
      {
        if(rule.tagmap[tagname].first.name=="ts")
        {
          dictMap.set("ts",row.data[sqlcol])
        }
        if(rule.tagmap[tagname].first.name=="val")
        {
          dictMap.set("val",row.data[sqlcol])
        }
      }
    }
    targetId=row.data[package.id["uniqueCol"]].toStr
    if(dictMap["val"].typeof == Int#)
    {
      dictMap["val"]=haystack::Number.fromStr(dictMap["val"].toStr)
    }
    if(dictMap["val"].typeof == sys::Float#)
    {
      dictMap["val"]=haystack::Number.fromStr(dictMap["val"].toStr)
    }
    map := ["target":targetId,"dict":Etc.makeDict(dictMap)]
    Logger.log.debug(map.toStr)
    return map
   }
   catch(Err e)
   {
     Logger.log.err("Error making dic", e)
     return [:]
   }

  }

  static File getPackageDir()
  {
    return (Env.cur.homeDir+`resources/sql/`).create
  }



}
