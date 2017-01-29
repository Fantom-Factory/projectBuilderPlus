/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

class LintChecker
{
    LintError[] results { private set }
    private Type[] lints

    new make(Type[] lints)
    {
        this.lints = lints
        this.results = LintError[,]
    }

    Void checkLints(Obj? data)
    {
        results.clear

        lints.each |lintType|
        {
            lint := lintType.make as Lint ?: throw Err("Type $lintType is not ${Lint#}")
            results.addAll( lint.checkLint(data) )
        }
    }
}
