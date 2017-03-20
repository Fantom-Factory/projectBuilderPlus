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

class MdbImportWindow : PbpWindow
{
    private ProjectBuilder projectBuilder

    private Button loadButton
    private Button importButton
    private Button closeButton
    private ConfigurePane configurePane

    private ActorPool actorPool
    private MdbLoadActor loadActor
    private LintActor lintActor
    private MdbSaveActor saveActor

    private ImportDto? importDto

    new make(ProjectBuilder projectBuilder) : super(projectBuilder.builder)
    {
        this.mode = WindowMode.windowModal

        this.projectBuilder = projectBuilder

        this.actorPool = ActorPool()

        this.size = Size(800 + 330, 600)
        this.title = "MS Access import"

        this.onClose.add |event| { onCloseWindow(event) }

        this.loadButton = Button()
        {
            it.text = "Load db file"
            it.onAction.add |Event e|
            {

                 fileDialog := FileDialog()
                 {
                     it.filterExts = ["*.mdb",]
                     it.mode = FileDialogMode.openFile
                 }

                 uri := fileDialog.open(this)
                 if(uri != null)
                 {
                     loadActor.send([
                                     "dbFile": uri,
                                     ].toImmutable)
                 }
            }
        }

        this.importButton = Button()
        {
            it.text = "Import to PB plus"
            it.onAction.add |Event e|
            {
                if (configurePane.selectedPointsIdx.size == 0)
                {
                    Dialog.openInfo(this, "You must select points to save.")
                    return
                }

                if (configurePane.pointTableModel == null)
                {
                    throw Err("configurePane.pointTableModel is null")
                }

                if (configurePane.pointTableModel.lintErrorIndex == null)
                {
                    throw Err("configurePane.pointTableModel.lintErrorIndex is null")
                }

                if (importDto != null)
                {
                    saveActor.send([
                        "importDto": importDto,
                        "selected": configurePane.selectedPointsIdx,
                        "points": configurePane.pointTableModel.rows,].toImmutable)
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

        this.configurePane = ConfigurePane(projectBuilder, importButton)

        this.loadActor = MdbLoadActor(
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
            this.configurePane.progressBar,
            [NameLint#, MappingIdLint#, ]) |[Map:LintError[]] lintErrorsIndex|
            {
                onLints(lintErrorsIndex)
            }

        this.saveActor = MdbSaveActor(this.actorPool,
            this.projectBuilder,
            this.loadButton,
            this.importButton,
            this.closeButton,
            this.configurePane.progressLabel,
            this.configurePane.progressBar) |Int savedPointsCount|
            {
                Dialog.openInfo(this, "You have saved ${savedPointsCount} point(s).")
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

    private Void onDataLoaded(ImportDto loadedImportDto)
    {
        importButton.enabled = false

        importDto = loadedImportDto

        configurePane.pointTableModel = PointTableModel(importDto)

        Dialog.openInfo(null, "${importDto.points.size} Points has been loaded.")

        lintActor.send(["importDto": importDto].toImmutable)
    }

    private Void onLints([Map:LintError[]] lintErrorsIndex)
    {
        configurePane.pointTableModel = PointTableModel(importDto, lintErrorsIndex)
    }
}
