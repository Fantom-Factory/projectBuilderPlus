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
using pbpnhaystack

class ConfigurePane : EdgePane
{
    private static const File ordTemplatesDir := Env.cur.homeDir + `resources/ordtemplates.list`

    private ProjectBuilder projectBuilder

    private Combo siteCombo
    private Combo sleepCombo
    Text equipText { private set }
    private |Record?| onSiteSelectedFunc
    private |Int?| onSleepSelectedFunc
    private Combo haystackCombo
    private Combo obixCombo
    ProgressBar progressBar { private set }
    Label progressLabel { private set }
    private Table pageTable
    PageTableModel? pageTableModel { set { &pageTableModel = it; pageTable.model = it; pageTable.refreshAll; textLint.text = ""; labelSelectedRows.text = "" } }
    private Text textLint
    private Label labelSelectedRows
    private Button importButton

    private Button insertButton
    private Button editButton
    private Button deleteButton
    private Button moveUpButton
    private Button moveDownButton
    private Table ordTemplatesTable
    private Str[] ordTemplates

    new make(ProjectBuilder projectBuilder, Button importButton, |Record?| onSiteSelectedFunc, |Int?| onSleepSelectedFunc) : super.make()
    {
        this.projectBuilder = projectBuilder
        this.importButton = importButton
        this.onSiteSelectedFunc = onSiteSelectedFunc
        this.onSleepSelectedFunc = onSleepSelectedFunc

        this.siteCombo = Combo()
        {
            it.onModify.add |Event e| { onSiteComboModify(e) }
        }

        this.sleepCombo = Combo()
        {
            it.items = [0, 100, 250, 500, 1000]
            it.selectedIndex = 0
            it.onModify.add |Event e| { onSleepComboModify(e) }
        }

        this.equipText = Text()

        this.progressBar = ProgressBar()

        this.progressLabel = Label() { it.text = "" }

        this.haystackCombo = Combo()
        {
            it.items = getHaystackComboItems()
        }

        this.obixCombo = Combo()
        {
            it.items = getObixComboItems()
        }

        this.pageTable = Table()
        {
            it.multi = true
            it.onSelect.add |event| { onTableRowSelected(event) }
            it.onPopup.add |event| { onTablePopup(event) }
        }

        this.textLint = Text() { it.multiLine = true; it.editable = false;  }

        this.labelSelectedRows = Label()


        this.ordTemplates = loadOrdTemplates()
        this.ordTemplatesTable = Table()
        {
            it.model = OrdTemplatesTableModel(ordTemplates)
            it.multi = false
        }

        this.insertButton = Button() { it.text = "Insert"; it.onAction.add |event| { onInsertButtonClicked(event) } }
        this.editButton = Button() { it.text = "Edit"; it.onAction.add |event| { onEditButtonClicked(event) } }
        this.deleteButton = Button() { it.text = "Delete"; it.onAction.add |event| { onDeleteButtonClicked(event) } }
        this.moveUpButton = Button() { it.text = "Move up"; it.onAction.add |event| { onMoveUpButtonClicked(event) } }
        this.moveDownButton = Button() { it.text = "Move down"; it.onAction.add |event| { onMoveDownButtonClicked(event) } }

        this.center = InsetPane(12, 12, 0, 12)
        {
            it.content = EdgePane()
            {
                it.top = createFormPane()
                it.center = InsetPane() { it.content = createPageTablePane() }
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

        fillSiteCombo()

        relayout()
    }

    private Void onTableRowSelected(Event event)
    {
        showLintOnRowSelect(event)

        importButton.enabled = pageTable.selected.size > 0

        showMessageOnRowSelect(event)

//        if (pageTableModel != null)
//        {
//            pageTable.selected.each |row|
//            {
//                echo(pageTableModel.rows[row])
//            }
//        }
    }

    private Void onTablePopup(Event event)
    {
        if (ordTemplates.isEmpty || pageTableModel == null) { return }

        menu := Menu()
        menu.add(MenuItem()
        {
            it.text = "Clear templates"
            it.onAction.add |e|
            {
                pageTableModel.clearTemplates(pageTable.selected)
                pageTable.refreshAll
            }
        })
        menu.addSep

        ordTemplates.each |template|
        {
            menu.add(MenuItem()
            {
                it.text = template
                it.onAction.add |e|
                {
                    selected := pageTable.selected
                    pageTableModel.setTemplateToRows(pageTable.selected, template)
                    pageTable.refreshAll
                    pageTable.selected = selected
                }
            })
        }

        event.popup = menu
    }

    private Void showMessageOnRowSelect(Event event)
    {
        pageTableModel := pageTable.model as PageTableModel

        selectedPages := pageTableModel.rows.findAll |page, idx -> Bool| { pageTable.selected.contains(idx) }

        lintCount := selectedPages.reduce(0) |Int sum, page -> Int|
        {
            sum += pageTableModel.lintErrorIndex?.get(page)?.size ?: 0
        }

        labelSelectedRows.text = "Selected ${selectedPages.size} page(s)" + (lintCount > 0 ? " with ${lintCount} lint(s) - pages with lint errors won't be saved." : "")
    }

    private Void showLintOnRowSelect(Event event)
    {
        pageTableModel := pageTable.model as PageTableModel

        lintMessage := ""
        if (pageTableModel.lintErrorIndex != null && event.index != null)
        {
            lintErrors := pageTableModel.lintErrorIndex[pageTableModel.rows[event.index]]

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

    private SashPane createPageTablePane()
    {
        return SashPane()
        {
            it.weights = [80,20]
            pageTable,
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

    private EdgePane createFormPane()
    {
        return EdgePane()
        {
            it.left = GridPane()
            {
                it.numCols = 2
                Label() { it.text = "Obix Connection" },
                obixCombo,
                Label() { it.text = "NHaystack Connection" },
                haystackCombo,
                // Label(),
                // Label() { it.text = "NHaystack mapping will be used if it is not empty." },
                Label() { it.text = "Site" },
                siteCombo,
                Label() { it.text = "Equip base name" },
                equipText,
                Label() { it.text = "HTTP sleep in ms" },
                sleepCombo,
            }
            it.right = createOrdTemplatesPane()
        }
    }

    private ConstraintPane createOrdTemplatesPane()
    {
        return ConstraintPane()
        {
            it.minw = 400
            it.content = EdgePane()
            {
                it.center = ordTemplatesTable
                it.bottom = GridPane()
                {
                    it.numCols = 5
                    insertButton,
                    editButton,
                    deleteButton,
                    moveUpButton,
                    moveDownButton
                }
            }
        }
    }

    private Obj[] getObixComboItems()
    {
        obixConnProvider := projectBuilder.connProviders["ObixConnProvider"] as pbpobix::PbpConnExt ?: throw Err("Unable to find ObixConnProvider in $projectBuilder.connProviders")
        return obixConnProvider.manager.getConnections
    }

    private Obj[] getHaystackComboItems()
    {
        conns := HaystackConnManager(projectBuilder.currentProject).getConnections().dup
        conns.insert(0, HaystackConnection.makeWith("Empty", ``, "", ""))
        return conns
    }

    LoadConfig getLoadConfig()
    {
        obix := obixCombo.selected as PbpObixConn
        haystack := haystackCombo.selected as HaystackConnection

        return LoadConfig()
        {
            mapping = (haystack.name == "Empty") ? MappingType.obix : MappingType.haystack
            obixUri = Uri.fromStr(obix.host, false)
            obixUser = obix.user
            obixPassword = obix.conn.plainPassword
            haystackUri = haystack.uri
            haystackUser = haystack.user
            haystackPassword = haystack.password
            sleep = (sleepCombo.selectedIndex == -1) ? 0 : sleepCombo.selected
            getDisMacro = (projectBuilder.currentProject.projectConfigProps["useDisMacro"] == "true")
        }
    }

    PbpObixConn? selectedObixConn()
    {
        return  obixCombo.selected as PbpObixConn
    }

    HaystackConnection? selectedHaystackConn()
    {
        conn := haystackCombo.selected as HaystackConnection
        return (conn == null || conn.name == "Empty") ? null : conn
    }

    private Void fillSiteCombo()
    {
        siteCombo.items = getComboItemsFor(Site#)
        if (siteCombo.items.size > 0) siteCombo.selectedIndex = 0
    }

    private Obj[] getComboItemsFor(Type type)
    {
        recordMap := projectBuilder.currentProject.database.getClassMap(type)

        return recordMap.vals.map |Record rec -> RecordComboItem| { RecordComboItem(rec) }
    }

    private Void onSiteComboModify(Event e)
    {
        record := siteCombo.selectedIndex == -1 ? null : (siteCombo.selected as RecordComboItem)?.record as Record

        onSiteSelectedFunc(record)
    }

    private Void onSleepComboModify(Event e)
    {
        sleep := (sleepCombo.selectedIndex == -1 ? null : sleepCombo.selected) as Int

        onSleepSelectedFunc(sleep)
    }

    Int[] selectedPagesIdx()
    {
        return pageTable.selected
    }

    private Void onInsertButtonClicked(Event e)
    {
        value := Dialog.openPromptStr(this.window, "Insert new template definition")
        if (value != null)
        {
            (ordTemplatesTable.model as OrdTemplatesTableModel).addTemplate(value)
            saveOrdTemplates(ordTemplates, pageTableModel)
            ordTemplatesTable.refreshAll
        }
    }

    private Void onEditButtonClicked(Event e)
    {
        model := (ordTemplatesTable.model as OrdTemplatesTableModel)

        if (checkNoOrdTemplateSelected("to edit")) { return }

        oldTemplate := model.getTemplate(ordTemplatesTable.selected.first)

        value := Dialog.openPromptStr(this.window, "Insert new template definition", oldTemplate)
        if (value != null)
        {
            model.editTemplate(ordTemplatesTable.selected.first, value)
            saveOrdTemplates(ordTemplates, pageTableModel)
            ordTemplatesTable.refreshAll
        }
    }

    private Void onDeleteButtonClicked(Event e)
    {
        model := (ordTemplatesTable.model as OrdTemplatesTableModel)

        if (checkNoOrdTemplateSelected("to delete")) { return }

        if (model.numRows == 1)
        {
            Dialog.openInfo(this.window, "Unable to delete last template!")
            return ;
        }

        oldTemplate := model.getTemplate(ordTemplatesTable.selected.first)

        if (Dialog.openQuestion(this.window, "Delete template '${oldTemplate}'?", null, Dialog.yesNo) == Dialog.yes)
        {
            model.deleteTemplate(ordTemplatesTable.selected.first)
            saveOrdTemplates(ordTemplates, pageTableModel)
            ordTemplatesTable.refreshAll
        }
    }

    private Void onMoveUpButtonClicked(Event event)
    {
        moveTemplate(ordTemplatesTable, ordTemplates, true, pageTableModel)
    }

    private Void onMoveDownButtonClicked(Event event)
    {
        moveTemplate(ordTemplatesTable, ordTemplates, false, pageTableModel)
    }

    private static Void moveTemplate(Table ordTemplatesTable, Str[] ordTemplates, Bool up, PageTableModel pageTableModel)
    {
        model := (ordTemplatesTable.model as OrdTemplatesTableModel)

        selected := ordTemplatesTable.selected
        if (selected.isEmpty) { return }

        index := selected.first

        if ((!up && index < model.numRows - 1) ||
            (up && index > 0))
        {
            model.swap(index, index + (up ? -1 : +1))
            ordTemplatesTable.refreshAll
            ordTemplatesTable.selected = [index + (up ? -1 : +1)]
            saveOrdTemplates(ordTemplates, pageTableModel)
        }
    }

    private Bool checkNoOrdTemplateSelected(Str msg)
    {
        if (ordTemplatesTable.selected.isEmpty)
        {
            Dialog.openInfo(this.window, "No template selected ${msg}!")
            return true
        }
        else
        {
            return false
        }
    }

    private static Str[] loadOrdTemplates()
    {
        if(ordTemplatesDir.exists)
        {
            return ordTemplatesDir.readObj
        }
        else
        {
            return Str[,]
        }
    }

    private static Void saveOrdTemplates(Str[] ordTemplates, PageTableModel pageTableModel)
    {
        if (!ordTemplates.isEmpty) { pageTableModel.defaultTemplate = ordTemplates[0] }

        if(!ordTemplatesDir.exists)
        {
            ordTemplatesDir.create
        }

        ordTemplatesDir.writeObj(ordTemplates)
    }

    Str defaultTemplate()
    {
        model := (ordTemplatesTable.model as OrdTemplatesTableModel)

        return (model.numRows > 0 ? model.getTemplate(0) : "add template")
    }
}

const class LoadConfig
{
    const MappingType mapping
    const Uri? obixUri
    const Str? obixUser
    const Str? obixPassword
    const Uri? haystackUri
    const Str? haystackUser
    const Str? haystackPassword
    const Int? sleep
    const Bool getDisMacro

    new make(|This|? f := null) { f?.call(this) }
}

enum class MappingType
{
    obix,
    haystack
}
