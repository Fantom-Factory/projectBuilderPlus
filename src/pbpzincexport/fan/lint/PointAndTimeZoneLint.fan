/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////



const class PointAndTimeZoneLint : BaseLint
{
    override protected Void doCheckLint(RecordTreeDto dto, LintError[] lintErrors)
    {
        record := dto.record.getDict
//        echo("checking ${Etc.dictToMap(record)}")
        if(record.has("point") && record.missing("tz"))
        {
            lintErrors.add(LintError() { it.message = "Point with id ${dto.record.id} has no time zone specified" })
        }
    }
}
