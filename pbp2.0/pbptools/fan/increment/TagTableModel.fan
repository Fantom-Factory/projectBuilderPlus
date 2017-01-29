/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using pbpcore

class TagTableModel : TableModel
{
    private Tag[] tags

    new make(Tag[] tags)
    {
        this.tags = tags
    }

    override Int numRows() { tags.size }
    override Int numCols() { 2 }

    override Str text(Int col, Int row)
    {
        switch (col)
        {
            case 0: return tags[row].name
            case 1: return tags[row].typeof.name
            default: throw Err("Model.text - Invalid col index $col")
        }
    }

    override Str header(Int col)
    {
        switch (col)
        {
            case 0: return "Tag"
            case 1: return "Type"
            default: throw Err("Model.header - Invalid col index $col")
        }
    }

    Tag[] getTags(Int[] indices)
    {
        result := Tag[,]
        indices.each |i|
        {
            result.add(tags[i])
        }
        return result
    }
}
