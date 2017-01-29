/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using fwt
using gfx
using projectBuilder
using pbpcore
using haystack
using pbplogging

const class AxSaveActor : BaseActor
{
    private const Str onRecordsSavedFuncHandle := Uuid().toStr

    new make(ActorPool pool, ProjectBuilder projectBuilder,
        Button loadButton, Button importButton, Button closeButton, Label progressLabel, ProgressBar progressBar,
        |Int, Int, Int| onRecordsSavedFunc) : super.make(pool, projectBuilder, loadButton, importButton, closeButton, progressLabel, progressBar)
    {
        Actor.locals[onRecordsSavedFuncHandle] = onRecordsSavedFunc
    }

    protected override Obj? doReceive([Str:Obj?] msgMap)
    {
        importDto := msgMap["importDto"] as ImportDto ?: throw Err("importDto not found in map $msgMap")
        siteRecord := msgMap["siteRecord"] as Record ?: throw Err("siteRecord not found in map $msgMap")
        equipName := msgMap["equipName"] as Str ?: throw Err("equipName not found in map $msgMap")
        lintErrorIndex := msgMap["lintErrorIndex"] as [Page:LintError[]] ?: throw Err("lintErrorIndex not found in map $msgMap")
        selectedPagesIdx := msgMap["selected"] as Int[] ?: throw Err("selected not found in map $msgMap")
        pages := msgMap["pages"] as Page[] ?: throw Err("pages not found in map $msgMap")
        obixConnRef := msgMap["obixConnRef"] as Ref ?: throw Err("obixConnRef not found in map $msgMap")
        haystackConnRef := msgMap["haystackConnRef"] as Ref
        now := Duration.now

        selectedPages := pages.findAll |page, idx -> Bool| { selectedPagesIdx.contains(idx) }

        pagesWithoutLint := selectedPages.findAll |page -> Bool| { (lintErrorIndex[page] ?: LintError[,]).size == 0 }

        pointsCount := processPoints(pagesWithoutLint, importDto, siteRecord, equipName, obixConnRef, haystackConnRef)

        progress(1, 1, "Saving records done in ${(Duration.now - now).toLocale}")

        Desktop.callAsync |->|
        {
            onRecordsSavedFunc := Actor.locals[onRecordsSavedFuncHandle] as |Int, Int, Int|
            onRecordsSavedFunc(selectedPages.size, pagesWithoutLint.size, pointsCount)
        }

        return null
    }


    private Void processPoint(pbpaximport::Point point, Record siteRecord, Record equipRecord, Ref obixConnRef, Ref? haystackConnRef)
    {

        unit := Unit.fromStr(point.unit ?: "", false)
        unitTagVal := unit?.name ?: ""

        tags := Tag[
            TagFactory.getTag("dis", point.name),
            TagFactory.getTag("point", Marker.fromStr("point")),
            TagFactory.getTag("imported", Marker.fromStr("imported")),
            TagFactory.getTag("siteRef", siteRecord.id),
            TagFactory.getTag("tz", siteRecord.get("tz")?.val),
            TagFactory.getTag("equipRef", equipRecord.id),
            TagFactory.getTag("mod", DateTime.now),
            TagFactory.getTag("obixConnRef", obixConnRef),
            TagFactory.getTag("axSlotPath", point.axSlotPath),
            TagFactory.getTag("unit", unitTagVal),
            TagFactory.getTag("kind", point.kind),
        ]

        if (point.haystackId != null)
        {
            // Acquired using Haystack
            tags.addAll(Tag[
                TagFactory.getTag("haystackConnRef", haystackConnRef ?: ""),
                TagFactory.getTag("axType", point.axType ?: ""),
                TagFactory.getTag("curStatus", point.curStatus ?: ""),
                TagFactory.getTag("precision", point.precision ?: ""),
                TagFactory.getTag("curVal", point.curVal ?: ""),
                TagFactory.getTag("actions", point.actions ?: ""),
                TagFactory.getTag("enum", point.enum ?: ""),
                TagFactory.getTag("navName", point.navName ?: "")
            ])

            if (point.disMacro != null)
                tags.add(TagFactory.getTag("disMacro", point.disMacro ?: ""))

            if (point.markers.contains("cur"))
                tags.add(TagFactory.getTag("haystackCur", Ref.fromStr(point.haystackId)))

            if (point.markers.contains("his"))
                tags.add(TagFactory.getTag("haystackHis", Ref.fromStr(point.haystackId)))

            if (point.markers.contains("cmd"))
                tags.add(TagFactory.getTag("haystackWrite", Ref.fromStr(point.haystackId)))
        }
        else
        {
            // Acquired using Obix
            tags.addAll(Tag[
                TagFactory.getTag("obixHis", point.obixHis?.relToAuth()),
                TagFactory.getTag("his", Marker.fromStr("his"))
            ])
        }

        tags.addAll(point.markers
            .exclude |m| { m == "point" || m == "imported" }
            .map |m| { TagFactory.getTag(m, Marker.fromStr(m)) }
        )


        record := pbpcore::Point()
        {
            it.data = tags
        }

        Logger.log.info("Saving Point ${record.id} with name ${point.name}")

        saveRecord(record)
    }

    private Int processPoints(Page[] pagesToImport, ImportDto importDto, Record siteRecord, Str equipName, Ref obixConnRef, Ref? haystackConnRef)
    {
        progress(0, 0, "Saving points...")

        i := 0
        n := pagesToImport.reduce(0) |Int sum, page -> Int| { sum += importDto.pageIndex[page]?.size ?: 0 }

        pageEquipIndex := Page:Record[:]

        pagesToImport.each |page|
        {
            points := importDto.pageIndex[page]
            if (points != null)
            {
                points.each |point|
                {
                    equipRecord := getEquipRecord(point, siteRecord, equipName, page, pageEquipIndex)

                    processPoint(point, siteRecord, equipRecord, obixConnRef, haystackConnRef)

                    progress(i, n, "Saving points...")
                    i++
                }
            }
        }

        progress(1, 1, "Saving done (${n} point(s) saved)")

        return n
    }

    private Record getEquipRecord(pbpaximport::Point point, Record siteRecord, Str equipName, Page page, Page:Record pageEquipIndex)
    {
        result := pageEquipIndex[page]
        if (result == null)
        {
            pathArray := point.page.res.path()
            pageRes := EscapeUtils.unescapeNiagara(pathArray[-2..-2].first ?: "")

            tags :=  Tag[
                TagFactory.getTag("dis", ("$equipName $pageRes").trim),
                TagFactory.getTag("navName", pageRes),
                TagFactory.getTag("pageName", page.name),
                TagFactory.getTag("pageRes", pageRes),
                TagFactory.getTag("siteRef", siteRecord.id),
                TagFactory.getTag("equip", Marker.fromStr("equip")),
                TagFactory.getTag("mod", DateTime.now)
            ]

            if (page.disMacro != null)
                tags.add(TagFactory.getTag("disMacro", page.disMacro ?: ""))

            result = Equip()
            {
                it.data = tags
            }

            Logger.log.info("Saving Equip ${result.id} with name ${page.name}")

            saveRecord(result)

            pageEquipIndex[page] = result
        }

        return result
    }

    private Void saveRecord(Record record)
    {
        Desktop.callAsync |->|
        {
            projectBuilder := Actor.locals[projectBuilderHandle] as ProjectBuilder

            FileUtil.createRecFile(projectBuilder.prj, record)
        }
    }

}
