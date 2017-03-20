/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore
using pbpnhaystack
using pbplogging
using haystack

**
** Encapsulate Haystack connection operations.
** Most of the operations exists in pbpnhaystack, but a bit hard to reuse.
** So we copy the codes here.
**
class HaystackConnManager
{
	Project project
	private HaystackConnection[] connections := HaystackConnection[,]

	new make(Project project)
	{
		this.project = project
		loadConnectionsFromFile()
	}

	HaystackConnection[] getConnections()
	{
		return connections
	}

    HaystackConnRecord? findOrCreateConnRecord(HaystackConnection conn)
    {
		map := this.project.database.getClassMap(HaystackConnRecord#) as Str:Obj?

        connRec := (HaystackConnRecord?)map
                    ?.find(|rec -> Bool| {
                        return rec is HaystackConnRecord &&
                               (rec as HaystackConnRecord).id.id == conn.id }
                    )

        //
        // No Record created yet for this connection, we create a new record
        //
        if (connRec == null)
        {
        	Logger.log.info("No existing record found for connection ${conn.uri}, creating a new HaystackConnRecord.")

        	idx := connections.findIndex { it.name == conn.name && it.uri == conn.uri && it.user == conn.user }
			if (idx == null)
				throw Err("No existing connection found in saved Haystack connections")

			tmp := HaystackConnection.makeCopy(connections[idx]) { it.id = Ref.gen.toStr }
			connections[idx] = tmp

            connRec = HaystackConnRecord() { it.id = Ref.fromStr(tmp.id); }
            connRec = connRec.
			            set(MarkerTag() { it.name = "haystackConn"; it.val = "haystackConn" }).
			            set(UriTag() { it.name = "uri"; it.val = tmp.uri}).
			            set(StrTag() { it.name = "username"; it.val = tmp.user}).
			            set(StrTag() { it.name = "dis"; it.val = tmp.name})

            project.database.save(connRec)
            saveConnectionsToFile()
        }

        return connRec
    }

	private Void saveConnectionsToFile()
    {
        connDir := this.project.connDir
        file := connDir.listFiles.find |File f -> Bool| { f.ext=="haystackconn" } ?: connDir.createFile("list.haystackconn")
        file.writeObj(connections)
    }

    private Void loadConnectionsFromFile()
    {
        connDir := this.project.connDir
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

}
