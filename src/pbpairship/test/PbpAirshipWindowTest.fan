/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using projectBuilder


class PbpAirshipWindowTest : Test
{
  Void testAirshipWindow()
  {
    PbpAirshipWindow(null, [:],
        LicenseInfo.makeWith()
        {
            it.sasHosts = [:]
            it.unlimitedSas = true
            it.recLimit = "999999"
            it.name = "Mock name"
            it.companyName = "Mock company name"
            it.host = "localhost"
            it.timeCreated = null
            it.key = null
        }).open()
  }
}
