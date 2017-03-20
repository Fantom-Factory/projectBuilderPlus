/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using concurrent
using fwt
using projectBuilder
using pbpgui
using haystack
using pbplogging

const class MdbLoadActor : BaseActor
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
        dbFile := msgMap["dbFile"] as File ?: throw Err("dbFile not found in map $msgMap")
        tableName := msgMap["tableName"] as Str ?: "tblTrendlogList"
        Logger.log.info("importing from DB $dbFile with table Name $tableName")

        now := Duration.now

        points := loadFromDBFile(dbFile, tableName)

        progress(1, 1, "Loading done in ${(Duration.now - now).toLocale}")

        Desktop.callAsync |->|
        {
            onImportValuesLoadedFunc := Actor.locals[onImportValuesLoadedFuncHandle] as |ImportDto|
            onImportValuesLoadedFunc(ImportDto() { it.points = points; })
        }

        return null
    }

    private Map[] loadFromDBFile(File dbFile, Str tableName)
    {
        progress(0, 0, "Loading...")

        data := MdbLoader.loadTable(dbFile, tableName)
        progress(1, 1, "Loading done")

        return data
    }
}
