/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using [java] org.projecthaystack::HRow
using [java] org.projecthaystack::HCol
using [java] org.projecthaystack::HMarker

/**
 * @author 
 * @version $Revision:$
 */
class HRowTableModel : TableModel
{
    private static const Int desktopFontSize := Desktop.sysFont.size.toInt

    private HRow[] rows
    private HCol[] cols
    private Int[] prefWidths

    new make(HRow[] rows)
    {
        this.rows = rows.dup
        this.cols = sortCols(extractColsFromRows(this.rows))
        this.prefWidths = calcPrefWidths(this, this.cols, this.rows)
    }

    override Int? prefWidth(Int col) { prefWidths[col] }
    override Int numRows() { rows.size }
    override Int numCols() { cols.size }
    override Str header(Int col) { cols[col].dis }
    override Str text(Int col, Int row)
    {
        v := rows[row].get(cols[col].name, false)
        return (v is HMarker ? "√" : (v?.toString ?: ""))
    }

    HRow? getRow(Int idx) { rows.getSafe(idx) }

    private static Int[] calcPrefWidths(TableModel model, HCol[] cols, HRow[] rows)
    {
        return cols.map |col, colIdx -> Int|
        {
            prefSize := model.header(colIdx).size * desktopFontSize + 10

            return rows.reduce(prefSize) |Int reduction, HRow row -> Int|
            {
                return reduction.max( (row.get(col, false)?.toStr?.size ?: 0) * desktopFontSize + 10 )
            }
        }
    }

    private static HCol[] sortCols(HCol[] cols)
    {
        priority := ["id": 0, "dis": 1]

        cols.sort |HCol a, HCol b -> Int|
        {
            p1 := priority[a.name]
            p2 := priority[b.name]

            if (p1 != null && p2 != null)
            {
                return p1 - p2
            }
            else
            {
                if (p1 != null) { return -1 }
                else if (p2 != null) { return 1 }
                else { return 0 }
            }
        }

        return cols
    }

    private static HCol[] extractColsFromRows(HRow[] rows)
    {
        set := [Str:HCol][:] { it.ordered = true }
        rows.each |row|
        {
            grid := row.grid()
            for (i := 0; i < grid.numCols(); i++)
            {
                set[grid.col(i).name] = grid.col(i)
            }
        }

        return set.vals
    }
}
