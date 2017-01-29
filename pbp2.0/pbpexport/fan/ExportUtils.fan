/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using pbpcore

final class ExportUtils
{
    private new make()
    {

    }

    static Str generateExportSummary(ExportModel exportModel)
    {
        sb := StrBuf()

        sb.add("Exported records\n")

        sites := exportModel.sitesAndEquips.findAll |Record item -> Bool| { item is Site }
        equips := exportModel.sitesAndEquips.findAll |Record item -> Bool| { item is Equip }

        if (sites.size > 0 )
        {
            sb.add("\n\tSites\n")
            sites.each |rec| { sb.add("\t\t").add( rec.get("dis") ).add("\n") }
        }

        if (equips.size > 0 )
        {
            sb.add("\n\tEquipments\n")
            equips.each |rec| { sb.add("\t\t").add( rec.get("dis") ).add("\n") }
        }

        sb.add("\nConnections\n")
        exportModel.connections.each |conn| { sb.add("\t").add(conn.connectionType.label).add(": IP/Host ").add(conn.deployment).add("\n")}

        return sb.toStr
    }
}
