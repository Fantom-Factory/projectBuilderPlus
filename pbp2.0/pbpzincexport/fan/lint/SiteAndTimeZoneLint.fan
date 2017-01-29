/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using haystack

const class SiteAndTimeZoneLint : BaseLint
{
    override protected Void doCheckLint(RecordTreeDto dto, LintError[] lintErrors)
    {
        record := dto.record.getDict
//        echo("checking ${Etc.dictToMap(record)}")
        if(record.has("site") && record.missing("tz"))
        {
            lintErrors.add(LintError() { it.message = "Site with id ${dto.record.id} has no time zone specified" })
        }
    }
}
