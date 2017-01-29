/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpcore

class RecordTableModel : TableModel
{
    private static const Str[] cols := ["Id", "Name", "Lints"]

    private static const Color RED := Color.red.lighter(0.9f)
    RecordTreeDto[] rows { private set }
    [Str:LintError[]]? lintErrorIndex { private set }



    new make(RecordTreeDto[] rows,[Str:LintError[]]? lintErrorIndex := null)
    {
        this.lintErrorIndex = lintErrorIndex
        this.rows = process(rows)
    }

    override Int numCols()
    {
        return cols.size
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
                return 110
            case 1:
                return 110
            case 2:
                return 470
        }

        return null
    }


    override Str text(Int col, Int row)
    {
        id := getId(row)
        switch (col)
        {
            case 0:
                return id
            case 1:
                return formatName(rows[row].record.get("dis")?.val as Str)
            case 2:
                errors := lintErrorIndex?.get(id)
                return (errors == null || errors.isEmpty ? "" : errors.size.toStr)
        }

        return ""
    }

    internal Str formatName(Str? name)
    {
        if(name == null) return "Not specified" // TODO: localize
        return name
    }


    override Color? bg(Int col, Int row)
    {
        errors := lintErrorIndex?.get(getId(row))
        return (errors != null && !errors.isEmpty ? RED : null)
    }

    internal Str getId(Int row)
    {
        return rows[row].record.id.toStr
    }

    override Str header(Int col)
    {
        return cols[col]
    }

    internal RecordTreeDto[] process(RecordTreeDto[] dtos)
    {
        list := RecordTreeDto[,]
        dtos.each|dto|
        {
            list.add(dto)
            list.addAll(process(dto.children))
        }
        return list
    }

}
