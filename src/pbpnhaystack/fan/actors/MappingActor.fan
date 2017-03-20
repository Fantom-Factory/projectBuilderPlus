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

/**
 * @author 
 * @version $Revision:$
 */
const class MappingActor : AbstractMappingActor
{
    private const Mapping[] mappingList

    new make(Mapping[] mappingList, ActorPool pool, Int connIdx, ProjectBuilder projectBuilder, MappingProgressWindow progressWindow,
        |Int -> HaystackConnection?| supplyConnFunc,
        |Int, HaystackConnection| updateConnFunc,
        |Err?| onFinishFunc) : super.make(pool, connIdx, projectBuilder, progressWindow, supplyConnFunc, updateConnFunc, onFinishFunc)
    {
        this.mappingList = mappingList
    }

    protected override Obj? onReceive(Obj? msg, Project currentProject)
    {
        connRecord := findOrCreateConnRecord(currentProject)
        if (connRecord == null) { return null }

        recs := Record[,]
        for (i := 0; i < mappingList.size; i++)
        {
            recs.add(processMapping(mappingList.get(i), i, connRecord))
        }
        saveRecords(recs, currentProject)
        return null
    }

    private Record processMapping(Mapping mapping, Int i, Record connRef)
    {
        progress("Processing mapping from $mapping.rowDis to $mapping.pointDis", i)

        row := mapping.row
        point := mapping.point

        rowId := row.id

        copyTags := ["axType", "axSlotPath"]
        supportedTags := ["haystackConnRef", "haystackCur", "haystackHis", "haystackWrite"].addAll(copyTags)

        oldTags := point.data.findAll |Tag tag -> Bool| { !supportedTags.contains(tag.name) }

        tags := Tag[,]
        tags.addAll(oldTags)

        copyTags.each |tagName| { copyTagsFromRow(row, tagName, tags) }

        tags.add(TagFactory.getTag("haystackConnRef", Ref.fromStr(connRef.id.toStr)))
        tags.add(TagFactory.getTag("haystackCur", Ref.fromStr(rowId.val)))
        tags.add(TagFactory.getTag("haystackHis", Ref.fromStr(rowId.val)))
        tags.add(TagFactory.getTag("haystackWrite", Ref.fromStr(rowId.val)))

        setFunc := Field.makeSetFunc([Record#id: Ref.fromStr(point.id.toStr), Record#data: tags.toImmutable])
        newRec := mapping.point.typeof.make([setFunc])

        return newRec
    }
}
