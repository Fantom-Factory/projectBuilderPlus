/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////



abstract const class BaseLint : Lint
{
    override LintError[] checkLint(Obj? data)
    {
        dto := data as RecordTreeDto ?: throw Err("Data should be of type ${RecordTreeDto#} not ${data?.typeof}")

        lintErrors := LintError[,]
        doCheckLint(dto, lintErrors)
        dto.children.each|child|
        {
            doCheckLint(child, lintErrors)
        }
        return lintErrors
    }

    abstract protected Void doCheckLint(RecordTreeDto dto, LintError[] lintErrors)
}
