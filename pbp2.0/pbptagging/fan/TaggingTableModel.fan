/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt

class TaggingTableModel : TableModel
{
    private static const Str[] cols := ["File name", "Tags", "Cnt"]

    private TaggingRow[] rows
    private TaggingRow[] filteredRows

    new make(TaggingRow[] rows)
    {
        this.rows = rows
        this.filteredRows = rows.dup
    }

    override Int? prefWidth(Int col)
    {
        switch (col)
        {
            case 0:
                return 150
            case 1:
                return 530
            case 2:
                return 50
        }

        return null
    }

    override Str text(Int col, Int row)
    {
        switch (col)
        {
            case 0:
                return filteredRows[row].fileName
            case 1:
                return filteredRows[row].tagsStr
            case 2:
                return filteredRows[row].tagsCount.toStr
        }

        return ""
    }

    override Str header(Int col)
    {
        return cols[col]
    }

    override Int numCols()
    {
        return cols.size
    }

    override Int numRows()
    {
        return filteredRows.size
    }

    TaggingRow getRow(Int idx)
    {
        return filteredRows[idx]
    }

    Void filter(File? file, Regex? filter := null)
    {
        filteredRows = rows.findAll |TaggingRow item -> Bool|
        {
            Bool filterFile := (file == null || file == item.file)
            Bool filterStr := (filter == null || filter.matches(item.matchStr))

            return filterStr && filterFile
        }
    }

    Void resetFilter()
    {
        filteredRows = rows.dup
    }

}
