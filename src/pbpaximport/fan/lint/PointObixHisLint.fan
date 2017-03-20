/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


const class PointObixHisLint : AbstractLint
{
    override protected Void doCheckLint(Point point, LintError[] lintErrors)
    {
        if (point.obixHis == null)
        {
            lintErrors.add(LintError() { it.message = "Point ${point.name} with ord ${point.ord} and markers ${point.markers} has null obixHis" })
        }
    }
}
