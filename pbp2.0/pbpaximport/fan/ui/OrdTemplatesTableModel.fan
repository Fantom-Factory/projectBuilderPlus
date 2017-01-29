/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

class OrdTemplatesTableModel : TableModel
{
    private static const Str[] cols := ["Ord display template"]
    private static const Font defaultFont := Desktop.sysFont.toBold

    private Str[] rows
    new make(Str[] rows)
    {
        this.rows = rows
    }

    override Int numCols()
    {
        return 1
    }

    override Int numRows()
    {
        return rows.size
    }

    override Int? prefWidth(Int col)
    {
        switch (col)
        {
            case 0:
                return 370
        }

        return null
    }

    override Str text(Int col, Int row)
    {
        switch (col)
        {
            case 0:
                return rows[row]
        }

        return ""
    }

    override Str header(Int col)
    {
        return cols[col]
    }

    override Font? font(Int col, Int row)
    {
        if (col == 0 && row == 0)
        {
            return defaultFont
        }
        else
        {
            return null
        }
    }

    Void addTemplate(Str value)
    {
        rows.add(value)
    }

    Void deleteTemplate(Int index)
    {
        rows.removeAt(index)
    }

    Void editTemplate(Int index, Str value)
    {
        rows[index] = value
    }

    Str getTemplate(Int index)
    {
        return rows[index]
    }

    Void swap(Int indexA, Int indexB)
    {
        rows.swap(indexA, indexB)
    }
}
