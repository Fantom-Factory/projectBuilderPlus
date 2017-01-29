/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using haystack
using [java] org.projecthaystack::HGridBuilder
using [java] org.projecthaystack::HRow
using [java] org.projecthaystack::HMarker
using [java] org.projecthaystack::HDateTime
using [java] org.projecthaystack::HDate
using [java] org.projecthaystack::HRef
using [java] org.projecthaystack::HBool
using [java] org.projecthaystack::HUri
using [java] org.projecthaystack::HTime
using [java] org.projecthaystack::HNum
using [java] org.projecthaystack::HStr
using [java] org.projecthaystack::HTimeZone
using [java] org.projecthaystack.io::HZincWriter

/**
 * @author 
 * @version $Revision:$
 */
class MappingActorTest : Test
{
    Void testCopyTags()
    {
        cols := ["marker", "dateTimeTz", "dateTime", "date", "ref", "bool", "uri", "time", "num", "str"]


        b := HGridBuilder()
        cols.each |col| { b.addCol(col) }

        HaystackUtils.addRow(b, [
            HMarker.VAL,
            HDateTime.make(HDate.make(2014, 1, 29), HTime.make(9, 54, 13, 100), HTimeZone.make("Prague")),
            HDateTime.now,
            HDate.make(2014, 1, 29),
            HRef.make("bflmpsvz"),
            HBool.make(true),
            HUri.make("http://www.google.com"),
            HTime.make(9, 54, 13),
            HNum.make(123.456f, "m"),
            HStr.make("muhaha"),
        ])

        echo(HNum.make(123.456f, "m").val.typeof)

        grid := b.toGrid()

        tags := Tag[,]
        cols.each |col|
        {
            AbstractMappingActor.copyTagsFromRow(grid.row(0), col, tags)
        }

        verifyEq(tags.size, 10)

        verifyEq(tags[0].typeof, MarkerTag#)
        verifyEq(tags[1].typeof, DateTimeTag#)
        verifyEq(tags[2].typeof, DateTimeTag#)
        verifyEq(tags[3].typeof, DateTag#)
        verifyEq(tags[4].typeof, RefTag#)
        verifyEq(tags[5].typeof, BoolTag#)
        verifyEq(tags[6].typeof, UriTag#)
        verifyEq(tags[7].typeof, TimeTag#)
        verifyEq(tags[8].typeof, NumTag#)
        verifyEq(tags[9].typeof, StrTag#)

        cols.each|col, idx|
        {
            verifyEq(tags[idx].name, col)
        }

        verifyEq(tags[0].val, Marker.fromStr("marker"))
        verifyEq(tags[1].val, DateTime(2014, Month.jan, 29, 9, 54, 13, 0, TimeZone.fromStr("Prague")))
        verifyEq((tags[2].val as DateTime).tz, TimeZone.cur)
        verifyEq(tags[3].val, Date(2014, Month.jan, 29))
        verifyEq(tags[4].val, Ref("bflmpsvz"))
        verifyEq(tags[5].val, true)
        verifyEq(tags[6].val, `http://www.google.com`)
        verifyEq(tags[7].val, Time(9, 54, 13))
        verifyEq(tags[8].val, 123.456f)
        verifyEq(tags[9].val, "muhaha")
    }
}
