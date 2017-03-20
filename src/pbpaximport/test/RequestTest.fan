/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////



class RequestTest : Test
{
    Void testConn()
    {
    // TODO: test is not working because of enabled auth on demo site. including login/pass in source code is REALLY BAD IDEA
//        base := `http://demo.energydvr.com/`
//        reader := PointReader()
//        points := reader.readPoints(base)
//
//        echo("------------------------------------------------------------------------------------------------------")
//        points.each { echo(it) }
    }

    Void testReplace()
    {
        str := """a\$b\$c\$\$"""
        echo("$str \t" + str.replace("""\$""", """\\\$"""))


        uri := Uri.fromStr("""/obix/histories/RandolphCoWind1/AHU\$2d2\$2d2\$2fDamper/""")
        echo(uri)
    }

}
