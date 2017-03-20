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
using pbpcore
using pbpobix
using haystack
using pbpnhaystack

class AxImportWindow : PbpWindow
{
    private ProjectBuilder projectBuilder

    private Button loadButton
    private Button importButton
    private Button closeButton
    private ConfigurePane configurePane

    private Record? siteRecord
    private Int sleep

    private ActorPool actorPool
    private AxLoadActor loadActor
    private LintActor lintActor
    private AxSaveActor saveActor

    private ImportDto? importDto

    new make(ProjectBuilder projectBuilder) : super(projectBuilder.builder)
    {
        this.mode = WindowMode.windowModal

        this.projectBuilder = projectBuilder

        this.actorPool = ActorPool()

        this.size = Size(800 + 430, 600)
        this.title = "Niagara import"
        this.sleep = 0

        this.onClose.add |event| { onCloseWindow(event) }

        this.loadButton = Button()
        {
            it.text = "Load from Niagara"
            it.onAction.add |Event e|
            {
                cfg := configurePane.getLoadConfig()

                if (cfg.obixUri == null)
                {
                    Dialog.openInfo(this, "You must select Niagara Obix URI to import.")
                    return
                }

                loadActor.send(["cfg": cfg].toImmutable)
            }
        }

        this.importButton = Button()
        {
            it.text = "Import to PB plus"
            it.onAction.add |Event e|
            {
                if (siteRecord == null)
                {
                    Dialog.openInfo(this, "You must select site to save.")
                    return
                }

                if (configurePane.selectedPagesIdx.size == 0)
                {
                    Dialog.openInfo(this, "You must select pages to save.")
                    return
                }

                if (configurePane.pageTableModel == null)
                {
                    throw Err("configurePane.pageTableModel is null")
                }

                if (configurePane.pageTableModel.lintErrorIndex == null)
                {
                    throw Err("configurePane.pageTableModel.lintErrorIndex is null")
                }

                if (importDto != null)
                {
                    saveActor.send([
                        "importDto": importDto,
                        "siteRecord": siteRecord,
                        "equipName": configurePane.equipText.text,
                        "lintErrorIndex": configurePane.pageTableModel.lintErrorIndex,
                        "selected": configurePane.selectedPagesIdx,
                        "pages": configurePane.pageTableModel.rows,
                        "obixConnRef": getObixConnRef(configurePane.selectedObixConn),
                        "haystackConnRef": getHaystackConnRef(configurePane.selectedHaystackConn)
                    ].toImmutable)
                }
            }
        }

        this.closeButton = Button()
        {
            it.text = "Close"
            it.onAction.add |Event e|
            {
                this.close()
            }
        }

        this.configurePane = ConfigurePane(projectBuilder, importButton,
            |Record? site|
            {
                loadButton.enabled = (site != null)
                siteRecord = site
            },
            |Int? sleep|
            {
                this.sleep = sleep ?: 0
            })

        this.loadActor = AxLoadActor(
            this.actorPool,
            this.projectBuilder,
            this.loadButton,
            this.importButton,
            this.closeButton,
            this.configurePane.progressLabel,
            this.configurePane.progressBar) |ImportDto importDto|
            {
                onDataLoaded(importDto)
            }

        this.lintActor = LintActor(
            this.actorPool,
            this.projectBuilder,
            this.loadButton,
            this.importButton,
            this.closeButton,
            this.configurePane.progressLabel,
            this.configurePane.progressBar) |[Page:LintError[]] lintErrorsIndex|
            {
                onLints(lintErrorsIndex)
            }

        this.saveActor = AxSaveActor(this.actorPool,
            this.projectBuilder,
            this.loadButton,
            this.importButton,
            this.closeButton,
            this.configurePane.progressLabel,
            this.configurePane.progressBar) |Int selectedPagesCount, Int savedPagesCount, Int pointsCount|
            {
                Dialog.openInfo(this, "You have saved ${pointsCount} point(s) to ${savedPagesCount} equip(s) (originaly selected ${selectedPagesCount} page(s) to save).")
            }

        this.content = EdgePane()
        {
            it.center = configurePane
            it.bottom = InsetPane()
            {
                it.content = EdgePane()
                {
                    it.right = GridPane()
                    {
                        it.numCols = 3
                        loadButton,
                        importButton,
                        closeButton,
                    }
                }
            }
        }


        this.loadButton.enabled = true
        this.importButton.enabled = false
        this.closeButton.enabled = true

        relayout
    }

    private Ref? getObixConnRef(PbpObixConn obixConn)
    {
        obixConnRef := obixConn.conn.params["record"] as Record
        return obixConnRef.id
    }

    private Ref? getHaystackConnRef(HaystackConnection? conn)
    {
        if (conn == null || conn.name == "Empty") return null

        connMgr := HaystackConnManager(projectBuilder.currentProject)
        return connMgr.findOrCreateConnRecord(conn)?.id
    }

    private Void onCloseWindow(Event event)
    {
        ws := projectBuilder.workspace as PbpWorkspace ?: throw Err("Unable to get ${PbpWorkspace#}")

        ws.siteExplorer.update(projectBuilder.prj.database.getClassMap(Site#))
        ws.siteExplorer.refreshAll()

        ws.equipExplorer.update(projectBuilder.prj.database.getClassMap(Equip#))
        ws.equipExplorer.refreshAll()

        ws.pointExplorer.update(projectBuilder.prj.database.getClassMap(pbpcore::Point#))
        ws.pointExplorer.refreshAll()

        actorPool.kill
    }

    private static const Type[] obixLints := [PointObixHisLint#, PointObixAndIdLint#, PointKindAndUnitLint#]
    private static const Type[] haystackLints := [PointHaystackLint#]

    private Void onDataLoaded(ImportDto loadedImportDto)
    {
        importButton.enabled = false

        importDto = loadedImportDto

        configurePane.pageTableModel = PageTableModel(importDto.pageIndex, configurePane.defaultTemplate)

        Dialog.openInfo(null, "${importDto.points.size} Points has been loaded.")

        lintActor.send([
            "importDto": importDto,
            "lints": (configurePane.selectedHaystackConn == null) ? obixLints : haystackLints
        ].toImmutable)
    }

    private Void onLints([Page:LintError[]] lintErrorsIndex)
    {
        configurePane.pageTableModel = PageTableModel(importDto.pageIndex, configurePane.defaultTemplate, lintErrorsIndex)
    }
}
