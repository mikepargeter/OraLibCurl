/* 
 * Copyright (c) 2018, Mike Pargeter
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * * Neither the name of the copyright holder nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

CREATE OR REPLACE PACKAGE pg_oralibcurl
  AUTHID CURRENT_USER
IS

  -- Function to return the version of libcurl.
  
  FUNCTION fn_version
  RETURN VARCHAR2
  AS LANGUAGE C
  NAME "libcurl_version"
  LIBRARY OraLibCurl;
  
  -- Procedures to fetch a URL using libcurl, with versions to return the
  -- response as a CLOB or BLOB.

  PROCEDURE pr_fetch_clob
  ( p_request_url            IN     VARCHAR2
  , p_request_user_agent     IN     VARCHAR2
  , p_request_parameters     IN     VARCHAR2
  , p_request_content_type   IN     VARCHAR2
  , p_request_follow         IN     BOOLEAN
  , p_response_http_version     OUT VARCHAR2
  , p_response_status_code      OUT PLS_INTEGER
  , p_response_reason_phrase    OUT VARCHAR2
  , p_response_headers_clob  IN OUT CLOB
  , p_response_lob           IN OUT CLOB
  )
  AS LANGUAGE C
  NAME "libcurl_fetch"
  LIBRARY OraLibCurl
  WITH CONTEXT
  PARAMETERS
  ( CONTEXT
  , p_request_url            STRING
  , p_request_user_agent     STRING
  , p_request_user_agent     INDICATOR
  , p_request_parameters     STRING
  , p_request_parameters     INDICATOR
  , p_request_content_type   STRING
  , p_request_content_type   INDICATOR
  , p_request_follow         SHORT
  , p_request_follow         INDICATOR
  , p_response_http_version  STRING
  , p_response_status_code   LONG
  , p_response_reason_phrase STRING
  , p_response_headers_clob  OCILOBLOCATOR
  , p_response_headers_clob  INDICATOR
  , p_response_lob           OCILOBLOCATOR
  , p_response_lob           INDICATOR
  );

  PROCEDURE pr_fetch_blob
  ( p_request_url            IN     VARCHAR2
  , p_request_user_agent     IN     VARCHAR2
  , p_request_parameters     IN     VARCHAR2
  , p_request_content_type   IN     VARCHAR2
  , p_request_follow         IN     BOOLEAN
  , p_response_http_version     OUT VARCHAR2
  , p_response_status_code      OUT PLS_INTEGER
  , p_response_reason_phrase    OUT VARCHAR2
  , p_response_headers_clob  IN OUT CLOB
  , p_response_lob           IN OUT BLOB
  )
  AS LANGUAGE C
  NAME "libcurl_fetch"
  LIBRARY OraLibCurl
  WITH CONTEXT
  PARAMETERS
  ( CONTEXT
  , p_request_url            STRING
  , p_request_user_agent     STRING
  , p_request_user_agent     INDICATOR
  , p_request_parameters     STRING
  , p_request_parameters     INDICATOR
  , p_request_content_type   STRING
  , p_request_content_type   INDICATOR
  , p_request_follow         SHORT
  , p_request_follow         INDICATOR
  , p_response_http_version  STRING
  , p_response_status_code   LONG
  , p_response_reason_phrase STRING
  , p_response_headers_clob  OCILOBLOCATOR
  , p_response_headers_clob  INDICATOR
  , p_response_lob           OCILOBLOCATOR
  , p_response_lob           INDICATOR
  );

  -- Wrappers for the above procedures with simplified parameters.

  PROCEDURE pr_fetch_clob
  ( p_request_url            IN     VARCHAR2
  , p_request_user_agent     IN     VARCHAR2    DEFAULT NULL
  , p_request_parameters     IN     VARCHAR2    DEFAULT NULL
  , p_request_content_type   IN     VARCHAR2    DEFAULT NULL
  , p_request_follow         IN     BOOLEAN     DEFAULT FALSE
  , p_response_http_version     OUT VARCHAR2
  , p_response_status_code      OUT PLS_INTEGER
  , p_response_reason_phrase    OUT VARCHAR2
  , p_response_lob           IN OUT CLOB
  );

  PROCEDURE pr_fetch_blob
  ( p_request_url            IN     VARCHAR2
  , p_request_user_agent     IN     VARCHAR2    DEFAULT NULL
  , p_request_parameters     IN     VARCHAR2    DEFAULT NULL
  , p_request_content_type   IN     VARCHAR2    DEFAULT NULL
  , p_request_follow         IN     BOOLEAN     DEFAULT FALSE
  , p_response_http_version     OUT VARCHAR2
  , p_response_status_code      OUT PLS_INTEGER
  , p_response_reason_phrase    OUT VARCHAR2
  , p_response_lob           IN OUT BLOB
  );

END pg_oralibcurl;
/

show errors
