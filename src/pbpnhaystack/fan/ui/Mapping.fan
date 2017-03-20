/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using [java] org.projecthaystack::HRow

/**
 * @author 
 * @version $Revision:$
 */
const class Mapping
{
    private const Unsafe rowUnsafe
    HRow row() { return rowUnsafe.val }

    private const Unsafe pointUnsafe
    Record point() { return pointUnsafe.val }

    new make(HRow row, Record point)
    {
        this.rowUnsafe = Unsafe(row)
        this.pointUnsafe = Unsafe(point)
    }

    Str rowDis() { row.dis }
    Str pointDis() { point.get("dis")?.val?.toStr ?: point.id.toStr }

    override Bool equals(Obj? that)
    {
        x := that as Mapping

        if (x == null) return false

        return row.id == x.row.id &&
            point.id == x.point.id
    }

    override Int hash()
    {
        return row.id.hash.
            xor(point.id.hash)
    }

    override Str toStr() { "Mapping('${row.id}' -> '${point.id}')" }
}
