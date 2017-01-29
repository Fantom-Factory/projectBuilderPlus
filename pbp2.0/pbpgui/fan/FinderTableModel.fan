/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt

class FinderTableModel : TableModel {

  Str[] rows
  Str[] filteredRows

  new make(Str[] rows) {
      this.rows = rows
      this.filteredRows = rows
  }

  Str[] headers := ["Name"]

  override Str header(Int col) {
    headers[col]
  }

  override Int numCols() {
    return 1
  }

  override Int numRows() {
    return filteredRows.size
  }

  override Str text(Int col, Int row) {
    return filteredRows[row]
  }

  override Int? prefWidth(Int col) {
    return 500
  }

  Str getRow(Int idx) {
    return filteredRows[idx]
  }

  Void filter(Str filter) {
    filteredRows = rows.findAll |row| {
      row.contains(filter)
    }
  }

  Void resetFilter() {
    filteredRows = rows.dup
  }

}
