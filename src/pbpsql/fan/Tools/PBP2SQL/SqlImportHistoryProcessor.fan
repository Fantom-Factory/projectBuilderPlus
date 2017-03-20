/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using concurrent
using fwt

class SqlImportHistoryProcessor : SqlProcessor
{
  new make(){}

  override SqlPackageEditPane[] getEditPanes(AtomicRef listRef)
  {
    toReturn := [,]
    toReturn.push(SqlPackageEditPane("History Rule", null, [Tag{name="ts"; val=""},Tag{name="val"; val=""}], listRef, ["type":Record#]))
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

    return SqlPackage{
      it.rules = rules
      id= SqlPackageId{
        idVal =["name":editPane.name, "type":editPane.options["type"], "uniqueCol":editPane.pbpidselector.text]
      }
    }
  }


}
