/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////



class EscapeUtilsTest : Test
{
    Void testIt()
    {
        verifyEq("-/", EscapeUtils.unescapeNiagara("\$2d\$2f"))
        verifyEq(".-./.", EscapeUtils.unescapeNiagara(".\$2d.\$2f."))

    }
}
