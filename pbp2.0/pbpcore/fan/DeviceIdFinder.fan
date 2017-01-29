/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using [java] fanx.interop::Interop
using [java] java.nio::ByteBuffer
using [java] java.nio::CharBuffer
using [java] java.nio.charset::Charset
using [java] java.nio.charset::CharsetDecoder
using [java] java.nio.charset::CodingErrorAction

/**
 * @author 
 * @version $Revision:$
 */

class DeviceIdFinder
{
    static Str findId()
    {
        switch (Env.cur.os)
        {
            case "win32":
                return findIdOnWindows()
            case "macosx":
                return findIdOnMac()
            default:
                throw Err("Unsupported OS $Env.cur.os")
        }
    }

    private static Str findIdOnMac()
    {
        output := cmd(["sh", "-c", "system_profiler SPHardwareDataType | awk '/Serial Number/ { print \$4; }'"])

        id := output.splitLines().first.trim

        return (!id.isEmpty ? id : throw Err("Unable to find device id from [${output}]"))
    }

    private static Str findIdOnWindows()
    {
        wmics := [
            "wmic",
            "%WINDIR%\\System32\\wbem\\wmic.exe",
            "%WINDIR%/System32/wbem/wmic.exe",
            "%WINDIR%\\SysWOW64\\wbem\\wmic.exe",
            "%WINDIR%/SysWOW64/wbem/wmic.exe",
            "c:\\Windows\\System32\\wbem\\wmic.exe",
            "c:\\Windows\\SysWOW64\\wbem\\wmic.exe",
            "c:/Windows/System32/wbem/wmic.exe",
            "c:/Windows/SysWOW64/wbem/wmic.exe"
        ]

        output := wmics.eachWhile |wmic|
        {
            try
            {
                return cmd([wmic, "bios", "get", "serialnumber"])
            }
            catch
            {
                return null
            }
        } as Str ?: throw Err("Unable to find wmic")

        lines := output.splitLines().findAll(|line -> Bool| { !line.trim.isEmpty })

        if (lines.size < 2) throw Err("Invalid output from wmic [{$output}]")
        if (!lines[0].startsWith("SerialNumber")) throw Err("Invalid output from wmic. Line1 ${lines[0]}")

        id := lines[1].trim

        return (!id.isEmpty ? id : throw Err("Unable to find device id from [${output}]"))
    }

    private static Str cmd(Str[] command)
    {
        buf := Buf()

        proc := Process(command)
        proc.out = buf.out
        proc.run.join

        return loadStrFromBuf(buf.flip.readAllBuf)
    }


    static Str loadStrFromBuf(Buf buf)
    {
        CharsetDecoder utf8Decoder := Charset.forName("UTF-8").newDecoder()
        utf8Decoder.onMalformedInput(CodingErrorAction.IGNORE)
        utf8Decoder.onUnmappableCharacter(CodingErrorAction.IGNORE)
        CharBuffer parsed := utf8Decoder.decode(Interop.toJava(buf))
        return parsed.toString()
    }

    static Void main(Str[] args)
    {
        echo("[$findId]")
    }
}
