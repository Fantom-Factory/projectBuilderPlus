/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


const class Page
{
    const Uri base
    const Str name
    const Str? title
    const Uri res
    const Str? pxFile
    const Str? disMacro


    new make(|This|? f := null)
    {
        f?.call(this)
    }

    new makeCopy(Page page, |This|? f := null)
    {
        this.base = page.base
        this.name = page.name
        this.title = page.title
        this.res = page.res
        this.pxFile = page.pxFile
        this.disMacro = page.disMacro

        f?.call(this)
    }

    override Str toStr() { return "Page(base:$base, name:$name, title: $title, res:$res, pxFile=$pxFile)" }

    override Int hash()
    {
        h := base.hash.xor(name.hash).xor(res.hash)

        if (pxFile != null) h = h.xor(pxFile.hash)
        if (title != null) h = h.xor(title.hash)
        if (disMacro != null) h = h.xor(disMacro.hash)

        return h
    }

    override Bool equals(Obj? that)
    {
        x := that as Page

        if (x == null) return false

        return base == x.base &&
            name == x.name &&
            res == x.res &&
            title == x.title &&
            pxFile == x.pxFile &&
            disMacro == x.disMacro
    }
}
