/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


const class MappingIdLint : AbstractLint
{
    override protected Void doCheckLint(Map point, LintError[] lintErrors)
    {
        logDevNum := point["logdevnum"]
        if(logDevNum == null)
        {
            lintErrors.add(LintError() { it.message = "logdevnum not found" })
        }

        logInst := point["loginst"]
        if(logInst == null)
        {
            lintErrors.add(LintError() { it.message = "loginst not found" })
        }
    }

}
