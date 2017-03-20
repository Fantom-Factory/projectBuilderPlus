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
using pbpgui
using haystack
using pbplogging

const class AxLoadActor : BaseActor
{
    private const Str onImportValuesLoadedFuncHandle := Uuid().toStr

    new make(ActorPool pool, ProjectBuilder projectBuilder,
        Button loadButton, Button importButton, Button closeButton, Label progressLabel, ProgressBar progressBar,
        |ImportDto| onImportValuesLoadedFunc) : super.make(pool, projectBuilder, loadButton, importButton, closeButton, progressLabel, progressBar)
    {
        Actor.locals[onImportValuesLoadedFuncHandle] = onImportValuesLoadedFunc
    }

    protected override Obj? doReceive([Str:Obj?] msgMap)
    {
        cfg := msgMap["cfg"] as LoadConfig

        Logger.log.info("Uri ${cfg.obixUri} with http sleep ${cfg.sleep} ms")

        now := Duration.now

        points := loadFromNiagara(cfg)

        index := makeIndex(points)

        progress(1, 1, "Loading done in ${(Duration.now - now).toLocale}")

        Desktop.callAsync |->|
        {
            onImportValuesLoadedFunc := Actor.locals[onImportValuesLoadedFuncHandle] as |ImportDto|
            onImportValuesLoadedFunc(ImportDto() { it.points = points; it.pageIndex = index})
        }

        return null
    }

    private [Page:pbpaximport::Point[]] makeIndex(pbpaximport::Point[] points)
    {
        progress(0, 0, "Indexing pages...")

        i := 0
        n := points.size

        index := [Page:pbpaximport::Point[]][:] { ordered = true }

        points.each |point|
        {
            list := index[point.page]

            if (list == null)
            {
                list = pbpaximport::Point[,]
                index[point.page] = list
            }

            list.add(point)

            progress(i, n, "Indexing pages...")
            i++
        }

        progress(1, 1, "Indexing done")

        return index
    }

    private pbpaximport::Point[] loadFromNiagara(LoadConfig cfg)
    {
        progress(0, 0, "Loading...")

        reader := PointReader()
        {
            it.mapping = cfg.mapping
            it.obixUri = cfg.obixUri
            it.obixUser = cfg.obixUser
            it.obixPassword = cfg.obixPassword
            it.haystackUri = cfg.haystackUri
            it.haystackUser = cfg.haystackUser
            it.haystackPassword = cfg.haystackPassword
            it.sleep = cfg.sleep
            it.getDisMacro = cfg.getDisMacro
        }

        points := reader.readPoints() |Int cur, Int count, Str message|
        {
            progress(cur, count, message)
        }

        progress(1, 1, "Loading done")

        return points
    }
}
