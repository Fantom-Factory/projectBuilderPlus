/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


abstract const class AbstractLint : Lint
{
    override LintError[] checkLint(Obj? data)
    {
        point := data as Map ?: throw Err("Data should be of type ${Map#} not ${data?.typeof}")

        lintErrors := LintError[,]
        doCheckLint(point, lintErrors)
        return lintErrors
    }

    abstract protected Void doCheckLint(Map point, LintError[] lintErrors)
}
