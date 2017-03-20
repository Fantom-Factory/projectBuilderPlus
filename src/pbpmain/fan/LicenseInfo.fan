/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using fwt
using web
using pbpcore
using kayako
using pbplogging

const class LicenseInfo
{
    const Str:Str sasHosts
    const Bool unlimitedSas
    const Str? recLimit
    const Str? name
    const Str? companyName
    const Str? host
    const Str? timeCreated
    const Str? key

    internal new make(Licensing licensing)
    {
        this.sasHosts = licensing.skysparkHostIds
        this.unlimitedSas = licensing.unlimitedSas
        this.recLimit = licensing.recLimit
        this.name = licensing.name
        this.companyName = licensing.companyName
        this.host = licensing.host
        this.timeCreated = licensing.timeCreated
        this.key = licensing.key
    }

    new makeWith(|This| f)
    {
        f(this)
    }

    ** Check license limit against val records
    ** return false if too many records and warn the user + kayako ticket
    Bool checkLicenseLimit(Int val)
    {
        // Impl: taken from original Licensing class

        if(!unlimitedSas && recLimit.toInt < val)
        {
            Dialog.openInfo(null, "Sorry the project has $val records, but your license only allows for $recLimit ")
            contents:="License upgrade request for:\n\nName:${name}\nCompany:${companyName}\nHost:${host}\nRecords:val\n\nkey:${key}"
            KayakoApi.makeTicket(null, ["departmentid":"7","subject":"License upgrade", "company":companyName,
                                        "fullname":name, "contents":contents])
            Dialog.openInfo(null, "Thank you, we will contact you shortly about your icense upgrade.")
            return false
        }

        // ok license
        return true
    }
}
