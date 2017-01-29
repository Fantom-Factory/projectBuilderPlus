/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using sql

const class SqlRow
{
  const SqlCol[] cols
  const Str:Obj? data

  new make(Row row)
  {
    scratch := SqlCol[,]
    map := [:]
    row.cols.each |col|
    {
      scratch.push(SqlCol{name=col.name})
      map.add(scratch.peek.name,row[col])
    }
    cols = scratch
    data = map
  }
}
