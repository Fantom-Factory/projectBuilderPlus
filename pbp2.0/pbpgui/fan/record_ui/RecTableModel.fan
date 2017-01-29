/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore
using concurrent
using haystack
using pbplogging

class RecTableModel : TableModel, UiUpdatable
{
  //Str:Record recMap
  Int defEndRange
  const Str defVal := "empty"
  const Int desktopFontSize := Desktop.sysFont.size.toInt
  Project? currentProject := null
  Actor? controller := null
  Table? table := null

  new make(Map recMap, Project? currentproject:=null)
  {
    currentProject = currentproject
    update(recMap);
  }
  Record[] auxRows := [,]
  Record[] rows := [,]
  Str:[Str:Obj] textrows := [:]
  Str[] cols := [,]

  Void update(Map recMap, Range? range := null) //TODO: Pagination Support
  {
    rows.clear
    cols.clear
    textrows.clear
    rows = [,].addAll(recMap.vals)
    auxRows = [,].addAll(recMap.vals)
    rows.each |rec|
    {
      Str:Obj datasheet := [:]
      datasheet.addList(rec.data)|Tag t-> Str|{
        if(!cols.contains(t.name)){cols.push(t.name)}
        return t.name
      }
      textrows.set(rec.id.toStr,datasheet)
    }

    //Reorganizing Columns
    cols.remove("dis")
    cols.remove("id")
    if (cols.contains("mod"))
    {
      cols.remove("mod")
      cols.sort
      cols = ["id","dis"].addAll(cols).add("mod")
    } else {
      cols.sort
      cols = ["id","dis"].addAll(cols)
    }
    if (this.controller != null)
    {
      this.controller.send(rows.size)
    }
  }

  override Void updateUi(Obj? params := null)
  {
    Range? range := params
    if(range != null)
    {
      this.curModelRange = range
      rows.clear
      rows.addAll(getPagedRecs())
    }
  }

  Range? curModelRange
  TableSorting? curModelSort

  TableSorting? curTableSort()
  {
    if (this.table?.sortCol == null) return null
    return TableSorting(
      header(this.table.sortCol),
      this.table.sortMode
    )
  }

  Record[] getPagedRecs()
  {
    if (this.curModelSort != null)
    {
      tagName := this.curModelSort.colName

      innerSortFunc := |Record r1, Record r2->Int| {
        v1 := r1.get(tagName)?.val
        v2 := r2.get(tagName)?.val

        if (v1 == null)             return (v2 == null) ? 0 : -1
        if (v2 == null)             return (v1 == null) ? 0 : 1
        if (v1.typeof != v2.typeof) return -1

        return v1 <=> v2;
      }

      sortFunc := (this.curModelSort.mode == SortMode.up)
                  ? |Record a, Record b->Int| { return innerSortFunc(a, b) }
                  : |Record a, Record b->Int| { return innerSortFunc(b, a) }
      auxRows.sort(sortFunc)
    }
    return auxRows.getRange(this.curModelRange)
  }

  Void attachController(Actor controller)
  {
    this.controller = controller
  }


  Record getRow(Int selected)
  {
    return rows[selected]
  }

  Record[] getRows(Int[] selected)
  {
    toreturn := [,]
    selected.each |index|
    {
      toreturn.push(rows[index])
    }
    return toreturn
  }

  override Int numRows() { return rows.size }
  override Int numCols() { return cols.size }
  override Str header(Int col) { return cols[col] }

  override Str text(Int col, Int row)
  {
    if (curTableSort != curModelSort)
    {
      // If current UI sorting is not the same as current model sorting,
      // we call updateUi(). updateUi() will redo sorting/paging of the model
      curModelSort = curTableSort
      updateUi(curModelRange)
    }

    Tag? targettag := textrows[rows[row].id.toStr][cols[col]]
    Str? tagText := null
    val := (targettag != null ? targettag.val : null)
    if(targettag != null && val!= null)
    {
      tagText = val.toStr
      if(val.typeof == Ref# && !(val as Ref).isNull)
      {
        //TODO:: USE INDEXING TO SOLVE THIS PROBLEM
        [Str:Obj]? targetmap := textrows[val.toStr]
        Str? text := ""
        // TODO: this sould probably use disMacro as a fallback
        if(targetmap != null && targetmap["dis"] != null)
        {
          text = (targetmap["dis"] as Tag).val
        }
        else
        {
          Record? rec := currentProject.database.getById(val.toStr)
          if(rec != null && rec.get("dis") != null)
          {
            text = rec.get("dis").val
          }
          else
          {
            text=null
          }
        }
        return text?:""
      }
      if(targettag.typeof==MarkerTag#)
      {
        return "√"
      }
    }
    return tagText?:""
  }

  //TODO: Refactor with Font.width
  override Int? prefWidth(Int col)
  {
    Int startingsize := header(col).size*desktopFontSize
    //Int startingsize := Desktop.sysFont.width(header(col))
    Int prefsize := startingsize
    rows.each |row, index|
    {
      Str field := text(col, index)
      if(field.size* desktopFontSize > prefsize)
      {
        prefsize = field.size*desktopFontSize
      }
    }
    return prefsize
  }

}

class TableSorting
{
  Str colName
  SortMode mode

  new make(Str colName, SortMode mode)
  {
    this.colName = colName
    this.mode = mode
  }

  override Str toStr()
  {
    return "TableSorting colName=$colName, mode=$mode"
  }

  override Bool equals(Obj? that)
  {
    if (that == null) return false

    return that.hash == this.hash
  }

  override Int hash()
  {
    return colName.hash.xor(mode.hash)
  }
}
