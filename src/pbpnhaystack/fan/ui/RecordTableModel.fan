/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using pbpcore

/**
 * @author 
 * @version $Revision:$
 */
class RecordTableModel : TableModel
{
    private static const Int desktopFontSize := Desktop.sysFont.size.toInt

    private Record[] rows
    private Str[] cols
    private Int[] prefWidths

    new make(Record[] rows)
    {
        this.rows = rows.dup
        this.cols = sortCols(extractColsFromRows(this.rows))
        this.prefWidths = calcPrefWidths(this, this.cols, this.rows)
    }

    override Int? prefWidth(Int col) { prefWidths[col] }
    override Int numRows() { rows.size }
    override Int numCols() { cols.size }
    override Str header(Int col) { cols[col] }
    override Str text(Int col, Int row)
    {
        v := rows[row].get(cols[col])
        return (v is MarkerTag ? "√" : (v?.val?.toStr ?: ""))
    }

    Record? getRow(Int idx) { rows.getSafe(idx) }

    private static Int[] calcPrefWidths(TableModel model, Str[] cols, Record[] rows)
    {
        return cols.map |col, colIdx -> Int|
        {
            prefSize := model.header(colIdx).size * desktopFontSize + 10

            return rows.reduce(prefSize) |Int reduction, Record row -> Int|
            {
                return reduction.max( (row.get(col)?.val?.toStr?.size ?: 0) * desktopFontSize + 10 )
            }
        }
    }

    private static Str[] sortCols(Str[] cols)
    {
        priority := ["id": 0, "dis": 1]

        cols.sort |Str a, Str b -> Int|
        {
            p1 := priority[a]
            p2 := priority[b]

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

    private static Str[] extractColsFromRows(Record[] rows)
    {
        return (rows.reduce([Str:Bool][:] { it.ordered = true }) |[Str:Bool] set, Record row -> [Str:Bool]|
        {
            row.data.each |tag|
            {
                set[tag.name] = true
            }
            return set
        } as [Str:Bool])?.keys ?: throw Err()
    }
}
