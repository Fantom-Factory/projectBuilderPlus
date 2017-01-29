/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using gfx
using projectBuilder
using pbpcore

class Step2Connections : ContentPane
{
    private ProjectBuilder projectBuilder
    private ExportModel exportModel
    private GridPane gridPane
    private Button btnAllSame

    new make(ProjectBuilder projectBuilder, ExportModel exportModel)
    {
        this.projectBuilder = projectBuilder
        this.exportModel = exportModel

        Str projectName := projectBuilder.currentProject.name
        File connDir := FileUtil.getConnDir(projectName)

        connDir.listFiles.each |File f| {
          PersistConn? conn := PersistConn.load(f)
          ConnectionModel? model
          if(conn!=null) {
              model = ConnectionModel(ConnectionType.fromStr(f.ext), conn.params["host"], conn.params["host"])
            exportModel.connections.push(model)
          }
        }

        this.btnAllSame = Button()
        {
            it.text = "All same"
            it.onAction.add |Event event|
            {
                exportModel.connections.each |conn|
                {
                    conn.deployment = conn.current
                }

                gridPane.each |widget| { (widget as Step2ConnectionsRow).updateFromModel }
            }
        }

        this.content = EdgePane()
        {
            top = InsetPane(0, 0, 5, 0) { it.content = EdgePane()
            {
                center = Label() { text = "Connectors based on the selection (Please change IP Address for deployment)" }
                right = btnAllSame
            } }
            center = ScrollPane() { it.content = gridPane = GridPane() }
        }
        /* Dummy Code, shouldn't need this.
        if (exportModel.connections.isEmpty)
        {
            exportModel.connections.addAll([ConnectionModel(ConnectionType.obixConn, "adsf", "zvxc"), ConnectionModel(ConnectionType.sql, "zzadsf", "fffff")])
        }*/

        exportModel.connections.each |connection|
        {
            gridPane.add(Step2ConnectionsRow(connection))
        }

        content.relayout
    }
}

class Step2ConnectionsRow : ContentPane
{
    private ConnectionModel connectionModel
    private GridPane gridPane
    private Text textCurrent
    private Text textDeployment

    new make(ConnectionModel connectionModel)
    {
        this.connectionModel = connectionModel

        this.textCurrent = Text()
        {
            it.onModify.add |event|
            {
                connectionModel.current = textCurrent.text
            }
        }

        this.textDeployment = Text()
        {
            it.onModify.add |event|
            {
                connectionModel.deployment = textDeployment.text
            }
        }

        this.gridPane = GridPane()
        {
            numCols = 4
            halignPane = Halign.right
            Label(),
            Label() { text = "Current" },
            Label() { text = "Deployment" },
            Label(),
            // new row
            Label() { text = "IP/Host" },
            textCurrent,
            textDeployment,
            Button()
            {
                it.text = "Same"
                it.onAction.add |Event event|
                {
                    connectionModel.deployment = connectionModel.current
                    updateFromModel
                }
            }
        }

        this.content = BorderPane()
        {
            it.border = Border.fromStr("0,0,1,0")
            it.insets = Insets.fromStr("5")
            it.content = EdgePane()
            {
                it.top = Label() { text = connectionModel.connectionType.label }
                it.center = gridPane
            }
        }

        updateFromModel
    }

    Void updateFromModel()
    {
        textCurrent.text = connectionModel.current
        textDeployment.text = connectionModel.deployment
    }
}

class ConnectionModel
{
    ConnectionType connectionType
    Str current
    Str deployment

    new make(ConnectionType connectionType, Str current, Str deployment)
    {
        this.connectionType = connectionType
        this.current = current
        this.deployment = deployment
    }
}

enum class ConnectionType
{
    obixConn("Obix connection"), sedona("Sedona"), skyconn("Skyspark"), sqlconn("SQL")

    private new make(Str label) { this.label = label; }

    const Str label
}
