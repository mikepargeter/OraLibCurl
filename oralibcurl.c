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

#include <curl/curl.h>
#include <oci.h>
#include <string.h>

struct LobContext {
    OCIEnv        *envhp;
    OCISvcCtx     *svchp;
    OCIError      *errhp;
    OCILobLocator *headers;
    short          headers_ind;
    OCILobLocator *lob;
    short          lob_ind;
    char          *reason_phrase;
};

char *libcurl_version() {
    return curl_version();
}

static size_t header_callback(char *buffer, size_t size, size_t nitems, void *userdata) {
    size_t result = nitems * size;

    struct LobContext *lob_context = userdata;

    oraub8 byte_count = nitems * size;
    oraub8 char_count = 0;

    if (strlen(lob_context->reason_phrase) == 0) {
        int i;
        int j = 0;
        int s = 0;

        for (i = 0; i < byte_count; i++) {
            if (s == 2) {
                if (buffer[i] != '\n' && buffer[i] != '\r') {
                    lob_context->reason_phrase[j] = buffer[i];
                    lob_context->reason_phrase[++j] = '\0';
                }
            } else {
                if (buffer[i] == ' ') {
                    s++;
                }
            }
        }
    }

    if (lob_context->headers_ind == OCI_IND_NOTNULL && OCILobWriteAppend2(lob_context->svchp, lob_context->errhp, lob_context->headers, &byte_count, &char_count, buffer, (nitems * size), OCI_ONE_PIECE, NULL, NULL, 0, SQLCS_IMPLICIT)) {
        result = 0;
    }

    return result;

}

static size_t write_callback(char *buffer, size_t size, size_t nitems, void *userdata) {
    size_t result = nitems * size;

    struct LobContext *lob_context = userdata;

    oraub8 byte_count = nitems * size;
    oraub8 char_count = 0;

    if (lob_context->lob_ind == OCI_IND_NOTNULL && OCILobWriteAppend2(lob_context->svchp, lob_context->errhp, lob_context->lob, &byte_count, &char_count, buffer, (nitems * size), OCI_ONE_PIECE, NULL, NULL, 0, SQLCS_IMPLICIT)) {
        result = 0;
    }

    return result;

}

void libcurl_fetch (OCIExtProcContext *ctx, char *url, char *user_agent, short user_agent_ind, char *parameters, short parameters_ind, char *content_type, short content_type_ind, short follow, short follow_ind, char *http_version, long *response_code, char *reason_phrase, OCILobLocator **headers, short *headers_ind, OCILobLocator **lob, short *lob_ind) {
    strcpy(http_version, "");
    *response_code = -1L;
    strcpy(reason_phrase, "");

    struct LobContext lob_context;

    OraText errbuf[OCI_ERROR_MAXMSG_SIZE2] = "";
    sb4 errcode = 0;

    if (OCIExtProcGetEnv(ctx, &lob_context.envhp, &lob_context.svchp, &lob_context.errhp) != OCI_SUCCESS) {
        strcpy(reason_phrase, "Failed to get Oracle context");
        return; 
    }

    lob_context.headers = *headers;
    lob_context.headers_ind = *headers_ind;

    if (lob_context.headers_ind == OCI_IND_NOTNULL && OCILobOpen(lob_context.svchp, lob_context.errhp, lob_context.headers, OCI_LOB_READWRITE)) {
        OCIErrorGet(lob_context.errhp, 1, NULL, &errcode, errbuf, sizeof(errbuf), OCI_HTYPE_ERROR);
        sprintf(reason_phrase, "Failed to open headers LOB: %s", errbuf);
        return;
    }

    lob_context.lob = *lob;
    lob_context.lob_ind = *lob_ind;

    if (lob_context.lob_ind == OCI_IND_NOTNULL && OCILobOpen(lob_context.svchp, lob_context.errhp, lob_context.lob, OCI_LOB_READWRITE)) {
        OCIErrorGet(lob_context.errhp, 1, NULL, &errcode, errbuf, sizeof(errbuf), OCI_HTYPE_ERROR);
        sprintf(reason_phrase, "Failed to open response LOB: %s", errbuf);
        return;
    }

    lob_context.reason_phrase = reason_phrase;

    CURL *curl = curl_easy_init();

    if (curl) {
        CURLcode res;

        char errbuf[CURL_ERROR_SIZE];
        strcpy(errbuf, "");

        curl_easy_setopt(curl, CURLOPT_URL, url);
        curl_easy_setopt(curl, CURLOPT_ERRORBUFFER, errbuf);

        if (user_agent_ind == OCI_IND_NOTNULL) {
            curl_easy_setopt(curl, CURLOPT_USERAGENT, user_agent);
        }

        if (parameters_ind == OCI_IND_NOTNULL) {
            curl_easy_setopt(curl, CURLOPT_POSTFIELDS, parameters);
        }

        if (content_type_ind == OCI_IND_NOTNULL) {
            char ctbuf[1024];
            snprintf(ctbuf, sizeof ctbuf, "Content-Type: %s", content_type);

            struct curl_slist *hs = NULL;
            hs = curl_slist_append(hs, ctbuf);
            curl_easy_setopt(curl, CURLOPT_HTTPHEADER, hs);        
        }

        if (follow_ind == OCI_IND_NOTNULL && follow == TRUE) {
            curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
        }

        curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, header_callback);
        curl_easy_setopt(curl, CURLOPT_HEADERDATA, &lob_context);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_callback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &lob_context);

        res = curl_easy_perform(curl);

        if (res == CURLE_OK) {
            curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, response_code);

            long l_http_version;

            curl_easy_getinfo(curl, CURLINFO_HTTP_VERSION, &l_http_version);

            switch (l_http_version) {
                case CURL_HTTP_VERSION_1_0 :
                    strcpy(http_version, "HTTP/1.0");
                    break;
                case CURL_HTTP_VERSION_1_1 :
                    strcpy(http_version, "HTTP/1.1");
                    break;
                case CURL_HTTP_VERSION_2_0 :
                    strcpy(http_version, "HTTP/2.0");
                    break;
                default :
                    sprintf(http_version, "UNKNOWN: %ld", l_http_version);
            }

        } else {
            *response_code = res;
            strcpy(reason_phrase, (strlen(errbuf)) ? errbuf : curl_easy_strerror(res));
        }

        curl_easy_cleanup(curl);

    } else {
        strcpy(reason_phrase, "Failed to initialise CURL handle");
    }

    if (lob_context.headers_ind == OCI_IND_NOTNULL && OCILobClose(lob_context.svchp, lob_context.errhp, lob_context.headers)) {
        OCIErrorGet(lob_context.errhp, 1, NULL, &errcode, errbuf, sizeof(errbuf), OCI_HTYPE_ERROR);
        sprintf(reason_phrase, "Failed to close headers LOB: %s", errbuf);
        return;
    }

    if (lob_context.lob_ind == OCI_IND_NOTNULL && OCILobClose(lob_context.svchp, lob_context.errhp, lob_context.lob)) {
        OCIErrorGet(lob_context.errhp, 1, NULL, &errcode, errbuf, sizeof(errbuf), OCI_HTYPE_ERROR);
        sprintf(reason_phrase, "Failed to close response LOB: %s", errbuf);
        return;
    }

}

