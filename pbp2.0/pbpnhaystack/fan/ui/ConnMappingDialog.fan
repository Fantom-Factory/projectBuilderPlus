/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using pbpgui
using pbpcore
using haystack
using [java] org.projecthaystack::HRow

/**
 * @author 
 * @version $Revision:$
 */
class ConnMappingDialog : PbpWindow
{
    private Table haystackTable
    private Table pointTable
    private Table mappingTable
    private Mapping[] mappingList

    private HRow[] rows
    private Record[] points

    private HaystackConnection conn
    private |HaystackConnection, Mapping[] -> Bool| onApplyMappingFunc

    new make(Window parent, HRow[] rows, Record[] points, HaystackConnection conn, |HaystackConnection, Mapping[] -> Bool| onApplyMappingFunc) : super(parent)
    {
        this.mode = WindowMode.appModal
        this.size = Size(900, 800)

        this.mappingList = Mapping[,]
        this.rows = rows.dup
        this.points = points.dup
        this.conn = conn
        this.onApplyMappingFunc = onApplyMappingFunc

        this.haystackTable = Table()
        this.pointTable = Table()
        this.mappingTable = Table() { it.model = MappingTableModel(mappingList) }

        refreshRows()
        refreshPoints()

        this.content = InsetPane()
        {
            it.content = EdgePane()
            {
                it.center = SashPane()
                {
                    it.orientation = Orientation.vertical
                    EdgePane() {
                        it.top = Label() { it.text = "Selected Haystack records"; it.font = Desktop.sysFont.toBold }
                        it.center = haystackTable
                    },
                    EdgePane() {
                        it.top = Label() { it.text = "Selected points"; it.font = Desktop.sysFont.toBold }
                        it.center = pointTable
                    },
                    EdgePane() {
                        it.top = GridPane()
                        {
                            Label() { it.text = "Mapping"; it.font = Desktop.sysFont.toBold },
                            Button() { it.text = "Add mapping"; it.onAction.add |e| { onAddMapping(e) } },
                            Button() { it.text = "Remove mapping"; it.onAction.add |e| { onRemoveMapping(e) } },
                        }
                        it.center = mappingTable
                    },
                }
                it.bottom = EdgePane() { it.center = Label(); it.right = GridPane()
                {
                    it.numCols = 2
                    Button() { it.text = "Apply"; it.onAction.add |e|
                    {
                        if (mappingList.isEmpty) { return }
                        if (onApplyMappingFunc(conn, mappingList)) { close() }
                    } },
                    Button() { it.text = "Cancel"; it.onAction.add |e| { close() } },
                } }
            }
        }
    }

    private Void onAddMapping(Event event)
    {
        selHaystackTable := haystackTable.selected
        if (selHaystackTable.isEmpty) { return }
        hRow := (haystackTable.model as HRowTableModel).getRow(selHaystackTable.first)

        selPointTable := pointTable.selected
        if (selPointTable.isEmpty) { return }
        point := (pointTable.model as RecordTableModel).getRow(selPointTable.first)


        newMapping := Mapping(hRow, point)
        if (mappingList.contains(newMapping)) { return }

        mappingList.add(newMapping)

        refreshMapping()
        refreshRows()
        refreshPoints()
    }

    private Void onRemoveMapping(Event event)
    {
        sel := mappingTable.selected
        if (sel.isEmpty) { return }

        mapping := (mappingTable.model as MappingTableModel).getRow(sel.first)
        if (mapping != null)
        {
            mappingList.remove(mapping)
        }

        refreshMapping()
        refreshRows()
        refreshPoints()
    }

    private Void refreshMapping()
    {
        mappingTable.model = MappingTableModel(mappingList)
        mappingTable.refreshAll
    }

    private Void refreshRows()
    {
        mappingRows := mappingList.map |Mapping m -> HRow| { m.row }

        haystackTable.model = HRowTableModel(rows.dup.findAll |HRow row -> Bool| { return !mappingRows.contains(row) })
        haystackTable.refreshAll
    }

    private Void refreshPoints()
    {
        mappingPoints := mappingList.map |Mapping m -> Ref| { m.point.id }

        pointTable.model = RecordTableModel(points.dup.findAll |Record point -> Bool| { return !mappingPoints.contains(point.id) })
        pointTable.refreshAll
    }
}
