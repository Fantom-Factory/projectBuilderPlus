/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using fwt
using gfx
using projectBuilder
using pbpgui
using pbpcore
using haystack

const class ImportValue
{
    const pbpaximport::Point axPoint
    const Record siteRecord
    const Record equipRecord
    const pbpcore::Point pbpPoint

    new make(pbpaximport::Point axPoint, Record siteRecord, Record equipRecord, pbpcore::Point pbpPoint)
    {
        this.axPoint = axPoint
        this.siteRecord = siteRecord
        this.equipRecord = equipRecord
        this.pbpPoint = pbpPoint
    }

    new makeCopy(ImportValue importValue, |This|? f := null) : this.make(importValue.axPoint, importValue.siteRecord, importValue.equipRecord, importValue.pbpPoint)
    {
        f?.call(this)
    }

    override Str toStr() { return "ImportValue(axPoint:$axPoint, siteRecord:$siteRecord, equipRecord:$equipRecord, pbpPoint:$pbpPoint)" }

    override Int hash()
    {
        return axPoint.hash.xor(siteRecord.hash).xor(equipRecord.hash).xor(pbpPoint.hash)
    }

    override Bool equals(Obj? that)
    {
        x := that as ImportValue

        if (x == null) return false

        return axPoint == x.axPoint &&
            siteRecord == x.siteRecord &&
            equipRecord == x.equipRecord &&
            pbpPoint == x.pbpPoint
    }
}
