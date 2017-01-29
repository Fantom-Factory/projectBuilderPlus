/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using projectBuilder
using pbpcore
using pbpgui
using pbpi
using fwt
using gfx
using concurrent
using pbpquery
using [java] org.projecthaystack::HRow
using [java] org.projecthaystack::HVal

/**
 * @author 
 * @version $Revision:$
 */
class PbpConnExt : ConnProvider, UiUpdatable
{
    override Str name
    private ProjectBuilder projectBuilder
    private HaystackConnection[] connections
    private NavNode[] roots
    private ConnectionsPane connectionsPane
    private TreePane treePane
    private HaystackManager haystackManager

    new make(ProjectBuilder projectBuilder)
    {
        this.projectBuilder = projectBuilder
        this.haystackManager = HaystackManager(|Str action, Obj? args| { onHaystackManagerAction(action, args) })
        this.name = "haystackConn"

        this.connections = HaystackConnection[,]
        this.roots = NavNode[,]

        this.connectionsPane = ConnectionsPane(connections,
            |Event e| { onAdd(e) },
            |Event e| { onDelete(e) },
            |Event e| { onEdit(e) },
            |Event e| { onReconnect(e) },
            |Event e| { onSync(e) },
            |Event e| { onRowSelected(e) })

        this.treePane = TreePane(projectBuilder.builder, roots,
            |NavNode[] navNodes| { onAddToProject(navNodes) },
            |NavNode[] siteNodes| { onAddSitesToProject(siteNodes) },
            |NavNode selNavNode| { onLoadNode(selNavNode) })

        UiUpdater(this, projectBuilder.getProjectChangeWatcher).send(null)
    }


    internal Bool fetchAxAnnotatedOnly()
    {
        return treePane.fetchAxAnnotatedOnly
    }

    override Conn[] conns()
    {
        return [,]
    }

    HaystackConnection[] getConnections()
    {
        if (this.connections.size == 0)
            loadConnections()
        return this.connections
    }

    Tab getTab()
    {
        return Tab()
        {
            it.text="Haystack";
            it.image=PBPIcons.sql24;
            SashPane()
            {
                it.orientation = Orientation.vertical
                connectionsPane,
                treePane,
            },
        }
    }

    Void loadConnections()
    {
        haystackManager.stopActorPool()
        haystackManager.startActorPool()

        connections.clear
        roots.clear
        treePane.title = "Connection not selected"
        treePane.selectedConnectionIdx = null
        treePane.refrechRoots

        if (projectBuilder.currentProject != null)
        {
            loadConnectionsFromFile()
            connectionsPane.refrechConnections

            haystackManager.reconnect(connections, true) |HaystackConnection[] conns, [Str:Err] errors|
            {
                showReconnectErrors(errors)
                connectionsPane.refrechConnections
            }
        }
    }

    private Void onAdd(Event event)
    {
        if (!checkProjectOpened()) { return }

        Obj? result := ConnectionEditDialog(projectBuilder.builder, "", "", "", "").open
        if (result is [Str:Obj?])
        {
            map := result as [Str:Obj?]
            name := map["name"]
            uri := map["uri"]
            username := map["username"]
            password := map["password"]

            if (name != null && Uri.fromStr(uri, false) != null && username != null && password != null)
            {
                conn := HaystackConnection.makeWith(name, Uri.fromStr(uri), username, password)
                connections.add(conn)
                saveConnectionsToFile()
                connectionsPane.refrechConnections

                haystackManager.reconnect([conn], false) |HaystackConnection[] conns, [Str:Err] errors|
                {
                    connectionsPane.refrechConnections
                }
            }
        }
    }

    private Void onDelete(Event event)
    {
        if (!checkProjectOpened()) { return }

        conn := connectionsPane.getSelectedConnection()
        connIdx := connectionsPane.getSelectedConnectionIdx()

        if (conn == null) { return }

        if (Dialog.openQuestion(projectBuilder.builder, "Do you want to delete connection '${conn.name}'?", Dialog.yesNo) == Dialog.yes)
        {
            conn.disconnect
            connections.remove(conn)
            saveConnectionsToFile()
            connectionsPane.refrechConnections

            deleteHaystackConnRecord(projectBuilder.currentProject, conn)

            if (connIdx != null && connections.getSafe(connIdx) == null)
            {
                roots.clear
                treePane.title = "Connection not selected"
                treePane.selectedConnectionIdx = null
                treePane.refrechRoots
            }
        }
    }

    private Void onEdit(Event event)
    {
        if (!checkProjectOpened()) { return }

        conn := connectionsPane.getSelectedConnection()

        if (conn == null) { return }

        Obj? result := ConnectionEditDialog(projectBuilder.builder, conn.name, conn.uri.toStr, conn.user, conn.password).open
        if (result is [Str:Obj?])
        {
            map := result as [Str:Obj?]
            name := map["name"]
            uri := map["uri"]
            username := map["username"]
            password := map["password"]

            if (name != null && Uri.fromStr(uri, false) != null && username != null && password != null)
            {
                idx := connections.index(conn) ?: throw Err("Unable to find conn in connections")
                updatedConn := HaystackConnection.makeCopy(conn)
                {
                    it.name = name
                    it.uri = Uri.fromStr(uri)
                    it.user = username
                    it.password = password
                }
                connections[idx] = updatedConn

                updateHaystackConnRecord(projectBuilder.currentProject, updatedConn)

                saveConnectionsToFile()
                connectionsPane.refrechConnections

                haystackManager.reconnect(connections, false) |HaystackConnection[] conns, [Str:Err] errors|
                {
                    connectionsPane.refrechConnections
                }
            }
        }
    }

    private Void onReconnect(Event event)
    {
        if (!checkProjectOpened()) { return }

        conn := connectionsPane.getSelectedConnection()

        if (conn != null)
        {
            haystackManager.reconnect([conn], true) |HaystackConnection[] conns, [Str:Err] errors|
            {
                showReconnectErrors(errors)
                connectionsPane.refrechConnections
            }
        }
    }

    private Void onSync(Event event)
    {
        fetchTree(false)
    }

    private Void fetchTree(Bool recursive)
    {
        if (!checkProjectOpened()) { return }

        conn := connectionsPane.getSelectedConnection()
        if (conn != null && conn.connected)
        {
            roots.clear
            treePane.title = "Loading tree"
            treePane.selectedConnectionIdx = connectionsPane.getSelectedConnectionIdx()
            treePane.refrechRoots

            haystackManager.stopActorPool()
            haystackManager.startActorPool()

            haystackManager.buildTree(conn, recursive, |NavNode[] result|
            {
                roots.clear
                if (conn === connectionsPane.getSelectedConnection())
                {
                    treePane.title = conn.name
                    roots.addAll(result)
                }
                else
                {
                    treePane.title = "Connection not selected"
                    treePane.selectedConnectionIdx = null
                    Dialog.openErr(projectBuilder.builder, "Selection changed during Haystack synchronization!")
                }
                treePane.refrechRoots
            }, null, fetchAxAnnotatedOnly)
        }
    }

    private Bool checkProjectOpened()
    {
         if (projectBuilder.currentProject != null)
         {
            return true
         }
         else
         {
            Dialog.openErr(projectBuilder.builder, "Please select project!")
            return false
         }
    }

    private Void saveConnectionsToFile()
    {
        connDir := projectBuilder.currentProject.connDir

        file := connDir.listFiles.find |File f -> Bool| { f.ext=="haystackconn" } ?: connDir.createFile("list.haystackconn")
        file.writeObj(connections)
    }

    private Void loadConnectionsFromFile()
    {
        connDir := projectBuilder.currentProject.connDir
        file := connDir.listFiles.find |File f -> Bool| { f.ext=="haystackconn" }
        if (file != null)
        {
            conns := file.readObj as HaystackConnection[] ?: throw Err("Unable to read connections from $file")
            conns.each |conn|
            {
                connections.add(conn)
            }
        }
    }

    override Void updateUi(Obj? obj := null)
    {
        loadConnections()
    }

    private Void onRowSelected(Event event)
    {
        onSync(event)
    }

    private Void onAddToProject(NavNode[] selectedNavNodes)
    {
        if (!checkProjectOpened()) { return }

        if (treePane.selectedConnectionIdx != null && connectionsPane.getSelectedConnection() == null)
        {
            connectionsPane.selectConnectionIdx(treePane.selectedConnectionIdx)
        }

        conn := connectionsPane.getSelectedConnection()
        if (conn != null && conn.connected)
        {
            tab := projectBuilder.builder._recordTabs.selected
            if (tab == null) { return }

            selected := findSelectedRecords(tab, projectBuilder).findAll |rec -> Bool| { rec.get("point") != null }
            if (selected.isEmpty)
            {
                Dialog.openInfo(projectBuilder.builder, "You have to select some points from Point or Query tab!")
                return
            }

            project := projectBuilder.currentProject ?: throw Err()

            rows := selectedNavNodes.map |NavNode node -> HRow| { node.row } as HRow[] ?: throw Err()

            ConnMappingDialog(projectBuilder.builder, rows, selected, conn, |HaystackConnection c, Mapping[] mapping -> Bool| { return onApplyMapping(c, mapping) }).open
        }
    }

    private static Record[] findSelectedRecords(Tab tab, ProjectBuilder projectBuilder)
    {
        widget := WidgetUtils.findWidgetOfType(tab.children, Type[RecordExplorer#, SearcherPane#])
        if (projectBuilder.isPointRecordsExplorer(widget))
        {
            return (widget as RecordExplorer).getSelected
        }
        else if (projectBuilder.isQueryRecordsExplorer(widget))
        {
            return (widget as SearcherPane).getSelectedPoints
        }
        else
        {
            return [,]
        }
    }

    private Void onHaystackManagerAction(Str action, Obj? args)
    {
        switch (action)
        {
            case "connStart":
                connectionsPane.showProgress
            case "connEnd":
                connectionsPane.hideProgress
            case "treeStart":
                treePane.showProgress
            case "treeEnd":
                treePane.hideProgress
        }
    }

    private Void showReconnectErrors([Str:Err] errors)
    {
        if (!errors.isEmpty)
        {
            title := Str[,]
            body := Str[,]
            errors.each |e, cName|
            {
                title.add("'${cName}'")
                body.add("${cName} -> ${e.msg}\n${e.traceToStr}")
            }
            titleMsg := title.join(", ")
            bodyMsg := body.join("\n===========================================\n\n")

            Dialog.openErr(projectBuilder.builder, "Unable to connect to ${titleMsg}!", bodyMsg)
        }

    }

    private Bool onApplyMapping(HaystackConnection conn, Mapping[] mapping)
    {
        if (Dialog.openQuestion(projectBuilder.builder, "Do you want apply $mapping.size mapping(s)?", Dialog.yesNo) == Dialog.yes)
        {
            idx := connections.index(conn)
            if (idx == null) { return false }

            haystackManager.mapping(mapping, projectBuilder.builder, idx, projectBuilder,
                |Int connIdx -> HaystackConnection?| { return getConnection(connIdx) },
                |Int connIdx, HaystackConnection newConn| { updateConnection(connIdx, newConn) },
                |Err? err| { onMappingFinished(err) })
            return true
        }

        return false
    }

    private HaystackConnection? getConnection(Int idx)
    {
        return connections.getSafe(idx)
    }

    private Void updateConnection(Int idx, HaystackConnection conn)
    {
        if (connections.getSafe(idx) != null)
        {
            connections[idx] = conn
            connectionsPane.refrechConnections
            saveConnectionsToFile()
        }
    }

    internal static HaystackConnRecord? findHaystackConnRecord(Project project, HaystackConnection conn)
    {
        map := project.database.getClassMap(HaystackConnRecord#) as Str:Obj?
        if (map == null) { return null }

        return (HaystackConnRecord?)map.find(|rec -> Bool| { return rec is HaystackConnRecord && (rec as HaystackConnRecord).id.id == conn.id })
    }

    internal static Void updateHaystackConnRecord(Project project, HaystackConnection conn)
    {
        if (conn.id == null) { return }

        connRec := findHaystackConnRecord(project, conn)
        if (connRec == null) { return }

        connRec = connRec.
            set(UriTag() { it.name = "uri"; it.val = conn.uri}).
            set(StrTag() { it.name = "username"; it.val = conn.user}).
            set(StrTag() { it.name = "dis"; it.val = conn.name})

        project.database.save(connRec)
    }

    internal static Void deleteHaystackConnRecord(Project project, HaystackConnection conn)
    {
        if (conn.id == null) { return }

        connRec := findHaystackConnRecord(project, conn)
        if (connRec == null) { return }

        project.database.removeRec(connRec)
    }

    private Void onMappingFinished(Err? err)
    {
        if (err == null)
        {
            updateRecordsTabs(false, false, true, true)
            Dialog.openInfo(projectBuilder.builder, "Haystack records have been mapped!")
        }
        else
        {
            Dialog.openErr(projectBuilder.builder, "Error while importing mapped records!", err.traceToStr)
        }
    }

    private Void onAddSitesToProject(NavNode[] siteNodes)
    {
        if (!checkProjectOpened()) { return }

        if (!checkSiteNodesAllFetched(siteNodes))
        {
            if (Dialog.openQuestion(projectBuilder.builder, "You have to fetch whole tree to import SEP structure. Do you want to proceed?", Dialog.yesNo) == Dialog.yes)
            {
                fetchTree(true)
            }
            return
        }

        if (!siteNodes.isEmpty)
        {
            tree := Tree() { it.model = NavNodeTreeModel(siteNodes) }
            body := ConstraintPane
            {
                it.minw = 350
                it.minh = 250
                EdgePane()
                {
                    it.top = Label() { it.text = "Do you want to import whole tree structure?"}
                    it.center = tree
                },
            }

            if (Dialog.openMsgBox(Dialog#.pod, "question", projectBuilder.builder, body, null, Dialog.yesNo) == Dialog.yes)
            {
                idx := connectionsPane.getSelectedConnectionIdx
                if (idx != null && idx == treePane.selectedConnectionIdx)
                {
                    haystackManager.sep(siteNodes, projectBuilder.builder, idx, projectBuilder,
                        |Int connIdx -> HaystackConnection?| { return getConnection(connIdx) },
                        |Int connIdx, HaystackConnection newConn| { updateConnection(connIdx, newConn) },
                        |Err? err| { onSepFinished(err) })
                }
            }
        }
        else
        {
            Dialog.openErr(projectBuilder.builder, "No Haystack Nav tree fetched!")
        }
    }

    private static Bool checkSiteNodesAllFetched(NavNode[] nodes)
    {
        return nodes.eachWhile |node|
        {
            if (node.navId != null && node.children.isEmpty)
            {
                return false
            }
            else
            {
                return checkSiteNodesAllFetched(node.children)
            }
        } as Bool ?: true
    }

    private Void onSepFinished(Err? err)
    {
        if (err == null)
        {
            updateRecordsTabs(true, true, true, true)
            Dialog.openInfo(projectBuilder.builder, "Haystack SEP structure have been imported!")
        }
        else
        {
            Dialog.openErr(projectBuilder.builder, "Error while importing SEP structure!", err.traceToStr)
        }
    }

    private Void updateRecordsTabs(Bool siteExp, Bool equipExp, Bool pointExp, Bool queryExp)
    {
        projectBuilder.builder._recordTabs.tabs.each |tab|
        {
            widget := WidgetUtils.findWidgetOfType(tab.children, Type[RecordExplorer#, SearcherPane#])
            if (projectBuilder.isSiteRecordsExplorer(widget) && siteExp)
            {
                recordExplorer := widget as RecordExplorer
                recordExplorer.update(projectBuilder.prj.database.getClassMap(pbpcore::Site#))
                recordExplorer.refreshAll()
            }
            else if (projectBuilder.isEquipRecordsExplorer(widget) && equipExp)
            {
                recordExplorer := widget as RecordExplorer
                recordExplorer.update(projectBuilder.prj.database.getClassMap(pbpcore::Equip#))
                recordExplorer.refreshAll()
            }
            else if (projectBuilder.isPointRecordsExplorer(widget) && pointExp)
            {
                recordExplorer := widget as RecordExplorer
                recordExplorer.update(projectBuilder.prj.database.getClassMap(pbpcore::Point#))
                recordExplorer.refreshAll()
            }
            else if (projectBuilder.isQueryRecordsExplorer(widget) && queryExp)
            {
                searcherPane := widget as SearcherPane
                searcherPane.reloadQuery
            }
        }
    }

    internal static Void expandTreeNodes(Tree tree, Obj[]? nodes := null, |Obj -> Bool| canExpandRoot := |Obj node -> Bool| { return true })
    {
        if (nodes == null)
        {
            expandTreeNodes(tree, tree.model.roots.findAll |node| { canExpandRoot(node) })
        }
        else
        {
            nodes.each |node|
            {
                tree.setExpanded(node, true)
                expandTreeNodes(tree, tree.model.children(node))
            }
        }
    }

    private Void onLoadNode(NavNode selNavNode)
    {
        if (!checkProjectOpened()) { return }

        conn := connectionsPane.getSelectedConnection()
        if (conn != null && conn.connected)
        {
            treePane.title = "Loading tree"
            treePane.selectedConnectionIdx = connectionsPane.getSelectedConnectionIdx()
            treePane.refrechRoots

            haystackManager.stopActorPool()
            haystackManager.startActorPool()

            navPath := findNavNodePath(roots, selNavNode)

            haystackManager.buildTree(conn, false, |NavNode[] result|
            {
                if (conn === connectionsPane.getSelectedConnection())
                {
                    treePane.title = conn.name
                    newRoots := updateNavNodeTree(roots, selNavNode, result)
                    roots.clear
                    roots.addAll(newRoots)
                    treePane.refrechRoots
                    treePane.expandNavPathByNavId(navPath)
                    treePane.selectNodeByNavId(selNavNode)
                }
            }, selNavNode, fetchAxAnnotatedOnly)
        }
    }

    private static NavNode[] updateNavNodeTree(NavNode[] roots, NavNode navNode, NavNode[] newChildren)
    {
        items := NavNode[,]

        roots.each |node|
        {
            if (node === navNode)
            {
                items.add(NavNode.makeWithChildren(navNode, newChildren))
            }
            else
            {
                if (node.children.isEmpty)
                {
                    items.add(node)
                }
                else
                {
                    items.add(NavNode.makeWithChildren(node, updateNavNodeTree(node.children, navNode, newChildren)))
                }
            }
        }

        return items
    }

    private static NavNode[] findNavNodePath(NavNode[] roots, NavNode node)
    {
        path := NavNode[,]
        findNavNodePathRecur(roots, node, path)
        return path.reverse
    }

    private static NavNode? findNavNodePathRecur(NavNode[] roots, NavNode node, NavNode[] path)
    {
        res := roots.eachWhile |n -> NavNode?|
        {
            if (n === node) { return n }
            if (n.children.isEmpty) { return null }

            r := findNavNodePathRecur(n.children, node, path);
            if (r != null)
            {
                path.add(r)
                return n
            }

            return r
        }

        if (res != null) { path.add(res) }

        return res
    }

}
