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
using haystack

const class ExportActor : BaseActor
{

    new make(ActorPool pool, ProjectBuilder projectBuilder,
        Button exportButton, Button closeButton, Label progressLabel, ProgressBar progressBar):
                                super.make(pool, projectBuilder, exportButton, closeButton, progressLabel, progressBar)
    {
    }

    protected override Obj? doReceive([Str:Obj?] msgMap)
    {
        nodesToExport := msgMap["nodesToExport"] as RecordTreeDto[] ?: throw Err("nodes not found in map $msgMap")
        exportFile := msgMap["exportFile"] as File ?: throw Err("export file not found in map $msgMap")
        now := Duration.now

        i := 0
        n := nodesToExport.size

        index := [RecordTreeDto:LintError[]][:]
        rows := Dict[,]
        nodesToExport.each |node|
        {
            rows.addAll(processRecord(node))
            progress(i, n, "Exporting...")
            i++
        }

//        zincWriter := ZincWriter(exportFile.create.out)
//        zincWriter.writeGrid(Etc.toGrid(rows)).flush.close
//        exportFile.out.flush.close
        // TODO: remove this workaround
        zinc := ZincWriter.gridToStr(Etc.toGrid(rows))
        exportFile.create.out.writeBuf(zinc.toBuf).flush.close

        progress(1, 1, "Export done in ${(Duration.now - now).toLocale}")

        return null
    }

    internal Dict[] processRecord(RecordTreeDto dto)
    {
        rows := Dict[,]
        rows.add(dto.record.getDict)
        dto.children.each|child|
        {
            rows.addAll(processRecord(child))
        }
        return rows
    }

}
