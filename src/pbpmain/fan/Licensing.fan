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

** Check license against licensing server.
internal class Licensing{

  private static const Str key1 := "I"+(8+1).toStr+"HBRREUyeZq8Bt21eM7AqsqGX"+"3hP8pwwXaVH8PwKnlminipOE1pedLfRRn2r6VPTQ0UHvlJn7NABaFmhEHaIeG"+"U10OHBYataWBy"
  private static const Str key2 := "ShpFVOp1V"+"jDkiXw1zHRYK8F"+(2+2).toStr+"GIVgjujJRwJ5nuDO9"+"tuzkpsgh2P3r8GldnKManvcBQEah2QpMJ9mtTdJSHuueBSIFjoDa92D0ZXX"
  private static const Str key3 := "P7fFWuNgXaRchieJ"+"qrw3Vk7t3HWm05JaiA"+(3+2).toStr+"boBluqCEja8RN1lKIJdR"+"vAC4g4VMwLyKHVHSTQ6Zg3h9O44bOhDGRTIDok"+"lapcTPh"
  private static const Str key4 := "aOCd2jX9H"+"conzYLJTJieWOh8H3Dgd4a0dSLAZpvwELnGOZK03tN"+(11-2).toStr+"1FomJpILAyyUtXKzpv7WRHPM"+"UDQJaxfvp7doE7Ueu4kJIg"+"vA"

  private File? liscenseFile
  private File? requestFile
//  private Str? uuid
//  Str? name
//  Str? companyName
//  Str? host
//  Str? recLimit
//  Str? timeCreated
//  Str? key
//  Str? skysparkIds
//  Bool unlimitedSas := false

  private Str? uuid	:= "058080ef-3063-f580-c540-005056000010"
  Str? name			:= "Project Builder Plus - Open Source"
  Str? companyName	:= "Alien-Factory"
  Str? host			:= "<host>"
  Str? recLimit		:= Int.maxVal.toStr
  Str? timeCreated	:= DateTime.now.toStr
  Str? key			:= "???"
  Str? skysparkIds	:= "*ANY*"

  Bool unlimitedSas := true

  Str:Str skysparkHostIds := [:]

  private MacAddressFinder addressFinder := MacAddressFinder()

  Bool checkLicense()
  {
    return true
		
    lookupLicenseFile
    lookupRequestFile
    if(liscenseFile == null && requestFile.exists)
    {
      fetched := fetchLicense
      if(!fetched)
      {
        Dialog.openWarn(null,"The license has not been approved yet.\nPlease try again later.")
        return false
      }
    }

    liscenseFile = File(Env.cur.homeDir.toStr.toUri+`resources/auth/`).listFiles.find |File f -> Bool|{return f.ext == "lic"}
    if(liscenseFile == null)
    {
      Logger.log.info("No License file found")

      showLicenseForm
      return false
    }
    readLicense

    if(skysparkHostIds.keys.contains("*ANY*"))
    {
      // unlimitedSas mode
      unlimitedSas = true
      // delete the license so it will have to be re-fetched at each restart
      liscenseFile.delete
    }

    valid := validateLicense()
    if(!valid)
    {
      Logger.log.info("Invalid license file : $liscenseFile.osPath")
      Dialog.openWarn(null,"Invalid License $liscenseFile.name")
    }
    else
    {
      Logger.log.info("Accepted license : $liscenseFile.osPath")
    }

    return valid
  }

  ** call to bass server and check whether the license is active or not
  Bool fetchLicense()
  {
    company := requestFile.readAllStr
    data := ["company" : company, "key" : (Desktop.isWindows || Desktop.isMac ? getDeviceIdHash(DeviceIdFinder.findId) : getMacAddressHash(addressFinder.find))]
    try
    {
      Logger.log.info("Fetching license for $company")
      url := "http://"+Env.cur.index("bass.licensing.server.url").first+":"+Env.cur.index("bass.licensing.server.port").first+"/fetch"
      webCon := WebClient(url.toUri)
      webCon.socketOptions.receiveTimeout = 30sec
      webCon.postForm(data)
      resCode := webCon.resCode
      licenseData := webCon.resIn.readAllStr
      if(resCode!=200)
      {
        Logger.log.info("License retrieval failed: $resCode")
        return false
      }

      File? liscenseFile := File(Env.cur.homeDir.toStr.toUri+`resources/auth/${company.trim}.lic`)
      liscenseFile.out.print(licenseData).close

      return true
    }
    catch(IOErr e)
    {
      Logger.log.info("Failed fetching the license ! $e")
    }
    catch(Err e)
    {
      Logger.log.info("Failed fetching the license ! $e")
    }
    return false
  }

  Void showLicenseForm()
  {
    name := Text{prefCols = 20}
    company := Text{prefCols = 20}
    email := Text{prefCols = 20}
    po := Text{prefCols = 20}
    hostname := Text{prefCols = 20; text = Env.cur.host}
    Str button := "cancel"
    Window? w
    w = Window(null)
    {
      title = "You need to request a License"
      alwaysOnTop = true
      InsetPane
      {
        GridPane
        {
          numCols = 2
          Label{text = "Name"},
          name,
          Label{text = "Company"},
          company,
          Label{text = "Email"},
          email,
          Label{text = "PO"},
          po,
          Label{text = "Hostname"},
          hostname,
          Button{text="Request License"; onAction.add {button = "license" ; w.close}},
          Button{text="Request SAS License"; onAction.add {button = "sasLicense" ; w.close}},
          Button{text="Cancel"; onAction.add {w.close}},
        },
      },
    }
    w.open

    if(button != "cancel")
    {
      compName := ""
      company.text.trim.each {compName += (it.isAlphaNum ? it.toChar : "_")}
      compName.replace("," , "_")
      key := (Desktop.isWindows || Desktop.isMac ? getDeviceIdHash(DeviceIdFinder.findId) : getMacAddressHash(addressFinder.find))
      data := [
        "Name" : name.text,
        "Company" : compName,
        "Email" : email.text,
        "PO" : po.text,
        "Hostname" : hostname.text,
        "Key" : key,
        "Mactype" : addressFinder.find.type,
        "LicType" : button=="license" ? "standalone" : "sas"
      ]

      Dialog.openInfo(null, "Press Ok to send the license data to the server.")

      // send data
      try
      {
        url := "http://"+Env.cur.index("bass.licensing.server.url").first+":"+Env.cur.index("bass.licensing.server.port").first+"/request"
        webCon := WebClient(url.toUri)
        webCon.postForm(data)
        webCon.close

        File? requestFile := File(Env.cur.homeDir.toStr.toUri+`resources/auth/request.txt`)
        requestFile.out.print(compName).close

        // creating kayako ticket
        KayakoApi.createLicenseTicket(data["Company"], data["Name"], data["Email"], data.toStr)

        Dialog.openInfo(null, "License data was sent to the server.")
      }
      catch(Err e)
      {
        Logger.log.info("Failed to send the license data to the server ! $e")
        Dialog.openWarn(null, "Failed to send the license data to the server ! $e")
      }

    }
  }

  ** Get the (valid) mac addresses - Obfuscated a bit into an MD5 hash
  internal Str getMacAddressHash(MacAddress address)
  {
    if(address.type == "M")
    {
      return address.address
    }
    buf:= Buf().print("projectBuilder") // salt
    address.bytes.each {buf.print(it)}
    hash := buf.toDigest("MD5").toHex
    return hash
  }

    internal Str getDeviceIdHash(Str deviceId)
    {
        return Buf().print("projectBuilder" /* salt */).print(deviceId).toDigest("MD5").toHex
    }

  internal static Str rotate(Str str, Int offset)
  {
    Buf s := Buf().writeUtf(str)
    (0 ..< str.size).each
    {
      idx := it + offset
      if(idx >= str.size)
        idx = idx - str.size
      else if(idx < 0)
        idx = str.size + idx
      a := str[it]
      s[idx] = str[it]
    }
    return s.flip[0 ..< str.size].readAllStr
  }

  Void lookupLicenseFile()
  {
    liscenseFile = File(Env.cur.homeDir.toStr.toUri+`resources/auth/`).listFiles.find |File f -> Bool|{return f.ext == "lic"}
  }

  Void lookupRequestFile()
  {
    requestFile = File(Env.cur.homeDir.toStr.toUri+`resources/auth/request.txt`)
  }

  Void readLicense()
  {
    Str[] values := liscenseFile.readAllLines
    uuid = values[0].split(',')[1]
    name = values[1].split(',')[1]
    companyName = values[2].split(',')[1]
    host = values[3].split(',')[1]
    recLimit = values[4].split(',')[1]
    timeCreated = values[5].split(',')[1]
    key = values[6].split(',')[1]
    if(values.size > 7 && values[7].startsWith("SkysparkIds"))
        skysparkIds = values[7].split(',')[1..-1].join(",")
        Logger.log.info("spids: $skysparkIds")
    if(skysparkIds != null)
    {
      skysparkHostIds.clear
      skysparkIds.split(',').each |item|
      {
        if(! item.trim.isEmpty && item.contains(":"))
        {
          parts := item.split(':')
          skysparkHostIds[parts[0]] = parts[1]
        }
      }
      Logger.log.info(skysparkHostIds.toStr)
    }
  }

//  ** Check license limit against val records
//  ** return false if too many records and warn the user + kayako ticket
//  Bool checkLicenseLimit(Int val)
//  {
//    if(!unlimitedSas && recLimit.toInt < val)
//    {
//        Dialog.openInfo(null, "Sorry the project has $val records, but your license only allows for $recLimit ")
//        contents:="License upgrade request for:\n\nName:${name}\nCompany:${companyName}\nHost:${host}\nRecords:val\n\nkey:${key}"
//        KayakoApi.makeTicket(null, ["departmentid":"7","subject":"License upgrade", "company":companyName,
//                                "fullname":name, "contents":contents])
//        Dialog.openInfo(null, "Thank you, we will contact you shortly about your icense upgrade.")
//        return false
//    }
//    // ok license
//    return true
//  }

    Bool validateLicense()
    {

        valid := false
        // check against all valid interfaces in case new ones showed up
        addressFinder.findAll.eachWhile |MacAddress address -> Bool?|
        {
            valid = checkKeys(key, name, companyName, host, recLimit, uuid, timeCreated, getMacAddressHash(address), skysparkIds)

            return (valid ? true : null)
        }

        if (!valid && (Desktop.isWindows || Desktop.isMac))
        {
            Logger.log.info("Unable to validate license using old method.")
            deviceHash := getDeviceIdHash(DeviceIdFinder.findId)
            valid = checkKeys(key, name, companyName, host, recLimit, uuid, timeCreated, deviceHash, skysparkIds)
        }

        return valid
    }

    private static Bool checkKeys(Str key, Str name, Str companyName, Str host, Str recLimit, Str uuid, Str timeCreated, Str deviceHash, Str? skysparkIds)
    {
        skysparkIds = skysparkIds ?: ""
        toHash := "${name}${companyName}${host}${recLimit}${uuid}${timeCreated}${deviceHash}${skysparkIds}"
        keysToCheck := [rotate(key1, -11), rotate(key2, -22), rotate(key3, -44), rotate(key4, -66)]
        linesToCheck := Str[,]

        keysToCheck.shuffle.each |keyz|
        {
            linesToCheck.push(toHash.toBuf.hmac("MD5", keyz.toBuf).toHex)
        }

        return linesToCheck.contains(key)
    }
}

