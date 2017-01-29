/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

class PointTableModel : TableModel
{
    private Str[] cols := [,]

    private static const Color RED := Color.red.lighter(0.9f)

    Map[] rows { private set }
    [Map:LintError[]]? lintErrorIndex { private set }

    private [Int:Str] templates

    new make(ImportDto dto, [Map:LintError[]]? lintErrorIndex := null)
    {
        this.lintErrorIndex = lintErrorIndex
        this.rows = dto.points

        if(!rows.isEmpty)
        {
            cols = rows.first.keys
        }

        this.templates = Int:Str[:]
    }

    override Int numCols()
    {
        return cols.size
    }

    override Int numRows()
    {
        return rows.size
    }

    override Str text(Int col, Int row)
    {
        colName := cols[col]
        rowData :=  rows[row]
        cellData :=  rowData[colName]
        if(cellData != null)
            return formatCell(cellData)

        return ""
    }


    internal Str formatCell(Obj data)
    {
        switch(Type.of(data))
        {
            case Str#:
                return data
            case Int#:
            case Float#:
            case DateTime#:
            case Bool#:
                return data.toStr

            default:
            return data->toString
        }
    }

    override Color? bg(Int col, Int row)
    {
        errors := lintErrorIndex?.get(rows[row])
        return (errors != null && !errors.isEmpty ? RED : null)
    }

    override Str header(Int col)
    {
        return cols[col]
    }

}
