/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt

/**
 * @author 
 * @version $Revision:$
 */
class MappingTableModel : TableModel
{
    private static const Str[] cols := ["Haystack", "", "Point"]

    private Mapping[] rows

    new make(Mapping[] rows)
    {
        this.rows = rows
    }

    override Int numRows() { rows.size }
    override Int numCols() { cols.size }
    override Str header(Int col) { cols[col] }
    override Str text(Int col, Int row)
    {
        switch (col)
        {
            case 0:
                return rows[row].rowDis
            case 1:
                return "->"
            case 2:
                return rows[row].pointDis
            default:
                return ""
        }
    }

    override Int? prefWidth(Int col)
    {
        switch (col)
        {
            case 0:
            case 2:
                return 330
            case 1:
                return 35
            default:
                return null
        }
    }

    Mapping? getRow(Int idx) { rows.getSafe(idx) }

}
