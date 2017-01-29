/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


const class PointKindAndUnitLint : AbstractLint
{
    override protected Void doCheckLint(Point point, LintError[] lintErrors)
    {
        if (point.kind == null)
        {
            lintErrors.add(LintError() { it.message = "Point ${point.name} has null kind" })
        }

        if (point.unit == null)
        {
            lintErrors.add(LintError() { it.message = "Point ${point.name} has null unit" })
        }
    }
}
