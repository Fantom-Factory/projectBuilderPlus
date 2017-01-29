/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using projectBuilder
using pbpgui
using pbpcore

const class RecordComboItem
{
    const Record record

    new make(Record record)
    {
        this.record = record
    }

    override Str toStr()
    {
        return record.get("dis")?.val ?: "N/A"
    }

}
