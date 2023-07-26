# hosts2rpz

hosts2rpz.pl - script for converting a generic hosts file into an rpz zone db

**NOTE**: This repository is forked from [@f3sty](https://github.com/f3sty/)/[hosts2rpz](https://github.com/f3sty/hosts2rpz). The original script was intended to be used with <https://dns4me.net>. Credit and thanks goes out to [@f3sty](https://github.com/f3sty/) for writing the original script!

## PowerDNS Configuration

~**STUB:** This chapter has yet to be written! Come back again later. I am still ironing out some issues with my install.~


```shell
# /etc/pdns/recursor.conf
lua-config-file=/etc/pdns/recursor.lua
```

```shell
# recursor.lua
rpzFile("/var/cache/pdns/facebook-extended.rpz",{defpol=Policy.NXDOMAIN,refresh=900})
rpzFile("/var/cache/pdns/dating-services-extended.rpz",{defpol=Policy.NXDOMAIN,refresh=900})
```

    PowerDNS Recursor 4.8.4 (C) 2001-2022 PowerDNS.COM

## Bind 9 Configuration

Define the response policy and rpz zone in the appropriate place (debian - /etc/bind/named.conf.local, RedHat - /etc/named.conf), e.g:

```shell
response-policy { zone "rpz"; };

zone "rpz" IN {
    type master;
    file "/var/lib/bind/rpz.db";
    allow-query { none; };
    allow-transfer { none; };
  };

and reload bind.

Enabling rpz logging can help with troubleshooting. In the logging section of your bind config (debian: /etc/bind/named.conf.options, RedHat: /etc/named.conf) add the following:

```shell
   channel rpzlog  {
     file "/var/log/bind/rpz.log" versions 3 size 10m;
     print-time yes;
     print-category  yes;
     print-severity  yes;
     severity        debug;
   };
   category rpz { rpzlog; };
```

RPZ can be used within views, just make sure the zone and response-policy are both defined within the same view.
