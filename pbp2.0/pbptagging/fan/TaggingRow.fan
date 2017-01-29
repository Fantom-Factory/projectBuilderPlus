/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////



const class TaggingRow
{
    const File file
    const Str fileName
    const Str[] tags
    const Str tagsStr
    const Int tagsCount
    const Str matchStr

    new make(File file, Str[] tags)
    {
        this.file = file
        this.fileName = file.name
        this.tags = tags
        this.tagsCount = tags.size
        this.tagsStr = tags.join(" ")
        this.matchStr = "$fileName $tagsStr"
    }

}
