/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


const class ImportDto
{
    const Point[] points
    const [Page:Point[]] pageIndex

    new make(|This|? f := null) { f?.call(this) }

    new makeCopy(ImportDto importDto, |This|? f := null)
    {
        this.points = importDto.points
        this.pageIndex = importDto.pageIndex

        f?.call(this)
    }

    override Str toStr() { return "ImportDto(points: $points, pageIndex.size: $pageIndex.size)" }

    override Int hash()
    {
        return points.hash.xor(pageIndex.hash)
    }

    override Bool equals(Obj? that)
    {
        x := that as ImportDto

        if (x == null) return false

        return points == x.points &&
            pageIndex == x.pageIndex
    }
}
