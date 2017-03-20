/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using web
using xml
using pbplogging
using concurrent
using [java] org.projecthaystack.client::HClient
using [java] org.projecthaystack::HGrid
using [java] org.projecthaystack::HRow
using [java] org.projecthaystack::HStr
using [java] org.projecthaystack::HNum
using [java] org.projecthaystack::HRef
using [java] org.projecthaystack::HBool
using [java] org.projecthaystack::HMarker
using [java] org.projecthaystack::HGridBuilder

class PointReader
{
    MappingType mapping := MappingType.obix

    Uri? obixUri
    Str? obixUser
    Str? obixPassword

    Uri? haystackUri
    Str? haystackUser
    Str? haystackPassword

    Int sleep := 0

    Bool getDisMacro := true

    Point[] readPoints(|Int, Int, Str|? progressFunc := null)
    {
        station := getStation(obixUri)

        pages := fetchPages(obixUri, progressFunc)

        points := readPointsFromPage(pages.vals, progressFunc)

        if (mapping == MappingType.haystack)
        {
            points = getHaystackPoint(points, progressFunc)
        }
        else
        {
            points = enhanceWithObixHis2(obixUri, station, points, progressFunc)
            points = enhanceWithUnitKind(points, progressFunc)
        }
        return points
    }

    **
    **  Factory method for WebClient creation. Adds neccessary req headers for basic auth
    **
    private WebClient createWebClientForObix(Uri? uri := null)
    {
        c := WebClient(uri)
        if(obixUser != null && obixPassword != null)
        {
            c.reqHeaders["Authorization"] = "Basic " + "$obixUser:$obixPassword".toBuf.toBase64
        }
        return c
    }

    private Uri getStation(Uri base)
    {
        c := createWebClientForObix(base + `obix/config/`)
        try
        {
            c.writeReq
            c.readRes
            if (c.resCode != 200)
                throw IOErr("Cant' connect to ${c.reqUri}! Response code: $c.resCode, phrase: $c.resPhrase")

            return parseStation(c.resBuf.in)
        }
        finally
        {
            c.close
        }
    }

    /*
<obj href="http://vm1.bassg.com:8080/obix/config/"
     is="/obix/def/baja:Station"
     display="Station"
     icon="/ord?module://icons/x16/database.png"
     xsi:schemaLocation="http://obix.org/ns/schema/1.0/obix/xsd">
  <str name="stationName"
       val="aesDemo"
       href="stationName/"
       displayName="Station Name"></str>
</obj>
    */
    private Uri parseStation(InStream in)
    {
        parser := XParser(in)

        while (parser.next != null)
        {
            if (parser.nodeType == XNodeType.elemStart &&
                parser.elem.name == "str" &&
                parser.depth == 1)
            {
                attrs := toAttrMap(parser.elem.attrs)
                if (attrs["name"] == "stationName")
                {
                    val := attrs["val"]
                    return (val[-1..-1] != "/" ? "${val}/" : val).toUri
                }
            }
        }
        throw Err("Unable to find stationName")
    }

    private Point[] enhanceWithObixHis(Point[] obixPoints, |Int, Int, Str|? progressFunc := null)
    {
        c := createWebClientForObix()
        try {
            points := Point[,]

            i := 0
            n := obixPoints.size

            obixPoints.each |p|
            {
                if (p.obix != null && p.obix.toStr.trim != "")
                {
                    c.reqUri = p.obix;
                    c.writeReq
                    c.readRes

                    if (c.resCode != 200)
                    {
                        throw IOErr("Can't connect to $p.obix! Response code: $c.resCode, phrase: $c.resPhrase")
                    }

                    Logger.log.info("Processing point $p.obix")
                    points.add(parseObixHis(p, c.resBuf.in))

                    Actor.sleep(Duration.fromStr("${sleep}ms"))
                }
                else
                {
                    points.add(p)
                }

                progressFunc?.call(i, n, "Obix his")
                i++
            }

            return points
        } finally {
            c.close
        }

    }

    private Point parseObixHis(Point point, InStream respIn)
    {
        parser := XParser(respIn)
        while (parser.next != null)
        {
            if (parser.nodeType == XNodeType.elemStart &&
                parser.elem.name == "ref" &&
                parser.depth == 1)
            {
                attrs := toAttrMap(parser.elem.attrs)
                if (attrs["name"] == "HistoryPathCapturerExt")
                {
                    return Point(point)
                    {
                        it.obixHis = point.page.base + point.page.res + (attrs["href"]).toUri
                    }
                }
            }
        }

        return point
    }

    private Point[] readPointsFromPage(Page[] pages, |Int, Int, Str|? progressFunc := null)
    {
        points := Point[,]

        i := 0
        n := pages.size

        pages.each |page, name|
        {
            try
            {
                points.addAll(doReadPointsFromPage(page))
            }
            catch(Err e)
            {
                 Logger.log.err("Failed to process page $page.name=$page.res",e)
            }
            progressFunc?.call(i, n, "Points")
            i++
        }

        return points
    }

    internal Point[] doReadPointsFromPage(Page page)
    {
        c := createWebClientForObix()
        try
        {
            c.reqUri = page.base + ("pxtohaystack?" + page.pxFile).toUri
            Logger.log.debug("processing page $page.name=$page.res")
            Logger.log.debug("trying to fetch $c.reqUri.toStr")
            c.writeReq
            c.readRes
            if (c.resCode != 200)
                throw IOErr("Cant' connect to $page.base! Response code: $c.resCode, phrase: $c.resPhrase")

            Logger.log.info("Processing page $page.name=$page.res")

            return parsePxPage(page, c.resBuf.in)
        }
        finally {
            c.close
        }
    }

/*
<?xml version="1.0" encoding="UTF-8"?>
<!-- Niagara Presentation XML -->
  <px version="1.0" media="workbench:WbPxMedia">
    <import>
      <module name="baja"/>
      <module name="bajaui"/>
      <module name="basAhuMaker"/>
      <module name="converters"/>
      <module name="gx"/>
      <module name="kitPx"/>
    </import>
    <content>
      <CanvasPane viewSize="1300.0,680.0">
        <AnalogImageBas layout="326.0,177.0,40.0,63.0" image="module://basAhuMaker/ahu/equipment/Damper/Damper_0_6.png" snapPoints="4,2,5;" markers="damper:damper:marker;outside:outside:marker;" mainSetting="0-100,0-9" imageLocation="module://basAhuMaker/ahu/equipment/Damper" imageName="Damper_0" calculate="true">
          <NullWidget/>
          <WsAnnotation name="wsAnnotation" value="10,7,16"/>
          <AnalogImageBinding ord="slot:../Damper"/>
        </AnalogImageBas>

        <BoundLabel layout="892.0,374.0,100.0,20.0">
          <BoundLabelBinding ord="slot:../Supply_Temp">
            <ObjectToString name="text" format="%out.value%"/>
          </BoundLabelBinding>
          <WsAnnotation name="wsAnnotation" value="2,2,8"/>
        </BoundLabel>
      </CanvasPane>
    </content>
  </px>
*/
    private Point[] parsePxPage(Page page, InStream respIn)
    {
        points := Point[,]
        parser := XParser(respIn)
        while (parser.next != null)
        {
            if (parser.nodeType == XNodeType.elemStart)
            {
                attrs := toAttrMap(parser.elem.attrs)
                if (attrs["markers"] != null)
                {
                    markers := attrs["markers"].split(';')
                                .findAll { it.trim != ""  && !it.startsWith("custom:") }
                                .map |x| {
                                    splitted := x.split(':')
                                    if (splitted.size == 3 && splitted[2] == "marker" && splitted[0] == splitted[1])
                                    {
                                        return splitted[0]
                                    }
                                    else
                                    {
                                        return ""
                                    }
                                }
                                .findAll { it != "" }

                    if (!markers.isEmpty)
                    {
                        bindingElem := parser.parseElem(false).elems.find |elem->Bool| { elem.name.contains("Binding") }

                        if (bindingElem != null)
                        {
                            ord := toAttrMap(bindingElem.attrs)["ord"]
                            if (ord != null)
                            {
                                obix := formatUri(page, ord)

//                                if (Int.random(0..100) < 20)
//                                {
//                                    obix = null
//                                }

                                id := formatId(obix)

                                point := Point()
                                {
                                    it.page = page
                                    it.name = parser.elem.name
                                    it.markers = markers
                                    it.obix = obix
                                    it.id = id
                                    it.ord = ord
                                }
                                Logger.log.debug("adding point: $point.toStr")
                                points.add(point)
                            }
                        }
                    }
                }
            }
        }
        return points
    }

    private static const Str stationOrSlot := "station:|slot:"
    private static const Str slot := "slot:"

    internal Uri? formatUri(Page page, Str ord)
    {
        // test for relative/absolute url
        if(ord.startsWith(stationOrSlot))
        {
            return page.base + ("obix/config" + ord[stationOrSlot.size..-1]).toUri
        }
        else if(ord.startsWith(slot))
        {
            return page.base + page.res + (ord[slot.size..-1]).toUri
        }
        else
        {
            Logger.log.err("unable to format uri for $page.name and ord: $ord")
            return null
        }
    }

    [Str:Page] fetchPages(Uri base, |Int, Int, Str|? progressFunc := null)
    {
        pages := fetchPageLinks(base)

        c := createWebClientForObix()
        try {
            // pipeline page requests
            i := 0
            n := pages.size

            result := [Str:Page][:]

            pages.each |page, name|
            {
                Logger.log.info("Fetching $page")

                c.reqUri = base + page.res
                c.writeReq
                c.readRes
                if (c.resCode != 200)
                    throw IOErr("Cant' connect to $base! Response code: $c.resCode, phrase: $c.resPhrase")

                map := parsePxUriAndTitle(c.resBuf.in)

                result[name] = Page(page) { it.pxFile = map["pxFile"]; it.title = map["title"] }

                Actor.sleep(Duration.fromStr("${sleep}ms"))

                progressFunc?.call(i, n, "Pages")
                i++
            }

            return result
        } finally {
            c.close
        }
    }


    private [Str:Page] fetchPageLinks(Uri base)
    {
        c := createWebClientForObix(base + `obix/config/Drivers/Config/obix/ObixQuery/query/`)
        c.reqMethod = "POST"
        c.reqVersion = Version("1.0")  // avoid using 1.1 to workaround unexpected "100: Continue" after POST
        c.reqHeaders["Content-Type"] = "application/xml; charset=utf-8"
        try {
            c.postStr("""<str val="bql:select * from basTemplateMavi:DeviceTemplateFolder"/>""")

            if (c.resCode != 200)
                throw IOErr("Cant' connect to $base! Response code: $c.resCode, phrase: $c.resPhrase")

            return parsePages(base, c.resBuf.in)

        } finally {
           c.close
        }
    }

/*
<obj display="Component" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://obix.org/ns/schema/1.0 /obix/xsd" xmlns="http://obix.org/ns/schema/1.0">
 <str name="res" val="obix/config/Drivers/NiagaraNetwork/Building1/points/AHU_1/Page/" href="res/" writable="true"/>
 <str name="res1" val="obix/config/Drivers/NiagaraNetwork/Building1/points/AHU_1/PageDVR/" href="res1/" writable="true"/>
</obj>
*/
    private [Str:Page] parsePages(Uri baseUri, InStream respIn)
    {
        pageLinks := [Str:Page][:]
        parser := XParser(respIn)
        while (parser.next != null)
        {
          if (parser.nodeType == XNodeType.elemStart)
          {
             if (parser.elem.name == "str")
             {
                attrs := toAttrMap(parser.elem.attrs)
                if (attrs["name"].trim != "" && attrs["val"].trim != "")
                    pageLinks.add(attrs["name"], Page()
                        {
                            base = baseUri
                            name = attrs["name"]
                            res = attrs["val"].toUri
                            disMacro = (getDisMacro) ? "\$siteRef \$navName" : null
                        }
                )
             }
          }
        }

        return pageLinks
    }

/*
<obj href="http://vm1.bassg.com:8080/obix/config/Drivers/NiagaraNetwork/Building1/points/AHU_1/Page/"
     is="/obix/def/basTemplateMavi:DeviceTemplateFolder /obix/def/baja:Folder"
     display="Device Template Folder"
     icon="/ord?module://basTemplateMavi/icons/nav/page16.png"
     xsi:schemaLocation="http://obix.org/ns/schema/1.0 /obix/xsd">
 <obj name="wb_graphic" href="wb_graphic/" is="/obix/def/baja:PxView" display="Px View" displayName="Wb_graphic" icon="/ord?module://icons/x16/views/view.png">
  <str name="icon" val="module://icons/x16/views/view.png" href="wb_graphic/icon/" displayName="Icon"writable="true"></str>
  <str name="requiredPermissions" val="r" href="wb_graphic/requiredPermissions/" displayName="Required Permissions" writable="true"></str>
  <str name="media" val="workbench:WbPxMedia" href="wb_graphic/media/" displayName="Media" writable="true"></str>
  <uri name="pxFile" val="file:^px/bassgUnits/wb/Building_1_Typical_AHU_100_Graphic.px" href="wb_graphic/pxFile/" displayName="Px File" writable="true"></uri>
 </obj>
 <ref name="Title" href="Title/" is="/obix/def/control:StringWritable /obix/def/control:StringPoint obix:Point" display="AHU-1 (Located@MR101) {ok} @ 10" icon="/ord?module://icons/x16/control/stringPoint.png"></ref>
</obj>
 */
    private [Str:Str?] parsePxUriAndTitle(InStream respIn)
    {
        Str? uri := null
        Str? title := null
        parser := XParser(respIn)
        while (parser.next != null)
        {
            if (parser.nodeType == XNodeType.elemStart && parser.elem.name == "obj" && parser.depth == 1)
            {
                attrs := toAttrMap(parser.elem.attrs)
                if (attrs["name"] == "wb_graphic" && attrs["is"] == "/obix/def/baja:PxView")
                {
                    uriElem := parser.parseElem(false).elems.find |elem->Bool|
                    {
                        elem.name == "uri" && toAttrMap(elem.attrs)["href"] == "wb_graphic/pxFile/"
                    }

                    uri = toAttrMap(uriElem.attrs)["val"]
                }
            }

            if (parser.nodeType == XNodeType.elemStart && parser.elem.name == "ref" && parser.depth == 1)
            {
                attrs := toAttrMap(parser.elem.attrs)
                if (attrs["name"] == "Title")
                {
                    title = attrs["display"]
                    idx := title.index("{")
                    if (idx != null)
                    {
                        title = title[0..<idx]
                    }
                }
            }
        }


        return ["pxFile": uri, "title": title]
    }

    [Str:Str] toAttrMap(XAttr[] attrs)
    {
       return attrs.reduce([:]) |[Str:Str] r, XAttr attr -> Map| { r.add(attr.name, attr.val) }
    }

    private Point[] enhanceWithObixHis2(Uri base, Uri station, Point[] points, |Int, Int, Str|? progressFunc := null)
    {
        obixMap := Str:Uri[:]

        c := createWebClientForObix()
        try {
            c.reqUri = base + `obix/histories/` + station;
            c.writeReq
            c.readRes

            if (c.resCode != 200)
                throw IOErr("Cant' connect to ${c.reqUri}! Response code: $c.resCode, phrase: $c.resPhrase")

            parseHistories(c.resBuf.in, base, station, obixMap)
        } finally {
            c.close
        }

        i := 0
        n := points.size

        result := Point[,]

        points.each |p|
        {
            obixHis := matchObixHis(p, obixMap)

            result.add(Point(p) { it.obixHis = obixHis} )

            progressFunc?.call(i, n, "Obix his")
            i++
        }

        return result
    }

    internal Uri? matchObixHis(Point p, Str:Uri obixMap)
    {
        Uri? uri := null
        if(p.id != null)
        {
            uri = obixMap[p.id]
            if(uri != null) return uri

            // try longer id
            uri = obixMap[formatId(p.obix, 3)]
            if(uri != null) return uri

            // in the last desperate attempt
            // we iterate through entire map
            uri = obixMap.eachWhile |v, k|
            {
                id := k.replace("\$2f", "\\").split('\\')
                segments := toSegments(p.obix)
                Logger.log.debug("id: $id")
                Logger.log.debug("segments: $segments")

                // we start matching from the end
                if(id.last.equals(segments.last))
                {
                    found := true
                    // reverse iterate through id segments and try to match it
                    segments = segments.reverse
                    id.eachrWhile|idSegment|
                    {
                        idx := segments.findIndex |Str s-> Bool|{ return s.equals(idSegment)}
                        // segment was not found
                        if(idx == null)
                        {
                            Logger.log.debug("segment $idSegment was not found")
                            found = false
                            return "not found"
                        }
                        else
                        {
                            Logger.log.debug("found segment $idSegment  at position: $idx")
                            segments = segments.removeRange(0..idx)
                            Logger.log.debug("new segments: $segments")
                        }
                        return null
                    }
                    Logger.log.debug("successfuly matched $p.obix to $v")
                    if(found) return v
                }
                // this element doesn't match
                return null
            }

        }
        if(uri == null) Logger.log.err("failed to match obixHis for $p.toStr")
        // everything failed
        return uri
    }

    **
    ** tries to format id to match obixHis
    **
    internal Str? formatId(Uri? uri, Int depth := 2)
    {
        if(uri == null) return null
        segments := toSegments(uri)
        result := segments[-depth..-1].join("""\$2f""")
        return result
    }


    internal Str[] toSegments(Uri uri)
    {
        segments := uri.path.dup
        // "points" isn't used in naming
        segments.remove("points")
        return segments
    }

    private Point[] enhanceWithUnitKind(Point[] points, |Int, Int, Str|? progressFunc := null)
    {
        obixMapKind := Uri:Str[:]
        obixMapUnit := Uri:Str[:]

        i := 0
        n := points.size

        result := Point[,]

        points.each |point|
        {
            if (point.obix != null)
            {
                if (!obixMapKind.containsKey(point.obix))
                {
                    c := createWebClientForObix()
                    try
                    {
                        c.reqUri = point.obix
                        c.writeReq
                        c.readRes
                        if (c.resCode != 200)
                        {
                            throw IOErr("Cant' connect to ${c.reqUri}! Response code: $c.resCode, phrase: $c.resPhrase")
                        }

                        parseKindUnit(c.resBuf.in, point, obixMapKind, obixMapUnit)

                        Actor.sleep(Duration.fromStr("${sleep}ms"))
                    }
                    finally
                    {
                        c.close
                    }

                }

                result.add(Point(point)
                {
                    it.kind = obixMapKind[point.obix]
                    it.unit = obixMapUnit[point.obix]
                })
            }
            else
            {
                result.add(point)
            }

            progressFunc?.call(i, n, "Enhance with unit kind")
            i++
        }

        return result
    }

    private Void parseHistories(InStream in, Uri base, Uri station, Str:Uri obixMap)
    {
        parser := XParser(in)

        while (parser.next != null)
        {
            if (parser.nodeType == XNodeType.elemStart &&
                parser.elem.name == "ref" &&
                parser.depth == 1)
            {
                attrs := toAttrMap(parser.elem.attrs)
                if (attrs["name"] != null && attrs["href"] != null)
                {
                    obixMap[attrs["name"]] = base + `obix/histories/` + station + attrs["href"].toUri
                }
            }
        }

    }

    private Void parseKindUnit(InStream in, Point point, Uri:Str obixMapKind, Uri:Str obixMapUnit)
    {
        parser := XParser(in)
        while (parser.next != null)
        {

            if (parser.nodeType == XNodeType.elemStart)
            {
                switch (parser.elem.name)
                {
                    case "real":
                        obixMapKind[point.obix] = "Number"
                    case "bool":
                        obixMapKind[point.obix] = "Bool"
                }

                if (parser.elem.attr("unit", false) != null)
                {
                    unit := Regex.fromStr("obix:units/").split(parser.elem.attr("unit", false).val).get(1)
                    obixMapUnit[point.obix] = unit
                }
                else
                {
                    obixMapUnit[point.obix] = ""
                }

                break
            }
        }
    }

    private Point[] getHaystackPoint(Point[] points, |Int, Int, Str|? progressFunc := null)
    {
        Logger.log.info("Connecting to NHaystack to get points: $haystackUri")

        client := HClient.open(haystackUri.toStr(), haystackUser, haystackPassword)

        b := HGridBuilder()
        b.addCol("filter");
        b.addRow([ HStr.make("point and axSlotPath") ]);
        req := b.toGrid();
        grid := client.call("read", req);

        result := Point[,]
        count := 0
        total := points.size

        points.each |point|
        {
            for (i:=0;i<grid.numRows();i++)
            {
                r := grid.row(i)

                axSlotPath := (r.get("axSlotPath", false) as HStr)?.val

                if (axSlotPath == point.axSlotPath)
                {
                    id := null
                    axType := null
                    kind := null
                    curStatus := null
                    precision := null
                    navName := null
                    curVal := null
                    enum := null
                    actions := null
                    unit := null
                    markers := Str[,]
                    disMacro := (getDisMacro) ? "\$equipRef \$navName" : null

                    for (j:=0; j<grid.numCols(); j++)
                    {
                        c := grid.col(j)

                        switch (c.name)
                        {
                            case "id":
                                id = (r.get(c, false) as HRef)?.val
                            case "axType":
                                axType = (r.get(c, false) as HStr)?.val
                            case "kind":
                                kind = (r.get(c, false) as HStr)?.val
                            case "curStatus":
                                curStatus = (r.get(c, false) as HStr)?.val
                            case "precision":
                                precision = (r.get(c, false) as HNum)?.val
                            case "navName":
                                navName = (r.get(c, false) as HStr)?.val
                            case "disMacro":
                                if (getDisMacro)
                                {
                                    disMacro = (r.get(c, false) as HStr)?.val
                                }
                            case "curVal":
                                switch ((r.get("kind", false) as HStr)?.val?.lower())
                                {
                                    case "number":
                                        curVal = (r.get(c, false) as HNum)?.val
                                    case "bool":
                                        curVal = (r.get(c, false) as HBool)?.val
                                    default:
                                        curVal = (r.get(c, false) as HStr)?.val
                                }
                            case "enum":
                                enum = (r.get(c, false) as HStr)?.val
                            case "actions":
                                actions = (r.get(c, false) as HStr)?.val
                            case "unit":
                                unit = (r.get(c, false) as HStr)?.val
                            default:
                                val := r.get(c, false)
                                if (val is HMarker) markers.add(c.name)
                        }
                    }

                    p := Point(point)
                    {
                        it.haystackId = id
                        it.axType = axType
                        it.kind = kind
                        it.curStatus = curStatus
                        it.precision = precision
                        it.navName = navName
                        it.disMacro = disMacro
                        it.curVal = curVal
                        it.enum = enum
                        it.actions = actions
                        it.unit = unit
                        it.markers = point.markers.union(markers)
                    }
                    result.add(p)

                    break
                }
            }

            count++
            progressFunc?.call(count, total, "Haystack tags for points")
        }

        return result
    }
}
