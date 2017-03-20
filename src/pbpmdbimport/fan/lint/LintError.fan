/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


const class LintError
{
    const Str message
    const Obj? data

    new make(|This| f) { f.call(this) }

    override Str toStr() { return "LintError(message: $message, data: ${data?.typeof})" }

    override Int hash()
    {
        return message.hash.xor(message.hash).xor(data.hash)
    }

    override Bool equals(Obj? that)
    {
        x := that as LintError

        if (x == null) return false

        return message == x.message &&
            data == x.data
    }
}
