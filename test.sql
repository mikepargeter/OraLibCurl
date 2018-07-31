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
 
CREATE TABLE t_oralibcurl (c_clob CLOB)
/

DECLARE
  l_response_http_version  VARCHAR2(64);
  l_response_status_code   PLS_INTEGER;
  l_response_reason_phrase VARCHAR2(4096);
  l_response_headers_clob  CLOB;
  l_response_lob           CLOB;
BEGIN
  dbms_output.put_line(pg_oralibcurl.fn_version);

  dbms_lob.createtemporary(l_response_headers_clob, TRUE, dbms_lob.session);
  
  INSERT INTO t_oralibcurl VALUES (empty_clob()) RETURNING c_clob INTO l_response_lob;

  pg_oralibcurl.pr_fetch_clob
  ( p_request_url            => 'https://www.google.com/'
  , p_request_user_agent     => NULL
  , p_request_parameters     => NULL
  , p_request_content_type   => NULL
  , p_request_follow         => FALSE
  , p_response_http_version  => l_response_http_version
  , p_response_status_code   => l_response_status_code
  , p_response_reason_phrase => l_response_reason_phrase
  , p_response_headers_clob  => l_response_headers_clob
  , p_response_lob           => l_response_lob
  );

  dbms_output.put_line('l_response_http_version:  '||l_response_http_version);
  dbms_output.put_line('l_response_status_code:   '||l_response_status_code);
  dbms_output.put_line('l_response_reason_phrase: '||l_response_reason_phrase);
  dbms_output.put_line('l_response_headers_clob: Length = '||dbms_lob.getlength(l_response_headers_clob));
  dbms_output.put_line(l_response_headers_clob);
  dbms_output.put_line('l_response_lob: Length = '||dbms_lob.getlength(l_response_lob));

  dbms_lob.freetemporary(l_response_headers_clob);
  
  COMMIT;
END;
/

DROP TABLE t_oralibcurl PURGE
/