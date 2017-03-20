/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


const class PointObixAndIdLint : AbstractLint
{
    override protected Void doCheckLint(Point point, LintError[] lintErrors)
    {
        if (point.obix == null)
        {
            lintErrors.add(LintError() { it.message = "Point ${point.name} has null obix" })
        }

        if (point.id == null)
        {
            lintErrors.add(LintError() { it.message = "Point ${point.name} has null id" })
        }
    }
}
