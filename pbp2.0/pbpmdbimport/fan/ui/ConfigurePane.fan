/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using projectBuilder
using pbpgui
using pbpcore
using pbpobix

class ConfigurePane : EdgePane
{
    private ProjectBuilder projectBuilder

    ProgressBar progressBar { private set }
    Label progressLabel { private set }
    private Table pointTable
    PointTableModel? pointTableModel { set { &pointTableModel = it; pointTable.model = it; pointTable.refreshAll; textLint.text = ""; labelSelectedRows.text = "" } }
    private Text textLint
    private Label labelSelectedRows
    private Button importButton


    new make(ProjectBuilder projectBuilder, Button importButton) : super.make()
    {
        this.projectBuilder = projectBuilder
        this.importButton = importButton

        this.progressBar = ProgressBar()

        this.progressLabel = Label() { it.text = "" }

        this.pointTable = Table()
        {
            it.multi = true
            it.onSelect.add |event| { onTableRowSelected(event) }
        }

        this.textLint = Text() { it.multiLine = true; it.editable = false;  }

        this.labelSelectedRows = Label()

        this.center = InsetPane(12, 12, 0, 12)
        {
            it.content = EdgePane()
            {
                it.center = InsetPane() { it.content = createPointTablePane() }
                it.bottom = labelSelectedRows
            }
        }
        
        this.bottom = InsetPane(12, 12, 0, 12)
        {
            it.content = EdgePane()
            {
                it.left = progressLabel
                it.center = progressBar
            }
        }
        
        relayout()
    }

    private Void onTableRowSelected(Event event)
    {
        showLintOnRowSelect(event)

        importButton.enabled = pointTable.selected.size > 0

        showMessageOnRowSelect(event)

    }

    private Void showMessageOnRowSelect(Event event)
    {
        pointTableModel := pointTable.model as PointTableModel

        selectedPoints := pointTableModel.rows.findAll |point, idx -> Bool| { pointTable.selected.contains(idx) }

        lintCount := selectedPoints.reduce(0) |Int sum, point -> Int|
        {
            sum += pointTableModel.lintErrorIndex?.get(point)?.size ?: 0
        }

        labelSelectedRows.text = "Selected ${selectedPoints.size} point(s)" + (lintCount > 0 ? " with ${lintCount} lint(s) - points with lint errors won't be imported." : "")
    }

    private Void showLintOnRowSelect(Event event)
    {
        pointTableModel := pointTable.model as PointTableModel

        lintMessage := ""
        if (pointTableModel.lintErrorIndex != null && event.index != null)
        {
            lintErrors := pointTableModel.lintErrorIndex[pointTableModel.rows[event.index]]

            if (lintErrors != null)
            {
                sb := StrBuf()
                lintErrors.each |lintError|
                {
                    sb.add(lintError.message).add("\n")
                }
                lintMessage = sb.toStr
            }
        }

        textLint.text = lintMessage
    }

    private SashPane createPointTablePane()
    {
        return SashPane()
        {
            it.weights = [80,20]
            pointTable,
            createLintPage(),
        }
    }

    private EdgePane createLintPage()
    {
        return EdgePane()
        {
            it.top = BorderPane()
            {
                it.border = Border("1,1,0,1")
                it.content = Label() { it.text = "Lint details"; it.halign = Halign.center }
            }
            it.center = textLint
        }
    }

    Int[] selectedPointsIdx()
    {
        return pointTable.selected
    }
}

