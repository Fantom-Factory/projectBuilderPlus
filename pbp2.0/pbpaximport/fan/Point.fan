/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


const class Point
{
    const Str? id
    const Page page
    const Str name
    const Str[] markers
    const Uri? obix
    const Uri? obixHis

    const Str? haystackId
    const Str? axType
    const Str? curStatus
    const Str? axSlotPath
    const Float? precision
    const Obj? curVal
    const Str? actions
    const Str? enum

    const Str? kind
    const Str? unit

    const Str? ord

    const Str? navName
    const Str? disMacro

    new make(|This|? f := null)
    {
        f?.call(this)

        //
        // Build axSlotPath
        //
        pointUri := Uri(this.ord.replace("station:|", "").replace("slot:", ""))

        if (pointUri.isAbs)
        {
            this.axSlotPath = "slot:$pointUri"
        }
        else
        {
            // Remove `obix/config` as the start of URI
            pageUri := Uri("/" + this.page.res.path[2..-1].join("/") + "/")

            // Combine URI
            this.axSlotPath = "slot:" + (pageUri + pointUri).toStr()
        }
    }

    new makeCopy(Point point, |This|? f := null)
    {
        this.id = point.id
        this.page = point.page
        this.name = point.name
        this.markers = point.markers
        this.obix = point.obix
        this.obixHis = point.obixHis

        this.haystackId = point.haystackId
        this.navName = point.navName
        this.axType = point.axType
        this.curStatus = point.curStatus
        this.axSlotPath = point.axSlotPath
        this.precision = point.precision
        this.curVal = point.curVal
        this.actions = point.actions
        this.enum = point.enum

        this.kind = point.kind
        this.unit = point.unit

        this.ord = point.ord

        this.navName = point.navName
        this.disMacro = point.disMacro

        f?.call(this)
    }

    override Str toStr()
    {
        return "Point(id:$id, name:$name, markers:$markers, page:$page, ord:$ord, obix:$obix, obixHis:$obixHis, haystackId:$haystackId, navName:$navName, axType:$axType, curStatus:$curStatus, axSlotPath:$axSlotPath, precision:$precision, curVal:$curVal, actions:$actions, enum:$enum, kind:$kind, unit:$unit)"
    }

    override Int hash()
    {
        h := page.hash.xor(name.hash).xor(markers.hash)

        if (id != null) h = h.xor(id.hash)
        if (obix != null) h = h.xor(obix.hash)
        if (obixHis != null) h = h.xor(obixHis.hash)
        if (kind != null) h = h.xor(kind.hash)
        if (unit != null) h = h.xor(unit.hash)
        if (ord != null) h = h.xor(ord.hash)

        if (haystackId != null) h = h.xor(haystackId.hash)
        if (navName != null) h = h.xor(navName.hash)
        if (axType != null) h = h.xor(axType.hash)
        if (curStatus != null) h = h.xor(curStatus.hash)
        if (axSlotPath != null) h = h.xor(axSlotPath.hash)
        if (precision != null) h = h.xor(precision.hash)
        if (curVal != null) h = h.xor(curVal.hash)
        if (actions != null) h = h.xor(actions.hash)
        if (enum != null) h = h.xor(enum.hash)
        if (navName != null) h = h.xor(navName.hash)
        if (disMacro != null) h = h.xor(disMacro.hash)

        return h
    }

    override Bool equals(Obj? that)
    {
        x := that as Point
        if (x == null) return false
        return x.hash == this.hash
    }
}

