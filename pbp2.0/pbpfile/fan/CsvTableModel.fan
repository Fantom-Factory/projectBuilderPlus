/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

**
** Model to represent content of the file.
**
class CsvTableModel : TableModel
{
  Str[] headers := [,]
  private Str[][] data := [,]
  
  override Int numCols() { return headers.size }  
  override Int numRows() { return data.size }  
  override Str header(Int col) { return headers[col] }
  
  //override Halign halign(Int col) { return col == 1 ? Halign.right : Halign.left }
  //override Font? font(Int col, Int row) { return col == 2 ? Font {name=Desktop.sysFont.name; size=Desktop.sysFont.size-1} : null }
  //override Color? fg(Int col, Int row)  { return col == 2 ? Color("#666") : null }
  //override Color? bg(Int col, Int row)  { return col == 2 ? Color("#eee") : null }
  
  new make(InStream in, Int separator := ',')
  {
    parse(in, separator)
  }

  Void parse(InStream in, Int separator := ',')
  {
    headers = in.readLine.split(separator)
    if (headers.size < 2)
      throw CsvParseErr("Values must be separated by '${separator}' and have more than 1 columns.")

    line := in.readLine
    while (line != null)
    {
      data.push(line.split(separator))
      line = in.readLine
    }
  }

  override Str text(Int col, Int row)
  {
    return data[row][col]
  }

  Str? getData(Str colName, Int row)
  {
    col := headers.index(colName)
    return data[row][col]
  }
  
  /*override Int sortCompare(Int col, Int row1, Int row2)
  {
    return 0
  }*/
  
  /*override Image? image(Int col, Int row)
  {
    return null    
  }*/
}

const class CsvParseErr : Err
{
  new make(Str msg) : super(msg)
  {}
}
