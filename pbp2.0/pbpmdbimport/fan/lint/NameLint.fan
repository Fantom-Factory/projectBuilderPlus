/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


const class NameLint : AbstractLint
{
    override protected Void doCheckLint(Map point, LintError[] lintErrors)
    {
        name := point["objname"]
        if(name == null)
        {
            lintErrors.add(LintError() { it.message = "objname not found" })
        }
    }

}
