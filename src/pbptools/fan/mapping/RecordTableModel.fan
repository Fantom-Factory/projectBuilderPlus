/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using pbpcore

class RecordTableModel : TableModel
{
    private Record[] records

    new make(Record[] records)
    {
        this.records = records
    }

        override Int numRows() { records.size }
        override Int numCols() { 1 }

    override Str text(Int col, Int row)
    {
        switch (col)
        {
            case 0: return records[row].get("dis").val
            default: throw Err("Model.text - Invalid col index $col")
        }
    }

    override Str header(Int col)
    {
        switch (col)
        {
            case 0: return "Name"
            default: throw Err("Model.header - Invalid col index $col")
        }
    }

    Record[] getRecords(Int[] indices)
    {
        result := Record[,]
        indices.each |i|
        {
            result.add(records[i])
        }
        return result
    }


}
