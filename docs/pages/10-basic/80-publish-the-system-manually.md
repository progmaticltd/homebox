# Publishing your domain manually

## Export the zone public keys

On the target server, run the command `pdnsutil export-zone-dnskey` to export the zone keys.

The syntax is `pdnsutil export-zone-dnskey <domain> <key-id>`. For instance:

```plain
root@bochica:~# pdnsutil export-zone-dnskey sweethome.box 1
sweethome.box IN DNSKEY 257 3 13 0YhoHk1QTXntIJMmSpRQsu0xDJXKGWryc8/1maCET5hgBNpkj+wA1RJ/DB9hUgbWxJ4zhL4p/Vzsdfc3Xbt0wg==
```

```plain
root@bochica:~# pdnsutil export-zone-dnskey sweethome.box 2
sweethome.box IN DNSKEY 257 3 13 woa93fOM44Zi454jawfRnrsXGM9RLR/olf3Uif1S7uQ3WBqCo3jc4AtXfWt1O/ecTxKpx35SpDPw2VoGTR28Sw==
```

```plain
root@bochica:~# pdnsutil export-zone-dnskey sweethome.box 3
sweethome.box IN DNSKEY 256 3 13 qVdBeyVDeRNg8CB3bpXlxPwH1VxX1BaSw+WaUcXeK51Mbm7wIxScAJwx9fnkynJjCIfL6vChpoUcy4x5Z5IerA==
```

This should give you all the information needed, you can now get the values, and publish them on your DNS server.

## Verification

Once you have published your DNS keys, wait a few minutes to an hour, and use the following site to check if your keys
are published:

[DNS key checker on mxtoolbox](https://mxtoolbox.com/SuperTool.aspx?action=dnskey)

You should see something like this:

![Screenshot of successful](/img/dns-setup/dns-keys.png)
