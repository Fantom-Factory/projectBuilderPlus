/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using pbpcore

abstract class AbstractTemplateTableModel : TableModel
{
    File templateDir := FileUtil.templateDir
    File[] rows := [,]
    Str[] cols := [,]

    abstract Void update()
    abstract File[] getRows(Int[] selected)

    override Int numCols() { return cols.size }
    override Int numRows() { return rows.size }

    override Str header(Int col)
    {
        return cols[col]
    }
}
