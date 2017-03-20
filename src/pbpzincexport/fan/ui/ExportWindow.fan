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

class ExportWindow  : PbpWindow
{
    private ProjectBuilder projectBuilder
    private ActorPool actorPool

    private LintActor lintActor
    private ExportActor exportActor

    // nodes to export
    private RecordTreeNode[] nodes

    // widgets
    private Button closeButton
    private Button exportButton
    private InfoPane infoPane

    new make(ProjectBuilder projectBuilder, RecordTreeNode[] nodes) : super(projectBuilder.builder)
    {
        this.mode = WindowMode.windowModal

        this.projectBuilder = projectBuilder

        this.actorPool = ActorPool()
        this.nodes = nodes

        this.size = Size(800 + 330, 600)
        this.title = "Zinc export" // TODO: localize

        this.closeButton = Button()
        {
            it.text = "Close"  // TODO: localize
            it.onAction.add |Event e|
            {
                this.close()
            }
        }

        this.exportButton = Button()
        {
            it.text = "Export to Zinc format"  // TODO: localize
            it.onAction.add |Event e|
            {
                fileSaveDialog := FileDialog()
                {
                    it.mode = FileDialogMode.saveFile
                    it.filterExts = ["*.zinc", ]
                }

                file := fileSaveDialog.open(this)
                if(file != null)
                {
                    exportActor.send(["nodesToExport": makeImmutable(nodes),
                                      "exportFile" : file.toImmutable].toImmutable)
                }
            }
        }

        this.infoPane = InfoPane(projectBuilder, exportButton)

        this.content = EdgePane()
        {
            it.center = infoPane
            it.bottom = InsetPane()
            {
                it.content = EdgePane()
                {
                    it.right = GridPane()
                    {
                        it.numCols = 2
                        exportButton,
                        closeButton,
                    }
                }
            }
        }


        this.lintActor = LintActor(
            this.actorPool,
            this.projectBuilder,
            this.exportButton,
            this.closeButton,
            this.infoPane.progressLabel,
            this.infoPane.progressBar,
            [SiteAndTimeZoneLint#,PointAndTimeZoneLint#,]) |[Str:LintError[]] lintErrorsIndex|
            {
                onLints(lintErrorsIndex)
            }

        this.exportActor = ExportActor(
            this.actorPool,
            this.projectBuilder,
            this.exportButton,
            this.closeButton,
            this.infoPane.progressLabel,
            this.infoPane.progressBar)


        this.exportButton.enabled = false
        this.closeButton.enabled = true

        this.onOpen.add(|e|{lintActor.send(["nodesToCheck": makeImmutable(nodes)].toImmutable)})

        relayout
    }

    internal RecordTreeDto[] makeImmutable(RecordTreeNode[] records)
    {
      list := RecordTreeDto[,]
      records.each |record|
      {
        list.add(makeImmutableRecord(record))
      }
      return list.toImmutable
    }

    internal RecordTreeDto makeImmutableRecord(RecordTreeNode node)
    {
      RecordTreeDto? parent := null // we don't need child->parent relation
      RecordTreeDto[] kids := makeImmutable(node.children)
      useDisMacro := (projectBuilder.callback("getCurProject") as Project).projectConfigProps.get("useDisMacro", "false").toBool
      
      result := RecordTreeDto()
      {
        recType := node.record.typeof
        disMacroApplyType := recType == Equip# || recType == pbpcore::Point#
        if (useDisMacro) {
          if (disMacroApplyType) {
            node.record = node.record.remove("dis")
          }
        } else {
          node.record = node.record.remove("disMacro")
        }
        it.parent = parent
        it.record = node.record.toImmutable
        it.children = kids
      }
      return result
    }

    private Void onLints([Str:LintError[]] lintErrorsIndex)
    {
        infoPane.recordTableModel = RecordTableModel(makeImmutable(nodes), lintErrorsIndex)
    }
}
