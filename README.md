# hosts2rpz

hosts2rpz.pl - script for converting a generic hosts file into an rpz zone db

**NOTE**: This repository is forked from @f3sty/hosts2rpz. The original script was intended to be used with <dns4me.net>. Credit and thanks goes out to @f3sty for writing the original script!

## PowerDNS Configuration

**STUB:** This chapter has yet to be written! Come back again later. I am still ironing out some issues with my install.

## Bind 9 Configuration

Define the response policy and rpz zone in the appropriate place (debian - /etc/bind/named.conf.local, RedHat - /etc/named.conf), e.g:


  response-policy { zone "rpz"; };

  zone "rpz" IN {
      type master;
      file "/var/lib/bind/rpz.db";
      allow-query { none; };
      allow-transfer { none; };
    };

and reload bind. 

Enabling rpz logging can help with troubleshooting. In the logging section of your bind config (debian: /etc/bind/named.conf.options, RedHat: /etc/named.conf) add the following:

     channel rpzlog  {
       file "/var/log/bind/rpz.log" versions 3 size 10m;
       print-time yes;
       print-category  yes;
       print-severity  yes;
       severity        debug;
     };
     category rpz { rpzlog; };


RPZ can be used within views, just make sure the zone and response-policy are both defined within the same view.

