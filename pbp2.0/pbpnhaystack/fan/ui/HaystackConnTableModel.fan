/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx

/**
 * @author 
 * @version $Revision:$
 */
class HaystackConnTableModel : TableModel
{
    private static const Str[] HEADERS := ["Connection", "Status"]

    private HaystackConnection[] connections

    new make(HaystackConnection[] connections)
    {
        this.connections = connections
    }

    HaystackConnection connection(Int index)
    {
        return connections[index]
    }

    override Int numRows() { connections.size }

    override Int numCols() { HEADERS.size }

    override Str header(Int col) { HEADERS[col] }

    override Str text(Int col, Int row)
    {
        switch (col)
        {
            case 0:
                return connections[row].name
            default:
                return connections[row].connected ? "OK" : "N/A"
        }
    }

    override Int? prefWidth(Int col)
    {
        switch (col)
        {
            case 0: return 165
            case 1: return 60
            default: return null
        }
    }
}
