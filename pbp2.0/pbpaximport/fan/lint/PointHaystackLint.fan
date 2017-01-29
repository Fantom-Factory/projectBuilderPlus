/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

const class PointHaystackLint : AbstractLint
{
    override protected Void doCheckLint(Point point, LintError[] lintErrors)
    {
        if (point.id == null)
            lintErrors.add(LintError() { it.message = "Point ${point.name} has null id" })

        if (point.haystackId == null)
            lintErrors.add(LintError() { it.message = "Point ${point.name} has null haystackId" })

        if (point.kind == null)
            lintErrors.add(LintError() { it.message = "Point ${point.name} has null kind" })

        if (point.kind == "Number" && point.unit == null)
            lintErrors.add(LintError() { it.message = "Point ${point.name} is Number but has null unit" })
    }
}
