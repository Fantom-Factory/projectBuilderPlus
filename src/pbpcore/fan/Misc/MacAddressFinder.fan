/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////


// History:
//   14 Jun 12  thibaut Creation
using concurrent
using pbplogging

** Try to find valid mac address
** using native calls since java NetworkInterface proved very unreliable in many ways
** See native calls output examples here : http://www.coffer.com/mac_info/locate-unix.html
class MacAddressFinder
{
  // Patterns for various mac address formats
  Regex lanscan := Regex.fromStr("0x([0-9A-Fa-f]{12}).*")
  Regex dotted  := Regex.fromStr(".*\\W+([0-9A-Fa-f]+:[0-9A-Fa-f]+:[0-9A-Fa-f]+:[0-9A-Fa-f]+:[0-9A-Fa-f]+:[0-9A-Fa-f]+).*")
  Regex dashed  := Regex.fromStr(".*\\W+([0-9A-Fa-f]+\\-[0-9A-Fa-f]+\\-[0-9A-Fa-f]+\\-[0-9A-Fa-f]+\\-[0-9A-Fa-f]+\\-[0-9A-Fa-f]+).*")

  ** Find all mac addresses
  MacAddress[] findAll()
  {
    addresses := [,]
    Str[]? command
    switch(Env.cur.os)
    {
      case "win32":
        command = ["ipconfig", "/all"]
      case "solaris":
        command = ["/usr/sbin/arp", Env.cur.host]
      default: // Other unixes (linux, mac etc...)
        command = File(`/usr/sbin/lanscan`).exists ? ["/usr/sbin/lanscan", "-a"] : ["/sbin/ifconfig", "-a"]
    }
    buf := Buf()
    p := Process(command)
    p.out = buf.out
    try
    {
     p.run.join
     Actor.sleep(250ms)
    }
    catch(Err e)
    {
      Logger.log.err("macaddress error", e)
    }

    return parse(readPayload(buf.flip.readAllBuf))
  }

  private static Str readPayload(Buf buf)
  {
        return DeviceIdFinder.loadStrFromBuf(buf)
  }

  ** Find a mac address, preferably a "good" one (not Vmware)
  ** Ordered by mac address to try to always return the same one
  MacAddress find()
  {
    all := findAll.sort |MacAddress a, MacAddress b->Int| {return a.address <=> b.address}
    // try to get a good one first
    good := all.eachWhile |MacAddress macAddress, int -> MacAddress?|
    {
      if(macAddress.type == "G") return macAddress
      return null
    }
    if(good != null) return good
    // vmware
    good = good ?: all.eachWhile |MacAddress macAddress, int -> MacAddress?|
    {
      if(macAddress.type == "V") return macAddress
      return null
    }
    if(good != null) return good
    // missing
    return MacAddress("000000000000")
 }

  ** Find mac addresses from the process output
  internal MacAddress[] parse(Str data)
  {
    addresses := [,]

    // Try the various mac address patterns
    [lanscan, dotted, dashed].each |Regex regex|
    {
      // Regexp in fantom does not seem to allow using multilines mode, so doing a line at a time
      data.splitLines.each |Str line|
      {
        matcher := regex.matcher(line)
        if(matcher.matches)
        {
          addresses.add(MacAddress(matcher.group(1)))
        }
      }
    }
    return addresses
  }
}

** Represent a normalized MacAddress
class MacAddress
{
  ** Normalized address in format such as AA:BB:55:66:CC
  const Str address
  const Int[] bytes
  const Str type //"G"(ood), "V"(mware) or "M"(issing)

  ** Build and normalize a macAddress
  new make(Str rawAddress)
  {
    bytes = normalize(rawAddress)
    Str a := ""
    bytes.each {a+=it.toHex(2)+":"}
    address = a[0..-2].upper
    if(rawAddress == "000000000000")
       type = "M"; // missing
    else if(bytes[0]==0x0 && bytes[1]==0x50 && bytes[2] == 0x56 && bytes[3]<=0x3F)
       type = "V" // vmware
      // default
    else
       type = "G" //good
  }

  ** Take raw mac address in various formats and return it as an Int Array
  internal Int[] normalize(Str addr)
  {
   Int[] b := [,]
   if(addr.contains(":"))
   {
    addr.split(':').each {b.add(Int.fromStr(it, 16))}
   }
   else if(addr.contains("-"))
   {
    addr.split('-').each {b.add(Int.fromStr(it, 16))}
   }
   else if(addr.size < 12)
   {
    return [0,0,0,0,0,0]
   }
   else
   {
    b.add(Int.fromStr(addr[0..1],16)).add(Int.fromStr(addr[2..3],16)).add(Int.fromStr(addr[4..5],16))
    b.add(Int.fromStr(addr[6..7],16)).add(Int.fromStr(addr[8..9],16)).add(Int.fromStr(addr[10..11],16))
   }
   return b
  }

  override Str toStr() {return address}
}

** Unit tests for this
class MacAddressFinderTest : Test
{
  Void test()
  {
    mac := MacAddressFinder()

    hpux := "\n0x0030E301E72B \n"
    linux := "eth0      Link encap:Ethernet HWaddr 00:08:C7:1B:8C:02 \n inet addr:192.168.111.20  Bcast:192.168.111.255  Mask:255.255.255.0"
    solaris := "le0: flags=863 mtu 1500\ninet 192.168.111.30 netmask ffffff00 broadcast 192.168.111.255\nether 0:3:ba:26:1:b0\n"
    windows := "... 0 Ethernet adapter :\nDescription . . . . . . . . : PPP Adapter.\nPhysical Address. . . . . . : 44-44-F4-54-00-00\n ..."

    // parsing tests
    verifyEq(mac.parse(hpux)[0].toStr , "00:30:E3:01:E7:2B")
    verifyEq(mac.parse(linux)[0].toStr , "00:08:C7:1B:8C:02")
    verifyEq(mac.parse(solaris)[0].toStr, "00:03:BA:26:01:B0")
    verifyEq(mac.parse(windows)[0].toStr, "44:44:F4:54:00:00")

    // bytes tests
    m := mac.parse(hpux)[0]
    verifyEq(m.bytes[0], 0x00)
    verifyEq(m.bytes[1], 0x30)
    verifyEq(m.bytes[2], 0xE3)
    verifyEq(m.bytes[3], 0x01)
    verifyEq(m.bytes[4], 0xE7)
    verifyEq(m.bytes[5], 0x2B)

    // type tests
    verifyEq(mac.find.type, "G")
    verify(mac.parse("JUNK").isEmpty)
    verifyEq(mac.parse("0x005056325555")[0].type, "V")
   }
}
