/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using concurrent

class ObixMapperTable : Table
{

  new make(|This| f) : super(f)
  {
    f(this)
  }

}


class ObixMapperTableModel : TableModel
{
  AtomicRef refMap
  ObixItem[] rows
  Str[] cols := ["Name","Href","isHis","isPoint","hasHistory"]

  new make(ObixItem[] items)
  {
    refMap := [:]
    items.each |item|
    {
      if(item.isPoint) {refMap[item.obj.normalizedHref.pathOnly] = "Searching.."}
      else{refMap[item.obj.normalizedHref.pathOnly] = "Already a History" }
    }
    this.refMap = AtomicRef(refMap.toImmutable)
    rows=items
  }

  Void update(ObixItem[] items)
  {
    rows = items
  }
  ObixItem getRow(Int[] selected)
  {
    return rows[selected.first]
  }
  override Str header(Int col){return cols[col]}
  override Int numCols(){return cols.size}
  override Int numRows(){return rows.size}
  override Str text(Int col, Int row)
  {
    switch(col)
    {
      case 0:
        return rows[row].obj.name
      case 1:
        return rows[row].obj.normalizedHref.pathOnly.toStr
      case 2:
        return rows[row].obj.contract.toStr.contains("obix:History").toStr
      case 3:
        return rows[row].obj.contract.toStr.contains("obix:Point").toStr
      case 4:
        if((refMap.val as Map).containsKey(rows[row].obj.normalizedHref.pathOnly))
        {

          return (refMap.val as Map).get(rows[row].obj.normalizedHref.pathOnly).toStr
        }
        return ""
      default:
      return ""
    }
  }
}
