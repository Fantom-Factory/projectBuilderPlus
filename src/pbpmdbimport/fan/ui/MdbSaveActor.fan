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
using pbplogging

const class MdbSaveActor : BaseActor
{
    private const Str onRecordsSavedFuncHandle := Uuid().toStr

    new make(ActorPool pool, ProjectBuilder projectBuilder,
        Button loadButton, Button importButton, Button closeButton, Label progressLabel, ProgressBar progressBar,
        |Int| onRecordsSavedFunc) : super.make(pool, projectBuilder, loadButton, importButton, closeButton, progressLabel, progressBar)
    {
        Actor.locals[onRecordsSavedFuncHandle] = onRecordsSavedFunc
    }

    protected override Obj? doReceive([Str:Obj?] msgMap)
    {
        importDto := msgMap["importDto"] as ImportDto ?: throw Err("importDto not found in map $msgMap")
        selectedPointsIdx := msgMap["selected"] as Int[] ?: throw Err("selected not found in map $msgMap")
        points := msgMap["points"] as Map[] ?: throw Err("points not found in map $msgMap")
        now := Duration.now

        ctr := 0
        selectedPointsIdx.each|idx|
        {
            pointData := points[idx]
            processPoint(pointData)
            progress(ctr, selectedPointsIdx.size, "Saving points...")
            ctr++
        }

        progress(1, 1, "Saving records done in ${(Duration.now - now).toLocale}")

        Desktop.callAsync |->|
        {
            onRecordsSavedFunc := Actor.locals[onRecordsSavedFuncHandle] as |Int|
            onRecordsSavedFunc(selectedPointsIdx.size)
        }

        return null
    }

    private Void processPoint(Map point)
    {
        name := point["objname"]
        logDevNum := point["logdevnum"]
        logInst := point["loginst"]
        record := pbpcore::Point()
        {
            it.data = Tag[
                TagFactory.getTag("dis", name),
                TagFactory.getTag("point", Marker.fromStr("point")),
                TagFactory.getTag("imported", Marker.fromStr("imported")),
                TagFactory.getTag("mod", DateTime.now),
                TagFactory.getTag("his", Marker.fromStr("his")),
                TagFactory.getTag("mappingId", formatMappingId(logDevNum, logInst)),

//                TagFactory.getTag("unit", unitTagVal),
//                TagFactory.getTag("kind", point.kind),
            ]
        }

        Logger.log.info("Saving Point ${record.id} with name ${name}")

        saveRecord(record)
    }

    internal Str formatMappingId(Int logDevNum, Int logInst)
    {
        return "${logDevNum.toStr.padl(7, '0')}_${logInst.toStr.padl(10, '0')}"
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
