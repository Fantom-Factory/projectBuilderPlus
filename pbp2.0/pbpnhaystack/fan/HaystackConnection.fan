/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2012, BAS Services & Graphics, LLC.
// Licensed under the Academic Free License version 3.0
//
/////////////////////////////////////////////////////////////////////////////

using [java] org.projecthaystack.client::HClient
using pbpcore
using concurrent

/**
 * @author 
 * @version $Revision:$
 */
@Serializable
const class HaystackConnection
{
    private static const Str key := "123not#So&Secret%Password456".reverse

    @Transient
    private const AtomicRef hClientRef := AtomicRef(null)
    HClient? hClient() { (hClientRef.val as Unsafe)?.val }

    const Str? id
    const Str name
    const Uri uri
    const Str user
    @Transient
    const Str password
    private const Str encryptedPass

    new makeWith(Str name, Uri uri, Str user, Str password)
    {
        this.id = null
        this.name = name
        this.uri = uri
        this.user = user
        this.password = password
        this.encryptedPass = encryptPassword(password)
    }

    new makeCopy(HaystackConnection copy, |This| f)
    {
        this.id = copy.id
        this.name = copy.name
        this.uri = copy.uri
        this.user = copy.user
        this.password = copy.password
        this.hClientRef.getAndSet(Unsafe(copy.hClient))
        f(this)
        this.encryptedPass = encryptPassword(password)
    }

    new make(|This| f) /* for serialization */
    {
        f(this)
        this.password = decryptPassword(encryptedPass)
    }

    Bool connected()
    {
        return hClient != null
    }

    Void connect(Bool force := false, Bool checked := true)
    {
        if (connected)
        {
            if (force)
            {
                disconnect()
                // and continue
            }
            else
            {
                return
            }
        }

        try
        {
            hClientRef.getAndSet(Unsafe(HClient.open(uri.toStr, user, password)))
            hClient.about
        }
        catch (Err e)
        {
            hClientRef.getAndSet(null)
            if (checked)
            {
                throw e
            }
        }
    }

    Void reconnect(Bool checked := true)
    {
        connect(true, checked)
    }

    Void disconnect()
    {
        hClientRef.getAndSet(null)
    }

    private static Str encryptPassword(Str password)
    {
        return Crypto().encode(password, key)
    }

    private static Str decryptPassword(Str encrypted)
    {
        return Crypto().decode(encrypted, key)
    }

    override Str toStr()
    {
      return this.name
    }
}
