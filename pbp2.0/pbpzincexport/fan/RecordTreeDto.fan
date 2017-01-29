/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore

const class RecordTreeDto
{
    const RecordTreeDto? parent
    const Record record
    const RecordTreeDto[] children

    new make(|This| f)
    {
        f(this)
    }

}
