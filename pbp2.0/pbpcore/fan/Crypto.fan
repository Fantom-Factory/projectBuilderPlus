/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using [java] java.nio::ByteBuffer
using [java] javax.crypto
using [java] javax.crypto.spec::SecretKeySpec
using [java] java.security
using [java] fanx.interop
using pbplogging

** 
** Encoding / decoding using java FFI, defaults to use AES
** Man does Java crypto has painful API's
**
class Crypto
{
  Str algo
  
  new make(Str algo:="AES")
  {
    this.algo = algo
  }
  
  ** Return password encrypted using given algo and secret key, base64 formatted
  Str encode(Str pass, Str secretKey)
  {
    k := Buf().print(secretKey).toDigest("SHA-256").toHex
    Key key := SecretKeySpec(toByteArray(k[0..15].toBuf), algo)
    Cipher c := Cipher.getInstance(algo)
    c.init(Cipher.ENCRYPT_MODE, key)
    encoded := c.doFinal(toByteArray(pass.toBuf))
    return toHex(fromByteArray(encoded))
  }
  
  ** Return password encrypted using given algo and secret key, base64 formatted
  Str decode(Str encoded, Str secretKey)
  {
    k := Buf().print(secretKey).toDigest("SHA-256").toHex
    Key key := SecretKeySpec(toByteArray(k[0..15].toBuf), algo)
    Cipher c := Cipher.getInstance(algo)
    c.init(Cipher.DECRYPT_MODE, key)
    pass := fromHex(encoded)
    decoded := c.doFinal(toByteArray(pass))
    return fromByteArray(decoded).readAllStr
  }
  
  internal ByteArray toByteArray(Buf buf)
  {
    bytes := ByteArray.make(buf.size)
    Interop.toJava(buf.in).read(bytes)
    return bytes
  }  
  
  ** Can't use toHex or toBase64 on Fantom NioBuf for some reason (not implemented)
  internal Str toHex(Buf buf)
  {
    Int? i
    Str s := ""
    while((i = buf.read) != null)
    {
      s += i.toHex(2)
    }  
    return s    
  }
  
  internal Buf fromHex(Str hex)
  {
    buf := Buf()
    for(i:=0; i!= hex.size / 2; i++)
    {
      val := Int.fromStr(hex[i*2 .. i*2+1], 16)
      buf.write(val)
    }
    return buf.flip        
  }
  
  internal Buf fromByteArray(ByteArray ba)
  {    
    bb := ByteBuffer.wrap(ba)
    return Interop.toFan(bb)
  } 
  
  
  Void main()
  {
    c:=Crypto()
    e := c.encode("15mil", "##betterthanNothing!")
    Logger.log.info("encoded: $e")
    d := c.decode(e, "##betterthanNothing!")
    Logger.log.info("decoded: $d")    
  }
}
