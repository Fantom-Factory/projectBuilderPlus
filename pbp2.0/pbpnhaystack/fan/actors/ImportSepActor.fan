/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using projectBuilder
using pbpcore
using haystack


/**
 * @author 
 * @version $Revision:$
 */
const class ImportSepActor : AbstractMappingActor
{
    private const NavNode[] siteNodes

    new make(NavNode[] siteNodes, ActorPool pool, Int connIdx, ProjectBuilder projectBuilder, MappingProgressWindow progressWindow,
        |Int -> HaystackConnection?| supplyConnFunc,
        |Int, HaystackConnection| updateConnFunc,
        |Err?| onFinishFunc) : super.make(pool, connIdx, projectBuilder, progressWindow, supplyConnFunc, updateConnFunc, onFinishFunc)
    {
        this.siteNodes = siteNodes
    }

    protected override Obj? onReceive(Obj? msg, Project currentProject)
    {
        connRecord := findOrCreateConnRecord(currentProject)
        if (connRecord == null) { return null }

        newRecords := Record[,]

        createRecords(siteNodes, connRecord, newRecords)

        saveRecords(newRecords, currentProject)

        return null
    }

    private Void createRecords(NavNode[] nodes, Record connRecord, Record[] newRecords, Record? parentRecord := null, Bool topLevel := true)
    {
        for (i := 0; i < nodes.size; i++)
        {
            node := nodes[i]

            if (topLevel) { progress("Processing SEP for ${node.dis}", i) }

            isSite := (parentRecord == null && node->site != null)
            isEquip := (parentRecord is Site && node->equip != null)
            isPoint := (parentRecord is Equip && node->point != null)

            rec := (Record?)null
            tags := Tag[,]

            if (isSite)
            {
                rec = Site() {}
            }
            else if (isEquip)
            {
                rec = Equip() {}
                tags.add(TagFactory.getTag("siteRef", Ref.fromStr(parentRecord.id.toStr)))
            }
            else if (isPoint)
            {
                rowId := node.row.id

                rec = Point() {}
                siteRef := ((parentRecord.get("siteRef") as RefTag).val as Ref)
                tags.add(TagFactory.getTag("siteRef", Ref.fromStr(siteRef.toStr)))
                tags.add(TagFactory.getTag("equipRef", Ref.fromStr(parentRecord.id.toStr)))

                tags.add(TagFactory.getTag("haystackConnRef", Ref.fromStr(connRecord.id.toStr)))
                tags.add(TagFactory.getTag("haystackCur", Ref.fromStr(rowId.val)))
                tags.add(TagFactory.getTag("haystackHis", Ref.fromStr(rowId.val)))
                tags.add(TagFactory.getTag("haystackWrite", Ref.fromStr(rowId.val)))
            }

            if (rec != null)
            {
                cols := Str[,]
                for (col := 0; col < node.row.grid.numCols(); col++)
                {
                    cols.add(node.row.grid.col(col).name)
                }
                cols.removeAll(["id", "siteRef", "equipRef"]) // we create own refs, ignore them in Haystack
                cols.each |colName| { copyTagsFromRow(node.row, colName, tags) }

                rec = rec.addAll(tags)

                newRecords.add(rec)

                createRecords(node.children, connRecord, newRecords, rec, false)
            }
        }
    }
}
