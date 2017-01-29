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
        point := data as Point ?: throw Err("Data should be of type ${Point#} not ${data?.typeof}")

        lintErrors := LintError[,]
        doCheckLint(point, lintErrors)
        return lintErrors
    }

    abstract protected Void doCheckLint(Point point, LintError[] lintErrors)
}
