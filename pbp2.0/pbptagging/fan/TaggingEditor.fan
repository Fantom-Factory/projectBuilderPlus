/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpgui
using pbpcore
using projectBuilder
using haystack

const class TaggingEditor
{
    private const Record[] selectedRecords
    private const Unsafe projectBuilderUnsafe

    new make(ProjectBuilder projectBuilder, Record[] selectedRecords)
    {
        this.projectBuilderUnsafe = Unsafe(projectBuilder)
        this.selectedRecords = selectedRecords
    }

    Str infoText()
    {
        typeMap := selectedRecords.dup.
            sort |left, right -> Int|
            {
                rank := Type:Int[Site#:0, Equip#:1, Point#:2]
                return rank.get(left.typeof, 999) - rank.get(right.typeof, 999)
            }.
            reduce(Type:Int[:] { ordered = true }) |Type:Int reduction, Record rec -> Type:Int|
            {
                cnt := reduction.get(rec.typeof, 0)
                return reduction[rec.typeof] = (cnt + 1)
            } as Type:Int

        Str msg := cntRec(0, "record")
        Str total := ""
        if (!typeMap.isEmpty)
        {
            items := Str[,]

            typeMap.each |cnt, type|
            {
                switch (type)
                {
                    case Site#:
                        items.add(cntRec(cnt, "site"))
                    case Equip#:
                        items.add(cntRec(cnt, "equip"))
                    case Point#:
                        items.add(cntRec(cnt, "point"))
                    default:
                        items.add(cntRec(cnt, type.name.lower))
                }
            }

            total = "In total " + cntRec(selectedRecords.size, "record") + "."

            msg = items.join(", ")
        }



        return "Tagging ${msg}. $total"
    }

    private static Str cntRec(Int n, Str item)
    {
        switch (n)
        {
            case 0:
                return "no ${item}s"
            case 1:
                return "$n ${item}"
            default:
                return "$n ${item}s"
        }
    }

    Void applyTags(TaggingRow taggingRow)
    {
        project := (projectBuilderUnsafe.val as ProjectBuilder)?.currentProject ?: throw Err()

        selectedRecords.each |record|
        {
            FileUtil.createRecFile(project, createRecord(record, taggingRow))
        }

    }

    private static Record createRecord(Record oldRecord, TaggingRow taggingRow)
    {
        oldTags := oldRecord.data.map |tag -> Str| { tag.name }

        tags := Tag[,]
        tags.addAll(oldRecord.data)

        tags.addAll(taggingRow.tags.
            findAll |Str tag -> Bool| { !oldTags.contains(tag) }.
            map |Str tag -> Tag| { TagFactory.getTag(tag, Marker.fromStr(tag)) })

        setFunc := Field.makeSetFunc([Record#id: oldRecord.id, Record#data: tags.toImmutable])

        return oldRecord.typeof.make([setFunc])

    }

}
