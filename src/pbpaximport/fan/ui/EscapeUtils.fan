/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


class EscapeUtils
{
    private static const Regex regexEsc := Regex.fromStr("\\\$([a-fA-F0-9]{2})")

    static Str unescapeNiagara(Str value)
    {
        matcher := regexEsc.matcher(value)

        escapes := Str[,]
        while (matcher.find)
        {
            escapes.add(matcher.group(1))
        }

        escapes.unique.each |esc|
        {
            value = value.replace("\$${esc}", Int.fromStr(esc, 16).toChar)
        }

        return value
    }
}
