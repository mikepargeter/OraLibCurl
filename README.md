# OraLibCurl

An Oracle wrapper for libcurl.

## Installation

Allow Oracle to use external procedures, edit `$ORACLE_HOME/hs/admin/extproc.ora`:

```
SET EXTPROC_DLLS=ANY
```

Note this allows access to any library; for production systems you would be more restrictive!

Clone this repository to a location of your choice and build the library:

```
cd /home/oracle
git clone https://github.com/mikepargeter/OraLibCurl.git
cd OraLibCurl
make
```

In a suitable schema create the library:

```
CREATE OR REPLACE LIBRARY OraLibCurl AS '/home/oracle/OraLibCurl/oralibcurl.so'
/

@pg_oralibcurl.pks
@pg_oralibcurl.pkb
```

## Testing

Run the test script:

```
@test.sql
```

If all is well you should have output such as:

```
libcurl/7.61.0 OpenSSL/1.0.1e zlib/1.2.3.f-ora-v2 c-ares/1.14.0 libssh2/1.8.0 nghttp2/1.6.0
l_response_http_version:  HTTP/1.1
l_response_status_code:   200
l_response_reason_phrase: OK
l_response_headers_clob: Length = 744
HTTP/1.1 200 OK
Date: Tue, 31 Jul 2018 19:08:00 GMT
Expires: -1
Cache-Control: private, max-age=0
Content-Type: text/html; charset=ISO-8859-1
P3P: CP="This is not a P3P policy! See g.co/p3phelp for more info."
Server: gws
X-XSS-Protection: 1; mode=block
X-Frame-Options: SAMEORIGIN
Set-Cookie: 1P_JAR=2018-07-31-19; expires=Thu, 30-Aug-2018 19:08:00 GMT; path=/; domain=.google.com
Set-Cookie: NID=135=jIBbCAWZrQt-nkbvDfzocn_QUoLkP9UMhQxqw3ynMszuxoDM5yKitZRZrePhfnQ7CqOXi2H-bO1riZi413UgkGQT-S5m3YO08Ns8whEAhSmIvkKH75KffzFKoAMq1m6u; expires=Wed, 30-Jan-2019 19:08:00 GMT; path=/; domain=.google.com; HttpOnly
Alt-Svc: quic=":443"; ma=2592000; v="44,43,39,35"
Accept-Ranges: none
Vary: Accept-Encoding
Transfer-Encoding: chunked


l_response_lob: Length = 45824
```
