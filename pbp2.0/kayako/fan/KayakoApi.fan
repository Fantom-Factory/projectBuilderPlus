/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using [java] java.net
using [java] fanx.interop
using fwt
using pbpgui
using gfx
using concurrent
using web
using xml
using pbplogging

class KayakoApi : Logging {

  static Void createLicenseTicket(Str company, Str name, Str email, Str content)
  {
    Str domain  := Env.cur.index("bass.ticketing.url").first
    [Str:Str] setAttr := ["subject":"License request for $company","fullname":"$name","email":"$email","contents":"$content"]
    [Str:Str] hidAttr := ["departmentid":"7","ticketstatusid":"1","ticketpriorityid":"1","tickettypeid":"1","autouserid":"1"]
    [Str:Str] auth := getAuthSignature()
    future := KayakoTicketPOSTProcessor(ActorPool()).send([setAttr,hidAttr,auth])
    while(! future.isDone) {Actor.sleep(20ms)}
    }

  static private [Str:Str] getAuthSignature(){
    //TODO: THIS NEEDS TO BE GOTTEN SOMEWHERE ELSE
    Str secretKey := "ZjA5ZmEzYWUtM2VhOC1jY2Q0LWI5MmUtYmFkMmVlYjhiODc4OTFkNjdhMGEtNzY1MzMtNzAzZjJkZGI5Y2Ji" //TODO: Obscure this?
    Str salt := "itobgt701t5nat7oor9z" //Need to randomly generate a salt with low entropy
    //to be fixed

    Str apikey := "6e35ce33-ae49-a464-31b6-b64c911b3cec"
    Str usig := salt.toBuf.hmac("SHA-256", secretKey.toBuf).toBase64.toStr
    Str urlencodedsig := URLEncoder.encode(usig, "UTF-8");
    Env.cur.homeDir.createFile("dump.txt").writeObj(usig)
    return ["apikey":apikey,"salt":salt,"signature":usig]
  }

  static Window makeTicket(Window? parentWin, Str:Str props := [:]){

    Str resp := "cancel"
    File? attach := null
    subject := Text{text = props["subject"]?:""}
    fullname := Text{text = props["fullname"]?:""}
    email := Text{text = props["email"]?:""}
    contents := Text{multiLine = true; text = props["contents"]?:""}
    attachment := Text{enabled=false}
    getFile := Button{text=".."; onAction.add|e|{
        attach = FileDialog{filterExts=["*.pbp","*.png", "*.jpg"]; dir=Env.cur.homeDir+`projects/`;}.open(e.window)
        if(attach!=null){
          attachment.text = attach.name
        }
      }}
    Window ticketWin := PbpWindow(parentWin){
      title = "PBP Help Desk"
      size = Size(500,400)
      content = EdgePane{
        top = Label{text="Submit Help Ticket"; halign=Halign.center }
        center = GridPane{
          halignPane = Halign.center
          numCols = 2;
          Label{text="Full Name"},fullname,
          Label{text="Email"},email,
          Label{text="Ticket Subject"},subject,
          Label{text="Message Content"},contents,
          Label{text="Attachment"},GridPane{numCols=2; attachment,getFile},
        }
        bottom = GridPane{numCols=2; halignPane = Halign.right; Button{text="Submit"; onAction.add|e|{resp="submit";e.window.close}},Button{text="Cancel"; onAction.add|e|{resp="cancel";e.window.close}}}
      }

      onClose.add |e|
      {
        switch(resp)
        {
          case "submit":
            Str domain  := Env.cur.index("bass.ticketing.url").first
            subjectencode := subject.text
            nameencode := fullname.text
            emailencode := email.text
            contentencode := contents.text
            [Str:Str] setAttr := ["subject":subjectencode,"fullname":nameencode,"email":emailencode,"contents":contentencode]
            [Str:Str] hidAttr := ["departmentid":props["departmentid"]?:"12","ticketstatusid":"1","ticketpriorityid":"1","tickettypeid":"1","autouserid":"1"]
            [Str:Str] auth := getAuthSignature()

            KayakoTicketPOSTProcessor(ActorPool()).send([setAttr,hidAttr,auth])
            return
          case "cancel":
            return
          default:
            return
        }
      }
    }
    ticketWin.open
    return ticketWin
  }

}

const class KayakoTicketPOSTProcessor : Actor , Logging {
  new make(ActorPool pool, |Obj?->Obj?|? receive := null) : super(pool, receive) {}
  const Str command := Str <|/api/index.php?e=/Core/Test&|>
  override Obj? receive(Obj? msg)
  {
    msgList := msg as [Str:Str][]
    //Main.log.info("Starting Kayako Help Ticket Submission Sent")
    urlParameters := Uri.encodeQuery(msgList[1].addAll(msgList[2].addAll(msgList[3])))
    URL url := URL(Env.cur.index("bass.ticketing.url").first+"/api/index.php?e=/Tickets/Ticket")
    HttpURLConnection conn := url.openConnection;
    conn.setRequestMethod("POST")
    conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded")
    conn.setRequestProperty("charset", "utf-8")
    conn.setRequestProperty("Content-Length", "" + (urlParameters).size.toStr)
    conn.setDoInput(true)
    conn.setDoOutput(true)
    OutStream request := Interop.toFan(conn.getOutputStream())
    request.writeChars(urlParameters)
    request.flush
    request.close
    InStream response := Interop.toFan(conn.getInputStream())
    Env.cur.homeDir.createFile("xmldump").writeObj(response.readAllLines)
    if(conn.getResponseCode == 200){
      info("Kayako Help Ticket Done - Success")
      return true
    }
    else
    {
      err("Kayako Help Ticket Done - Failed - Reason: conn.getResponseMessage")
      return false
    }
  }

}

const class KayakoTicketAttPOSTProcessor : Actor{
  new make(ActorPool pool, |Obj?->Obj?|? receive := null) : super(pool, receive) {}
  const Str command := "/api/index.php?e=//Tickets/TicketAttachment"
  override Obj? receive(Obj? msg)
  {
    return "blah"
  }

}


