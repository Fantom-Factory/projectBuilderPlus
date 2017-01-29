/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using fwt
using projectBuilder
using pbpcore
using haystack
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

/**
 * @author 
 * @version $Revision:$
 */
abstract const class AbstractMappingActor : Actor
{
    private const Int connIdx
    private const Str progessWindowKey
    private const Str onFinishFuncKey

    private const Unsafe projectBuilderUnsafe
    protected ProjectBuilder projectBuilder() { return projectBuilderUnsafe.val }
    private const Unsafe supplyConnFuncUnsafe
    private |Int -> HaystackConnection?| supplyConnFunc() { return supplyConnFuncUnsafe.val }
    private const Unsafe updateConnFuncUnsafe
    private |Int, HaystackConnection| updateConnFunc() { return updateConnFuncUnsafe.val }

    new make(ActorPool pool, Int connIdx, ProjectBuilder projectBuilder, MappingProgressWindow progressWindow,
        |Int -> HaystackConnection?| supplyConnFunc,
        |Int, HaystackConnection| updateConnFunc,
        |Err?| onFinishFunc) : super.make(pool)
    {
        this.connIdx = connIdx
        this.projectBuilderUnsafe = Unsafe(projectBuilder)
        this.progessWindowKey = Uuid().toStr; Actor.locals[progessWindowKey] = progressWindow
        this.onFinishFuncKey = Uuid().toStr; Actor.locals[onFinishFuncKey] = onFinishFunc
        this.supplyConnFuncUnsafe = Unsafe(supplyConnFunc)
        this.updateConnFuncUnsafe = Unsafe(updateConnFunc)
    }

    protected abstract Obj? onReceive(Obj? msg, Project currentProject)

    protected override Obj? receive(Obj? msg)
    {
        currentProject := projectBuilder.currentProject
        if (currentProject == null) { return null }

        Desktop.callAsync |->|
        {
            (Actor.locals[progessWindowKey] as MappingProgressWindow).open
        }

        Err? err := null
        try
        {
            return onReceive(msg, currentProject)
        }
        catch (Err e)
        {
            err = e
            return null
        }
        finally
        {
            theErr := err

            Desktop.callAsync |->|
            {
                (Actor.locals[progessWindowKey] as MappingProgressWindow).doClose
                Actor.locals[progessWindowKey] = null

                (Actor.locals[onFinishFuncKey] as |Err?|)(theErr)
                Actor.locals[onFinishFuncKey] = null
            }
        }
    }

    protected Void progress(Str msg, Int cur)
    {
        Desktop.callAsync |->|
        {
            try
            {
                (Actor.locals[progessWindowKey] as MappingProgressWindow).step(msg, cur)
            }
            catch (Err e)
            {
                e.trace
            }
        }
    }

    protected Record? findOrCreateConnRecord(Project project)
    {
        conn := supplyConnFunc()(connIdx)
        if (conn == null) { return null }

        if (conn.id == null)
        {
            newConn := conn = HaystackConnection.makeCopy(conn) { it.id = Ref.gen.toStr }
            Desktop.callAsync |->|
            {
                updateConnFunc()(connIdx, newConn)
            }
        }

        connRec := PbpConnExt.findHaystackConnRecord(project, conn)
        if (connRec == null) { connRec = HaystackConnRecord() { it.id = Ref.fromStr(conn.id); } }

        connRec = connRec.
            set(MarkerTag() { it.name = "haystackConn"; it.val = "haystackConn" }).
            set(UriTag() { it.name = "uri"; it.val = conn.uri}).
            set(StrTag() { it.name = "username"; it.val = conn.user}).
            set(StrTag() { it.name = "dis"; it.val = conn.name})

        project.database.save(connRec)

        return connRec
    }

    internal static Void copyTagsFromRow(HRow row, Str tagName, Tag[] tags)
    {
        hVal := row.get(tagName, false)
        if (hVal != null)
        {
            Tag? val := null
            switch (hVal.typeof)
            {
                case HMarker#:
                    val = TagFactory.getTag(tagName, Marker.fromStr(tagName))
                case HDateTime#:
                    dt := hVal as HDateTime
                    dateTime := DateTime.fromJava(dt.millis, TimeZone.fromStr(dt.tz.name))
                    val = TagFactory.getTag(tagName, dateTime)
                case HDate#:
                    d := hVal as HDate
                    date := Date(d.year, Month.vals[d.month - 1], d.day)
                    val = TagFactory.getTag(tagName, date)
                case HRef#:
                    val = TagFactory.getTag(tagName, Ref.fromStr((hVal as HRef).val))
                case HBool#:
                    val = TagFactory.getTag(tagName, (hVal as HBool).val)
                case HUri#:
                    val = TagFactory.getTag(tagName, Uri.fromStr((hVal as HUri).val))
                case HTime#:
                    val = TagFactory.getTag(tagName, Time.fromIso((hVal as HTime).toZinc))
                case HNum#:
                    val = TagFactory.getTag(tagName, (hVal as HNum).val)
                case HStr#:
                    val = TagFactory.getTag(tagName, (hVal as HStr).val)
                default:
                    throw Err("Unsupported val $hVal format")
            }

            tags.add(val)
        }
    }

    protected static Void saveRecord(Project project, Record newRec)
    {
        a := Unsafe(project)
        b := Unsafe(newRec)
        Desktop.callAsync |->| { FileUtil.createRecFile((Project)a.val, (Record)b.val) }
    }

    protected Void saveRecords(Record[] newRecords, Project currentProject)
    {
        a := Unsafe(currentProject)
        b := Unsafe(newRecords)
        Desktop.callAsync |->| { FileUtil.createRecFiles((Project)a.val, (Record[])b.val) }
    }
}
