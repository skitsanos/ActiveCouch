/**
 * CouchDB ActionScript 3 Client
 * @author Skitsanos Inc, 2012
 * @version 1.3
 */
package com.skitsanos.api {
import com.adobe.serialization.json.JSON;
import com.adobe.utils.StringUtil;
import com.hurlant.util.Base64;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.HTTPStatusEvent;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.utils.ByteArray;


[Event(name="couchdb_error",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_version",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_active_tasks",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_all_dbs",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_db_exist",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_db_create",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_db_delete",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_replicate",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_all_docs",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_docs_count",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_docs_exist",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_docs_create",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_docs_update",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_docs_copy",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_docs_get",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_docs_delete",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_docs_bulk_delete",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_attachment_exist",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_attachment_inline_set",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_attachment_inline_get",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_attachment_inline_info",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_attachment_inline_delete",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_all_design_docs",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_design_create",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_view_temp_create",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_view_create",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_show_exist",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_show_get",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_show_set",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_show_delete",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_list_exist",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_list_get",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_list_set",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_list_delete",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_design_list_get",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_view_exist",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_view_get",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_view_set",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_view_delete",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_view_get_map",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_view_get_reduce",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_validate_exist",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_validate_get",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_validate_set",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_validate_delete",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_rewrite_get",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_rewrite_set",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_rewrite_delete",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_filter_exist",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_filter_get",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_filter_set",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_filter_delete",type="com.skitsanos.api.CouchDbEvent")]

public class CouchDb extends EventDispatcher {
    private static const INVALID_DATABASE_NAME:String = "Invalid Database name";
    private static const INVALID_DB_NAME_DOCID:String = "Invalid Database name / Doc / Design Id";
    private static const APPLICATION_JSON:String = "application/json";

    private var _host:String = "localhost";
    private var _port:int = 5984;

    private var _username:String;
    private var _password:String;
    private var _useSsl:Boolean = false;

    private var failureFunction:Function = function (failure:Object):void {
        throwError(CouchDbEvent.ERROR, failure.error, failure.data);
    };

    public function get host():String {
        return _host;
    }

    public function set host(value:String):void {
        if (StringUtils.beginsWith(value, "http://")) {
            host = StringUtil.replace(value, "http://", "");
        } else if (StringUtils.beginsWith(value, "https://")) {
            host = StringUtil.replace(value, "https://", "");
        }
    }

    public function get port():int {
        return _port;
    }

    public function set port(value:int):void {
        _port = value;
    }

    public function get username():String {
        return _username;
    }

    public function set username(value:String):void {
        _username = value;
    }

    public function get password():String {
        return _password;
    }

    public function set password(value:String):void {
        _password = value;
    }

    public function get useSsl():Boolean {
        return _useSsl;
    }

    public function set useSsl(value:Boolean):void {
        _useSsl = value;
    }

    public function CouchDb(host:String = "", port:int = 5984, userName:String = "", password:String = "") {
        if (StringUtils.beginsWith(host, "http://")) {
            host = StringUtil.replace(host, "http://", "");
        } else if (StringUtils.beginsWith(host, "https://")) {
            host = StringUtil.replace(host, "https://", "");
            useSsl = true;
        }
        if (StringUtils.contains(host, "cloudant.com")) {
            useSsl = true;
        }

        _host = host;
        _port = port;
        _username = userName;
        _password = password;
    }

    public function version():void {
        executeRequest(getUrl() + "/", function (event:Object):void {
            var serverResponse:ServerResponse = new ServerResponse();
            var decoder:Object = com.adobe.serialization.json.JSON.decode(event.result);
            serverResponse.contentType = event.serverResponse.contentType;
            serverResponse.data = decoder;
            serverResponse.execTime = event.serverResponse.execTime;
            dispatchEvent(new CouchDbEvent(CouchDbEvent.VERSION, event.result, event.serverResponse));
        }, failureFunction, 'GET');
    }

    public function getActiveTasks():void {
        executeRequest(getUrl() + "/_active_tasks", function (event:Object):void {
            var serverResponse:ServerResponse = new ServerResponse();
            serverResponse.contentType = event.serverResponse.contentType;
            serverResponse.data = com.adobe.serialization.json.JSON.decode(event.result);
            serverResponse.execTime = event.serverResponse.execTime;
            dispatchEvent(new CouchDbEvent(CouchDbEvent.ACTIVE_TASKS, event.result, serverResponse));

        }, failureFunction, 'GET');
    }

    public function getDatabases():void {
        executeRequest(getUrl() + "/_all_dbs", function (event:Object):void {
                    var serverResponse:ServerResponse = new ServerResponse();
                    serverResponse.contentType = event.serverResponse.contentType;
                    serverResponse.data = com.adobe.serialization.json.JSON.decode(event.result);
                    serverResponse.execTime = event.serverResponse.execTime;
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.ALL_DBS, event.result, serverResponse));
                }, failureFunction
                , 'GET');
    }

    public function databaseExists(db:String):void {
        if ((null != db) && (0 < db.length)) {
            executeRequest(getUrl() + "/" + db, function (event:Object):void {
                        var serverResponse:ServerResponse = new ServerResponse();
                        serverResponse.data = com.adobe.serialization.json.JSON.decode(event.result);
                        serverResponse.contentType = event.serverResponse.contentType;
                        serverResponse.execTime = event.serverResponse.execTime;
                        dispatchEvent(new CouchDbEvent(CouchDbEvent.DB_EXIST, event.result, serverResponse));
                    }, failureFunction
                    , 'GET');
        } else {
            throwError(CouchDbEvent.DB_EXIST, INVALID_DATABASE_NAME);
        }
    }

    public function createDatabase(db:String):void {
        if ((null != db) && (0 < db.length)) {
            executeRequest(getUrl() + "/" + db.toLowerCase(), function (event:Object):void {
                        var serverResponse:ServerResponse = new ServerResponse();
                        var decoder:Object = com.adobe.serialization.json.JSON.decode(event.result);
                        var created:Boolean = false;
                        if (null == decoder.error)
                            created = true;
                        serverResponse.contentType = event.serverResponse.contentType;
                        serverResponse.data = decoder;
                        serverResponse.execTime = event.serverResponse.execTime;
                        dispatchEvent(new CouchDbEvent(CouchDbEvent.DB_CREATE, event.result, serverResponse));
                        if (!created) {
                            throwError(CouchDbEvent.DB_CREATE, "Database creation failed");
                        }
                    }, failureFunction
                    , 'PUT');
        } else {
            throwError(CouchDbEvent.DB_CREATE, INVALID_DATABASE_NAME);
        }
    }

    public function deleteDatabase(db:String):void {
        if ((null != db) && (0 < db.length)) {
            executeRequest(getUrl() + "/" + db.toLowerCase(), function (event:Object):void {
                        var serverResponse:ServerResponse = new ServerResponse();
                        var decoder:Object = com.adobe.serialization.json.JSON.decode(event.result);
                        var created:Boolean = false;
                        if (null == decoder.error)
                            created = true;
                        serverResponse.contentType = event.serverResponse.contentType;
                        serverResponse.data = decoder;
                        serverResponse.execTime = event.serverResponse.execTime;
                        dispatchEvent(new CouchDbEvent(CouchDbEvent.DB_DELETE, event.result, serverResponse));
                        if (!created) {
                            throwError(CouchDbEvent.DB_DELETE, "Database deletion failed");
                        }
                    }, failureFunction
                    , 'DELETE');
        } else {
            throwError(CouchDbEvent.DB_DELETE, INVALID_DATABASE_NAME);
        }
    }

    public function replicate(content:*):void {
        var postData:String;
        if (!(content as String)) {
            postData = com.adobe.serialization.json.JSON.encode(content);
        } else {
            postData = content;
        }
        executeRequest(getUrl() + "/_replicate", function (event:Object):void {
                    var serverResponse:ServerResponse = new ServerResponse();
                    serverResponse.contentType = event.serverResponse.contentType;
                    serverResponse.data = com.adobe.serialization.json.JSON.decode(event.result);
                    serverResponse.execTime = event.serverResponse.execTime;
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.REPLICATE, event.result, serverResponse));
                }, failureFunction
                , 'POST', postData, APPLICATION_JSON);
    }

    public function getAllDocuments(db:String, docId:String = "", limit:int = 0):void {
        if ((null != db) && (0 < db.length)) {
            var url:String = getUrl() + "/" + db + "/_all_docs";

            if ((null != docId) && (0 < docId.length)) {
                url += "?startkey_docid=" + docId;
                if (0 < limit) {
                    url += "&limit=" + limit;
                }
            } else if (0 < limit) {
                url += "?limit=" + limit;
            }

            executeRequest(url, function (event:Object):void {
                        var serverResponse:ServerResponse = new ServerResponse();
                        serverResponse.contentType = event.serverResponse.contentType;
                        serverResponse.data = com.adobe.serialization.json.JSON.decode(event.result);
                        serverResponse.execTime = event.serverResponse.execTime;
                        dispatchEvent(new CouchDbEvent(CouchDbEvent.ALL_DOCS, event.result, serverResponse));
                    }, failureFunction
                    , 'GET');
        } else {
            throwError(CouchDbEvent.ALL_DOCS, INVALID_DATABASE_NAME);
        }
    }

    public function countDocuments(db:String):void {
        if ((null != db) && (0 < db.length)) {
            executeRequest(getUrl() + "/" + db, function (event:Object):void {
                        var serverResponse:ServerResponse = new ServerResponse();
                        serverResponse.contentType = event.serverResponse.contentType;
                        var decoder:Object = com.adobe.serialization.json.JSON.decode(event.result);
                        serverResponse.data = decoder.doc_count;
                        serverResponse.execTime = event.serverResponse.execTime;
                        dispatchEvent(new CouchDbEvent(CouchDbEvent.DOCUMENTS_COUNT, event.result, serverResponse));
                    }, failureFunction
                    , 'GET');
        } else {
            throwError(CouchDbEvent.DOCUMENTS_COUNT, INVALID_DATABASE_NAME);
        }
    }

    public function documentExists(db:String, docId:String):void {
        if ((null != db) && (0 < db.length)) {
            executeRequest(getUrl() + "/" + db + "/" + docId, function (event:Object):void {
                        var serverResponse:ServerResponse = new ServerResponse();
                        serverResponse.contentType = event.serverResponse.contentType;
                        serverResponse.data = com.adobe.serialization.json.JSON.decode(event.result);
                        serverResponse.execTime = event.serverResponse.execTime;
                        dispatchEvent(new CouchDbEvent(CouchDbEvent.DOCUMENT_EXISTS, event.result, serverResponse));
                    }, failureFunction
                    , 'GET');
        } else {
            throwError(CouchDbEvent.DOCUMENT_EXISTS, INVALID_DATABASE_NAME);
        }
    }

    public function createDocument(db:String, content:*):void {
        if ((null != db) && (0 < db.length)) {
            var postData:String;
            if (!(content as String)) {
                postData = com.adobe.serialization.json.JSON.encode(content);
            } else {
                postData = content;
            }
            executeRequest(getUrl() + "/" + db, function (event:Object):void {
                var serverResponse:ServerResponse = new ServerResponse();
                serverResponse.contentType = event.serverResponse.contentType;
                serverResponse.data = com.adobe.serialization.json.JSON.decode(event.result);
                serverResponse.execTime = event.serverResponse.execTime;
                dispatchEvent(new CouchDbEvent(CouchDbEvent.CREATE_DOCUMENT, event.result, serverResponse));
            }, failureFunction, 'POST', postData, APPLICATION_JSON);
        } else {
            throwError(CouchDbEvent.CREATE_DOCUMENT, INVALID_DATABASE_NAME);
        }
    }

    public function updateDocument(db:String, docId:String, content:*):void {
        var execTime:Number;
        var resultHandler:Function = function (event:Object):void {
            var serverResponse:ServerResponse = new ServerResponse();
            serverResponse.contentType = event.serverResponse.contentType;
            serverResponse.data = com.adobe.serialization.json.JSON.decode(event.result);
            serverResponse.execTime = event.serverResponse.execTime + execTime;
            dispatchEvent(new CouchDbEvent(CouchDbEvent.UPDATE_DOCUMENT, event.result, serverResponse));
        };
        if ((null != db) && (0 < db.length) && (null != docId) && (0 < docId.length)) {
            executeRequest(getUrl() + "/" + db + "/" + docId, function (event:Object):void {
                var postData:Object;
                if (content as String) {
                    postData = com.adobe.serialization.json.JSON.decode(content);
                } else {
                    postData = content;
                }
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);

                if (null == doc.error) {
                    if (null == postData._id) {
                        postData._id = docId;
                    }
                    if (null == postData._rev) {
                        postData._rev = doc._rev;
                    }
                    execTime = event.serverResponse.execTime;
                    executeRequest(getUrl() + "/" + db, resultHandler, function (failure:Object):void {
                            },
                            "POST", com.adobe.serialization.json.JSON.encode(postData), APPLICATION_JSON);
                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.UPDATE_DOCUMENT, event.result, event.serverResponse));
                }
            }, failureFunction, 'GET');

        } else {
            throwError(CouchDbEvent.UPDATE_DOCUMENT, INVALID_DB_NAME_DOCID);
        }
    }

    public function copyDocument(db:String, docId:String, newDocId:String):void {
        var execTime:Number;
        if ((null != db) && (0 < db.length) && (null != docId) && (0 < docId.length) && (null != newDocId) && (0 < newDocId.length)) {
            executeRequest(getUrl() + "/" + db + "/" + docId, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    doc._id = newDocId;
                    execTime = event.serverResponse.execTime;
                    executeRequest(getUrl() + "/" + db, resultHandler, failureFunction,
                            "POST", com.adobe.serialization.json.JSON.encode(doc), APPLICATION_JSON);
                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.UPDATE_DOCUMENT, event.result, event.serverResponse));
                }
            }, failureFunction, 'GET');
            var resultHandler:Function = function (event:Object):void {
                var serverResponse:ServerResponse = new ServerResponse();
                serverResponse.contentType = event.serverResponse.contentType;
                var decoder:Object = com.adobe.serialization.json.JSON.decode(event.result);
                serverResponse.data = decoder;
                serverResponse.execTime = event.serverResponse.execTime + execTime;
                dispatchEvent(new CouchDbEvent(CouchDbEvent.COPY_DOCUMENT, event.result, serverResponse));
            };
        } else {
            throwError(CouchDbEvent.COPY_DOCUMENT, INVALID_DB_NAME_DOCID);
        }
    }

    public function deleteDocument(db:String, docId:String):void {
        var execTime:Number;
        if ((null != db) && (0 < db.length) && (null != docId) && (0 < docId.length)) {
            executeRequest(getUrl() + "/" + db + "/" + docId, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    execTime = event.serverResponse.execTime;
                    executeRequest(getUrl() + "/" + db + "/" + docId + "?rev=" + doc._rev, resultHandler,
                            failureFunction, "DELETE");
                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.UPDATE_DOCUMENT, event.result, event.serverResponse));
                }
            }, failureFunction, 'GET');
            var resultHandler:Function = function (event:Object):void {
                var serverResponse:ServerResponse = new ServerResponse();
                serverResponse.contentType = event.serverResponse.contentType;
                serverResponse.data = com.adobe.serialization.json.JSON.decode(event.result);
                serverResponse.execTime = event.serverResponse.execTime + execTime;
                dispatchEvent(new CouchDbEvent(CouchDbEvent.DELETE_DOCUMENT, event.result, serverResponse));
            };
        } else {
            throwError(CouchDbEvent.DELETE_DOCUMENT, INVALID_DB_NAME_DOCID);
        }
    }

    public function deleteDocuments(db:String, bulkDeleteCommand:String = null):void {
        var list:Array = new Array();
        var execTime:Number;
        var resultHandler:Function = function (event:Object):void {
            var serverResponse:ServerResponse = new ServerResponse();
            serverResponse.contentType = event.serverResponse.contentType;
            var decoder:Object = com.adobe.serialization.json.JSON.decode(event.result);
            serverResponse.data = decoder;
            serverResponse.execTime = event.serverResponse.execTime + execTime;
            dispatchEvent(new CouchDbEvent(CouchDbEvent.BULK_DELETE_DOCUMENTS, event.result, serverResponse));
        };
        if ((null != db) && (0 < db.length)) {
            if (null == bulkDeleteCommand) {
                executeRequest(getUrl() + "/" + db + "/_all_docs", function (event:Object):void {
                            var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                            if (null == doc.error) {
                                var rows:Object = doc.rows;
                                for each (var row:Object in rows) {
                                    var d:Object = new Object();
                                    d._id = row.id;
                                    d._rev = row.value.rev;
                                    d._deleted = true;
                                    list.push(d);
                                }
                                var docs:Object = new Object();
                                docs.docs = list;
                                execTime = event.serverResponse.execTime;
                                executeRequest(getUrl() + "/" + db + "/_bulk_docs", resultHandler, failureFunction,
                                        "POST",
                                        com.adobe.serialization.json.JSON.encode(docs), APPLICATION_JSON
                                );
                            }
                            else {
                                dispatchEvent(new CouchDbEvent(CouchDbEvent.BULK_DELETE_DOCUMENTS, event.result, event.serverResponse));
                            }
                        }
                        , failureFunction, 'GET');
            } else {
                executeRequest(getUrl() + "/" + db + "/_bulk_docs", resultHandler, failureFunction
                        , "POST", bulkDeleteCommand, APPLICATION_JSON);
            }
        }

        else {
            throwError(CouchDbEvent.BULK_DELETE_DOCUMENTS, INVALID_DATABASE_NAME);
        }
    }

    public function getDocumentAsJson(db:String, docId:String, startKey:String = null, endKey:String = null):void {
        if ((null != db) && (0 < db.length)) {
            var url:String = getUrl() + "/" + db + "/" + docId;
            if ((null != startKey) && (0 < startKey.length)) {
                url += "?startkey=" + encodeURIComponent(startKey);
            }
            if ((null != endKey) && (0 < endKey.length)) {
                if ((null == startKey) || (0 == startKey.length)) {
                    url += "?";
                } else {
                    url += "&";
                }
                url += "endkey=" + encodeURIComponent(endKey);
            }

            executeRequest(url, function (event:Object):void {
                var serverResponse:ServerResponse = new ServerResponse();
                serverResponse.contentType = event.serverResponse.contentType;
                var decoder:Object = com.adobe.serialization.json.JSON.decode(event.result);
                serverResponse.data = decoder;
                serverResponse.execTime = event.serverResponse.execTime;
                dispatchEvent(new CouchDbEvent(CouchDbEvent.GET_DOCUMENT, event.result, serverResponse));
            }, failureFunction, 'GET');

        } else {
            throwError(CouchDbEvent.GET_DOCUMENT, INVALID_DATABASE_NAME);
        }
    }

    public function existsAttachment(db:String, docId:String, attachmentName:String):void {
        if ((null != db) && (0 < db.length) && (null != docId) && (0 < docId.length)) {
            executeRequest(getUrl() + "/" + db + "/" + docId, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    var serverResponse:ServerResponse = new ServerResponse();
                    serverResponse.contentType = event.serverResponse.contentType;
                    serverResponse.execTime = event.serverResponse.execTime;
                    if (null != doc._attachments) {
                        var attachments:Object = doc._attachments;
                        serverResponse.data = attachments.hasOwnProperty(attachmentName);
                    }
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.ATTACHMENT_EXIST, event.result, serverResponse));
                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.ATTACHMENT_EXIST, event.result, event.serverResponse));
                }
            }, failureFunction, 'GET');
        } else {
            throwError(CouchDbEvent.ATTACHMENT_EXIST, INVALID_DB_NAME_DOCID);
        }
    }

    public function setInlineAttachment(db:String, docId:String, attachmentName:String, attachmentContentType:String, attachmentData:ByteArray):void {
        var execTime:Number;
        var resultHandler:Function = function (event:Object):void {
            var serverResponse:ServerResponse = new ServerResponse();
            serverResponse.contentType = event.serverResponse.contentType;
            var decoder:Object = com.adobe.serialization.json.JSON.decode(event.result);
            serverResponse.data = decoder;
            serverResponse.execTime = event.serverResponse.execTime + execTime;
            dispatchEvent(new CouchDbEvent(CouchDbEvent.ATTACHMENT_INLINE_SET, event.result, serverResponse));
        };
        if ((null != db) && (0 < db.length) && (null != docId) && (0 < docId.length) &&
                (null != attachmentName) && (0 < attachmentName.length) &&
                (null != attachmentContentType) && (0 < attachmentContentType.length) &&
                (null != attachmentData)) {

            executeRequest(getUrl() + "/" + db + "/" + docId, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    execTime = event.serverResponse.execTime;
                    var attachment:Object = null;
                    if (doc.hasOwnProperty("_attachments")) {
                        var attachments:Object = doc._attachments;
                        if (attachments.hasOwnProperty(attachmentName)) {
                            attachment = attachments[attachmentName];
                        }
                    } else {
                        doc["_attachments"] = new Object();
                    }

                    if (null == attachment) {
                        attachment = new Object();
                    }

                    attachment.content_type = attachmentContentType;
                    attachment.data = Base64.encodeByteArray(attachmentData);
                    doc["_attachments"][attachmentName] = attachment;
                    customUpdateDocument(db, docId, doc, CouchDbEvent.ATTACHMENT_INLINE_SET, resultHandler, failureFunction);

                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.ATTACHMENT_INLINE_SET, event.result, event.serverResponse));
                }
            }, failureFunction, 'GET');
        } else {

            throwError(CouchDbEvent.ATTACHMENT_INLINE_SET, INVALID_DB_NAME_DOCID);
        }
    }

    public function getInlineAttachment(db:String, docId:String, attachmentName:String):void {
        if ((null != db) && (0 < db.length) && (null != docId) && (0 < docId.length)) {
            executeRequest(getUrl() + "/" + db + "/" + docId + "/" + encodeURIComponent(attachmentName), function (event:Object):void {
                var serverResponse:ServerResponse = new ServerResponse();
                try {
                    var decoder:Object = com.adobe.serialization.json.JSON.decode(event.result);
                    serverResponse.data = decoder;
                    serverResponse.contentType = "text";
                } catch(error:Error) {
                    // We got file data, hence decoding error
                    serverResponse.data = event.result;
                    serverResponse.contentType = "binary";
                }
                serverResponse.execTime = event.serverResponse.execTime;
                dispatchEvent(new CouchDbEvent(CouchDbEvent.ATTACHMENT_INLINE_GET, event.result, serverResponse));
            }, failureFunction, "GET", "", "text/plain", URLLoaderDataFormat.BINARY);
        } else {
            throwError(CouchDbEvent.ATTACHMENT_INLINE_GET, INVALID_DB_NAME_DOCID);
        }
    }

    public function getInlineAttachmentInfo(db:String, docId:String, attachmentName:String):void {
        if ((null != db) && (0 < db.length) && (null != docId) && (0 < docId.length) &&
                (null != attachmentName) && (0 < attachmentName.length)) {
            executeRequest(getUrl() + "/" + db + "/" + docId, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    var attachments:Object = doc._attachments;
                    var attachmentsInfo:Array = new Array();
                    var filter:Boolean = false;
                    if ((null != attachmentName) && (0 < attachmentName.length))
                        filter = true;
                    for each (var attachment:Object in attachments) {
                        var info:InlineAttachmentInfo = new InlineAttachmentInfo();
                        if (filter && StringUtils.contains(attachment.Name, attachmentName)) {
                            info.name = attachment.Name;
                            info.contentType = attachment.content_type;
                            info.length = attachment.length;
                            attachmentsInfo.push(info);
                        } else {
                            info.name = attachment.Name;
                            info.contentType = attachment.content_type;
                            info.length = attachment.length;
                            attachmentsInfo.push(info);
                        }
                    }
                    var serverResponse:ServerResponse = new ServerResponse();
                    serverResponse.contentType = event.serverResponse.contentType;
                    serverResponse.data = attachmentsInfo;
                    serverResponse.execTime = event.serverResponse.execTime;
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.ATTACHMENT_INLINE_INFO, event.result, serverResponse));
                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.ATTACHMENT_INLINE_INFO, event.result, event.serverResponse));
                }
            }, failureFunction, "GET");
        } else {
            throwError(CouchDbEvent.ATTACHMENT_INLINE_INFO, INVALID_DB_NAME_DOCID);
        }
    }

    public function deleteInlineAttachment(db:String, docId:String, attachmentName:String):void {
        var execTime:Number;
        var updateHandler:Function = function (event:Object):void {
            var serverResponse:ServerResponse = new ServerResponse();
            serverResponse.contentType = event.serverResponse.contentType;
            var decoder:Object = com.adobe.serialization.json.JSON.decode(event.result);
            serverResponse.data = decoder;
            serverResponse.execTime = event.serverResponse.execTime + execTime;
            dispatchEvent(new CouchDbEvent(CouchDbEvent.ATTACHMENT_INLINE_DELETE, event.result, serverResponse));
        };
        if ((null != db) && (0 < db.length) && (null != docId) && (0 < docId.length) &&
                (null != attachmentName) && (0 < attachmentName.length)) {
            executeRequest(getUrl() + "/" + db + "/" + docId, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    execTime = event.serverResponse.execTime;
                    if (null != doc._attachments) {
                        var result:Boolean = delete doc._attachments[attachmentName];
                        if (result) {
                            trace(doc._attachments[attachmentName]);
                            customUpdateDocument(db, docId, doc, CouchDbEvent.ATTACHMENT_INLINE_DELETE, updateHandler, failureFunction);
                        } else {
                            var serverResponse:ServerResponse = new ServerResponse();
                            var error:Object = new Object();
                            error.error = "The Attachment " + attachmentName + "does not exist";
                            serverResponse.data = error;
                            serverResponse.contentType = "text";
                            dispatchEvent(new CouchDbEvent(CouchDbEvent.ATTACHMENT_INLINE_DELETE, com.adobe.serialization.json.JSON.encode(error), serverResponse));
                            throw new Error(error.error);
                        }
                    }
                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.ATTACHMENT_INLINE_DELETE, event.result, event.serverResponse));
                }
            }, failureFunction, "GET");
        } else {
            throwError(CouchDbEvent.ATTACHMENT_INLINE_DELETE, INVALID_DB_NAME_DOCID);
        }
    }

    public function getAllDesignDocuments(db:String):void {
        if ((null != db) && (0 < db.length)) {
            var url:String = getUrl() + "/" + db + "/?startkey=" + encodeURIComponent("\"_design\"") + "&endkey=" +
                    encodeURIComponent("\"_design0\"");
            executeRequest(url, function (event:Object):void {
                var serverResponse:ServerResponse = new ServerResponse();
                serverResponse.contentType = event.serverResponse.contentType;
                serverResponse.data = com.adobe.serialization.json.JSON.decode(event.result);
                serverResponse.execTime = event.serverResponse.execTime;
                dispatchEvent(new CouchDbEvent(CouchDbEvent.ALL_DESIGN_DOCS, event.result, serverResponse));
            }, failureFunction, "GET");
        } else {
            throwError(CouchDbEvent.ALL_DESIGN_DOCS, INVALID_DATABASE_NAME);
        }
    }

    public function createDesignDocument(db:String, name:String, viewName:String, map:String):void {
        if ((null != db) && (0 < db.length)) {
            var content:Object = new Object();
            content._id = "_design/" + name;
            content.views = viewName;
            content.map = map;

            var postData:String = com.adobe.serialization.json.JSON.encode(content);
            executeRequest(getUrl() + "/" + db, function (event:Object):void {
                var serverResponse:ServerResponse = new ServerResponse();
                serverResponse.contentType = event.serverResponse.contentType;
                var decoder:Object = com.adobe.serialization.json.JSON.decode(event.result);
                serverResponse.data = decoder;
                serverResponse.execTime = event.serverResponse.execTime;
                dispatchEvent(new CouchDbEvent(CouchDbEvent.DESIGN_CREATE, event.result, serverResponse));
            }, failureFunction, "POST", postData, APPLICATION_JSON);
        } else {
            throwError(CouchDbEvent.DESIGN_CREATE, INVALID_DATABASE_NAME);
        }
    }

    public function createTemporaryView(db:String, map:String, reduce:String, startKey:String, endKey:String):void {
        if ((null != db) && (0 < db.length)) {
            var url:String = getUrl() + "/" + db + "/_temp_view";
            if ((null != startKey) && (0 < startKey.length)) {
                url += "?startkey=" + encodeURIComponent(startKey);
            }
            if ((null != endKey) && (0 < endKey.length)) {
                if ((null != startKey) && (0 < startKey.length)) {
                    url += "&";
                } else {
                    url += "?";
                }
                url += "endkey=" + encodeURIComponent(endKey);
            }
            var content:Object = new Object();
            content.map = map;
            if ((null != reduce) && (0 < reduce.length))
                content.reduce = reduce;

            var postData:String = com.adobe.serialization.json.JSON.encode(content);
            executeRequest(url, function (event:Object):void {
                var serverResponse:ServerResponse = new ServerResponse();
                serverResponse.contentType = event.serverResponse.contentType;
                var decoder:Object = com.adobe.serialization.json.JSON.decode(event.result);
                serverResponse.data = decoder;
                serverResponse.execTime = event.serverResponse.execTime;
                dispatchEvent(new CouchDbEvent(CouchDbEvent.VIEW_TEMP_CREATE, event.result, serverResponse));
            }, failureFunction, "POST", postData, APPLICATION_JSON);
        } else {
            throwError(CouchDbEvent.VIEW_TEMP_CREATE, INVALID_DATABASE_NAME);
        }
    }

    public function createView(db:String, viewName:String, map:String, reduce:String, startKey:String, endKey:String):void {
        if ((null != db) && (0 < db.length)) {
            var url:String = getUrl() + "/" + db + "/" + viewName;
            if ((null != startKey) && (0 < startKey.length)) {
                url += "?startkey=" + encodeURIComponent(startKey);
            }
            if ((null != endKey) && (0 < endKey.length)) {
                if ((null != startKey) && (0 < startKey.length)) {
                    url += "&";
                } else {
                    url += "?";
                }
                url += "endkey=" + encodeURIComponent(endKey);
            }
            var content:Object = new Object();
            content.map = map;
            if ((null != reduce) && (0 < reduce.length))
                content.reduce = reduce;

            var postData:String = com.adobe.serialization.json.JSON.encode(content);
            executeRequest(url, function (event:Object):void {
                var serverResponse:ServerResponse = new ServerResponse();
                serverResponse.contentType = event.serverResponse.contentType;
                var decoder:Object = com.adobe.serialization.json.JSON.decode(event.result);
                serverResponse.data = decoder;
                serverResponse.execTime = event.serverResponse.execTime;
                dispatchEvent(new CouchDbEvent(CouchDbEvent.VIEW_CREATE, event.result, serverResponse));
            }, failureFunction, "POST", postData, APPLICATION_JSON);
        } else {
            throwError(CouchDbEvent.VIEW_CREATE, INVALID_DATABASE_NAME);
        }
    }

    public function existsShowFunction(db:String, designDocument:String, showFunctionName:String):void {
        if ((null != db) && (0 < db.length) && (null != designDocument) && (0 < designDocument.length)) {
            executeRequest(getUrl() + "/" + db + "/" + designDocument, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    var serverResponse:ServerResponse = new ServerResponse();
                    serverResponse.contentType = event.serverResponse.contentType;
                    serverResponse.execTime = event.serverResponse.execTime;
                    if (null != doc.shows) {
                        var shows:Object = doc.shows;
                        serverResponse.data = shows.hasOwnProperty(showFunctionName);
                    }
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.SHOW_EXIST, event.result, serverResponse));
                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.SHOW_EXIST, event.result, event.serverResponse));
                }
            }, failureFunction, "GET");
        } else {
            throwError(CouchDbEvent.SHOW_EXIST, INVALID_DB_NAME_DOCID);
        }
    }

    public function setShowFunction(db:String, designDocument:String, showFunctionName:String, content:String):void {
        var execTime:Number;
        var updateHandler:Function = function (event:Object):void {
            var serverResponse:ServerResponse = new ServerResponse();
            serverResponse.contentType = event.serverResponse.contentType;
            var decoder:Object = com.adobe.serialization.json.JSON.decode(event.result);
            serverResponse.data = decoder;
            serverResponse.execTime = event.serverResponse.execTime + execTime;
            dispatchEvent(new CouchDbEvent(CouchDbEvent.SHOW_SET, event.result, serverResponse));
        };
        if ((null != db) && (0 < db.length) && (null != designDocument) && (0 < designDocument.length) &&
                (null != showFunctionName) && (0 < showFunctionName.length) && (null != content)) {
            executeRequest(getUrl() + "/" + db + "/" + designDocument, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    execTime = event.serverResponse.execTime;
                    var showFunction:Object = null;
                    if (doc.hasOwnProperty("shows")) {
                        if (doc.shows.hasOwnProperty(showFunctionName)) {
                            showFunction = doc["shows"][showFunctionName];
                        }
                    } else {
                        doc["shows"] = new Object();
                    }
                    if (null == showFunction) {
                        doc["shows"][showFunctionName] = new Object();
                    }
                    doc["shows"][showFunctionName] = content;
                    customUpdateDocument(db, designDocument, doc, CouchDbEvent.SHOW_SET, updateHandler, failureFunction);
                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.SHOW_SET, event.result, event.serverResponse));
                }
            }, failureFunction, "GET");
        } else {
            throwError(CouchDbEvent.SHOW_SET, INVALID_DB_NAME_DOCID);
        }
    }

    public function getShowFunction(db:String, designDocument:String, showFunctionName:String):void {
        if ((null != db) && (0 < db.length) && (null != designDocument) && (0 < designDocument.length)) {
            executeRequest(getUrl() + "/" + db + "/" + designDocument, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    var serverResponse:ServerResponse = new ServerResponse();
                    serverResponse.contentType = event.serverResponse.contentType;
                    serverResponse.execTime = event.serverResponse.execTime;
                    if (null != doc.shows) {
                        var shows:Object = doc.shows;
                        if (shows.hasOwnProperty(showFunctionName)) {
                            serverResponse.data = sanitizeOutput(shows[showFunctionName]);
                        } else {
                            serverResponse.data = event.result;
                        }
                    }
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.SHOW_GET, event.result, serverResponse));
                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.SHOW_GET, event.result, event.serverResponse));
                }
            }, failureFunction, "GET");
        } else {
            throwError(CouchDbEvent.SHOW_GET, INVALID_DB_NAME_DOCID);
        }
    }

    public function deleteShowFunction(db:String, designDocument:String, showFunctionName:String):void {
        var execTime:Number;
        var updateHandler:Function = function (event:Object):void {
            var serverResponse:ServerResponse = new ServerResponse();
            serverResponse.contentType = event.serverResponse.contentType;
            var decoder:Object = com.adobe.serialization.json.JSON.decode(event.result);
            serverResponse.data = decoder;
            serverResponse.execTime = event.serverResponse.execTime + execTime;
            dispatchEvent(new CouchDbEvent(CouchDbEvent.SHOW_DELETE, event.result, serverResponse));
        };
        if ((null != db) && (0 < db.length) && (null != designDocument) && (0 < designDocument.length) &&
                (null != showFunctionName) && (0 < showFunctionName.length)) {
            executeRequest(getUrl() + "/" + db + "/" + designDocument, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    execTime = event.serverResponse.execTime;
                    if (null != doc.shows) {
                        var result:Boolean = delete doc.shows[showFunctionName];
                        if (result) {
                            trace(doc.shows[showFunctionName]);
                            var length:Number = 0;
                            for (var key:String in doc.shows) {
                                length++;
                                if (length >= 1)
                                    break;
                            }
                            if (0 == length)
                                delete doc.shows;
                            customUpdateDocument(db, designDocument, doc, CouchDbEvent.SHOW_DELETE, updateHandler, failureFunction);
                        } else {
                            var serverResponse:ServerResponse = new ServerResponse();
                            var error:Object = new Object();
                            error.error = "The Show Function " + showFunctionName + "does not exist";
                            serverResponse.data = error;
                            serverResponse.contentType = "text";
                            dispatchEvent(new CouchDbEvent(CouchDbEvent.SHOW_DELETE, com.adobe.serialization.json.JSON.encode(error), serverResponse));
                            throw new Error(error.error);
                        }
                    }
                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.SHOW_DELETE, event.result, event.serverResponse));
                }
            }, failureFunction, "GET");

        } else {
            throwError(CouchDbEvent.SHOW_DELETE, INVALID_DB_NAME_DOCID);
        }
    }

    public function existsListFunction(db:String, designDocument:String, listFunctionName:String):void {
        if ((null != db) && (0 < db.length) && (null != designDocument) && (0 < designDocument.length)) {
            executeRequest(getUrl() + "/" + db + "/" + designDocument, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    var serverResponse:ServerResponse = new ServerResponse();
                    serverResponse.contentType = event.serverResponse.contentType;
                    serverResponse.execTime = event.serverResponse.execTime;
                    if (null != doc.lists) {
                        var lists:Object = doc.lists;
                        serverResponse.data = lists.hasOwnProperty(listFunctionName);
                    }
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.LIST_EXIST, event.result, serverResponse));
                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.LIST_EXIST, event.result, event.serverResponse));
                }
            }, failureFunction, "GET");
        } else {
            throwError(CouchDbEvent.LIST_EXIST, INVALID_DB_NAME_DOCID);
        }
    }

    public function setListFunction(db:String, designDocument:String, listFunctionName:String, content:String):void {
        var execTime:Number;
        var updateHandler:Function = function (event:Object):void {
            var serverResponse:ServerResponse = new ServerResponse();
            serverResponse.contentType = event.serverResponse.contentType;
            var decoder:Object = com.adobe.serialization.json.JSON.decode(event.result);
            serverResponse.data = decoder;
            serverResponse.execTime = event.serverResponse.execTime + execTime;
            dispatchEvent(new CouchDbEvent(CouchDbEvent.LIST_SET, event.result, serverResponse));
        };
        if ((null != db) && (0 < db.length) && (null != designDocument) && (0 < designDocument.length) &&
                (null != listFunctionName) && (0 < listFunctionName.length) && (null != content)) {
            executeRequest(getUrl() + "/" + db + "/" + designDocument, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    execTime = event.serverResponse.execTime;
                    var listFunction:Object = null;
                    if (doc.hasOwnProperty("lists")) {
                        if (doc["lists"].hasOwnProperty(listFunctionName)) {
                            listFunction = doc["lists"][listFunctionName];
                        }
                    } else {
                        doc["lists"] = new Object();
                    }
                    if (null == listFunction) {
                        doc["lists"][listFunctionName] = new Object();
                    }
                    doc["lists"][listFunctionName] = content;
                    customUpdateDocument(db, designDocument, doc, CouchDbEvent.LIST_SET, updateHandler, failureFunction);
                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.LIST_SET, event.result, event.serverResponse));
                }
            }, failureFunction, "GET");

        } else {
            throwError(CouchDbEvent.LIST_SET, INVALID_DB_NAME_DOCID);
        }
    }

    public function getListFunction(db:String, designDocument:String, listFunctionName:String):void {
        if ((null != db) && (0 < db.length) && (null != designDocument) && (0 < designDocument.length)) {
            executeRequest(getUrl() + "/" + db + "/" + designDocument, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    var serverResponse:ServerResponse = new ServerResponse();
                    serverResponse.contentType = event.serverResponse.contentType;
                    serverResponse.execTime = event.serverResponse.execTime;
                    if (null != doc.lists) {
                        var lists:Object = doc.lists;
                        if (lists.hasOwnProperty(listFunctionName)) {
                            serverResponse.data = sanitizeOutput(lists[listFunctionName]);
                        } else {
                            serverResponse.data = event.result;
                        }
                    }
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.LIST_GET, event.result, serverResponse));
                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.LIST_GET, event.result, event.serverResponse));
                }
            }, failureFunction, "GET");
        } else {
            throwError(CouchDbEvent.LIST_GET, INVALID_DB_NAME_DOCID);
        }
    }

    public function deleteListFunction(db:String, designDocument:String, listFunctionName:String):void {
        var execTime:Number;
        var updateHandler:Function = function (event:Object):void {
            var serverResponse:ServerResponse = new ServerResponse();
            serverResponse.contentType = event.serverResponse.contentType;
            var decoder:Object = com.adobe.serialization.json.JSON.decode(event.result);
            serverResponse.data = decoder;
            serverResponse.execTime = event.serverResponse.execTime + execTime;
            dispatchEvent(new CouchDbEvent(CouchDbEvent.LIST_DELETE, event.result, serverResponse));
        };
        if ((null != db) && (0 < db.length) && (null != designDocument) && (0 < designDocument.length) &&
                (null != listFunctionName) && (0 < listFunctionName.length)) {
            executeRequest(getUrl() + "/" + db + "/" + designDocument, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    execTime = event.serverResponse.execTime;
                    if (null != doc.lists) {
                        var result:Boolean = delete doc.lists[listFunctionName];
                        if (result) {
                            trace(doc.lists[listFunctionName]);
                            var length:Number = 0;
                            for (var key:String in doc.lists) {
                                length++;
                                if (length >= 1)
                                    break;
                            }
                            if (0 == length)
                                delete doc.lists;

                            customUpdateDocument(db, designDocument, doc, CouchDbEvent.LIST_DELETE, updateHandler, failureFunction);
                        } else {
                            var serverResponse:ServerResponse = new ServerResponse();
                            var error:Object = new Object();
                            error.error = "The List Function " + listFunctionName + "does not exist";
                            serverResponse.data = error;
                            serverResponse.contentType = "text";
                            dispatchEvent(new CouchDbEvent(CouchDbEvent.LIST_DELETE, com.adobe.serialization.json.JSON.encode(error), serverResponse));
                            throw new Error(error.error);
                        }
                    }
                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.LIST_DELETE, event.result, event.serverResponse));
                }
            }, failureFunction, "GET");
        } else {
            throwError(CouchDbEvent.LIST_DELETE, INVALID_DB_NAME_DOCID);
        }
    }

    public function getDesignList(db:String, name:String, listName:String, viewName:String = null, parameters:Array = null):void {
        if ((null != db) && (0 < db.length) && (null != name) && (0 < name.length) && (null != listName) && (0 < listName.length)) {
            var url:String = getUrl() + "/" + db + "/_design/" + name + "/_list/" + listName;
            var params:String = new String;
            if ((null != viewName) && (0 < viewName.length)) {
                url += "/" + viewName;
            }
            if ((null != parameters) && (0 < parameters.length)) {
                for each (var obj:Object in parameters) {
                    for (var key:String in obj) {
                        params += encodeURIComponent(key) + "=" + encodeURIComponent(obj[key]) + "&";
                    }
                }
                params = params.substring(0, params.length - 1);
                url += "?" + params;
            }
            executeRequest(url, function (event:Object):void {
                var serverResponse:ServerResponse = new ServerResponse();
                serverResponse.contentType = event.serverResponse.contentType;
                serverResponse.execTime = event.serverResponse.execTime;
                dispatchEvent(new CouchDbEvent(CouchDbEvent.GET_DESIGN_LIST, event.result, serverResponse));
            }, failureFunction, "GET");
        } else {
            throwError(CouchDbEvent.GET_DESIGN_LIST, INVALID_DB_NAME_DOCID);
        }
    }

    public function existsViewFunction(db:String, designDocument:String, viewFunctionName:String):void {
        if ((null != db) && (0 < db.length) && (null != designDocument) && (0 < designDocument.length)) {
            executeRequest(getUrl() + "/" + db + "/" + designDocument, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    var serverResponse:ServerResponse = new ServerResponse();
                    serverResponse.contentType = event.serverResponse.contentType;
                    serverResponse.execTime = event.serverResponse.execTime;
                    if (null != doc.views) {
                        var views:Object = doc.views;
                        serverResponse.data = views.hasOwnProperty(viewFunctionName);
                    }
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.VIEW_EXIST, event.result, serverResponse));
                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.VIEW_EXIST, event.result, event.serverResponse));
                }
            }, failureFunction, "GET");
        } else {
            throwError(CouchDbEvent.VIEW_EXIST, INVALID_DB_NAME_DOCID);
        }
    }

    public function setViewFunction(db:String, designDocument:String, viewFunctionName:String, mapContent:String, reduceContent:String):void {
        var execTime:Number;
        var updateHandler:Function = function (event:Object):void {
            var serverResponse:ServerResponse = new ServerResponse();
            serverResponse.contentType = event.serverResponse.contentType;
            serverResponse.data = com.adobe.serialization.json.JSON.decode(event.result);
            serverResponse.execTime = event.serverResponse.execTime + execTime;
            dispatchEvent(new CouchDbEvent(CouchDbEvent.VIEW_SET, event.result, serverResponse));
        };
        if ((null != db) && (0 < db.length) && (null != designDocument) && (0 < designDocument.length) &&
                (null != viewFunctionName) && (0 < viewFunctionName.length) && (null != mapContent)) {
            executeRequest(getUrl() + "/" + db + "/" + designDocument, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    execTime = event.serverResponse.execTime;

                    var viewFunction:Object = null;
                    if (doc.hasOwnProperty("views")) {
                        if (doc["views"].hasOwnProperty(viewFunctionName)) {
                            viewFunction = doc["views"][viewFunctionName];
                        }
                    } else {
                        doc["views"] = new Object();
                    }

                    if (null == viewFunction) {
                        doc["views"][viewFunctionName] = new Object();
                    }
                    doc["views"][viewFunctionName]["map"] = mapContent;
                    doc["views"][viewFunctionName]["reduce"] = reduceContent;
                    customUpdateDocument(db, designDocument, doc, CouchDbEvent.VIEW_SET, updateHandler, failureFunction);
                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.VIEW_SET, event.result, event.serverResponse));
                }
            }, failureFunction, "GET");

        } else {
            throwError(CouchDbEvent.VIEW_SET, INVALID_DB_NAME_DOCID);
        }
    }

    public function getMapFunction(db:String, designDocument:String, viewFunctionName:String):void {
        if ((null != db) && (0 < db.length) && (null != designDocument) && (0 < designDocument.length)) {
            executeRequest(getUrl() + "/" + db + "/" + designDocument, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    var serverResponse:ServerResponse = new ServerResponse();
                    serverResponse.contentType = event.serverResponse.contentType;
                    serverResponse.execTime = event.serverResponse.execTime;
                    if (null != doc.views) {
                        var views:Object = doc.views;
                        if (views.hasOwnProperty(viewFunctionName)) {
                            serverResponse.data = sanitizeOutput(views[viewFunctionName].map);
                        }
                    }
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.VIEW_GET_MAP, event.result, serverResponse));
                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.VIEW_GET_MAP, event.result, event.serverResponse));
                }
            }, failureFunction, "GET");
        } else {
            throwError(CouchDbEvent.VIEW_GET_MAP, INVALID_DB_NAME_DOCID);
        }
    }

    public function getReduceFunction(db:String, designDocument:String, viewFunctionName:String):void {
        if ((null != db) && (0 < db.length) && (null != designDocument) && (0 < designDocument.length)) {
            executeRequest(getUrl() + "/" + db + "/" + designDocument, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    var serverResponse:ServerResponse = new ServerResponse();
                    serverResponse.contentType = event.serverResponse.contentType;
                    serverResponse.execTime = event.serverResponse.execTime;
                    if (null != doc.views) {
                        var views:Object = doc.views;
                        if (views.hasOwnProperty(viewFunctionName)) {
                            serverResponse.data = sanitizeOutput(views[viewFunctionName].reduce);
                        }
                    }
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.VIEW_GET_REDUCE, event.result, serverResponse));
                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.VIEW_GET_REDUCE, event.result, event.serverResponse));
                }
            }, failureFunction, "GET");
        } else {
            throwError(CouchDbEvent.VIEW_GET_REDUCE, INVALID_DB_NAME_DOCID);
        }
    }

    public function getDesignViewAsJson(db:String, name:String, viewName:String):void {
        if ((null != db) && (0 < db.length) && (null != name) && (0 < name.length)) {
            executeRequest(getUrl() + "/" + db + "/_design/" + name + "/_view" + viewName, function (event:Object):void {
                var serverResponse:ServerResponse = new ServerResponse();
                serverResponse.data = event.result;
                serverResponse.contentType = event.serverResponse.contentType;
                serverResponse.execTime = event.serverResponse.execTime;
                dispatchEvent(new CouchDbEvent(CouchDbEvent.VIEW_GET, event.result, serverResponse));
            }, failureFunction, "GET");
        } else {
            throwError(CouchDbEvent.VIEW_GET, INVALID_DB_NAME_DOCID);
        }
    }

    public function deleteViewFunction(db:String, designDocument:String, viewFunctionName:String):void {
        var execTime:Number;
        var updateHandler:Function = function (event:Object):void {
            var serverResponse:ServerResponse = new ServerResponse();
            serverResponse.contentType = event.serverResponse.contentType;
            serverResponse.data = com.adobe.serialization.json.JSON.decode(event.result);
            serverResponse.execTime = event.serverResponse.execTime + execTime;
            dispatchEvent(new CouchDbEvent(CouchDbEvent.DELETE_VIEW, event.result, serverResponse));
        };
        if ((null != db) && (0 < db.length) && (null != designDocument) && (0 < designDocument.length) &&
                (null != viewFunctionName) && (0 < viewFunctionName.length)) {
            executeRequest(getUrl() + "/" + db + "/" + designDocument, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    execTime = event.serverResponse.execTime;
                    if (null != doc.views) {
                        var result:Boolean = delete doc.views[viewFunctionName];
                        if (result) {
                            trace(doc.views[viewFunctionName]);
                            var length:Number = 0;
                            for (var key:String in doc.views) {
                                length++;
                                if (length >= 1)
                                    break;
                            }
                            if (0 == length)
                                delete doc.views;

                            customUpdateDocument(db, designDocument, doc, CouchDbEvent.DELETE_VIEW, updateHandler, failureFunction);
                        } else {
                            var serverResponse:ServerResponse = new ServerResponse();
                            var error:Object = new Object();
                            error.error = "The View Function " + viewFunctionName + "does not exist";
                            serverResponse.data = error;
                            serverResponse.contentType = "text";
                            dispatchEvent(new CouchDbEvent(CouchDbEvent.DELETE_VIEW, com.adobe.serialization.json.JSON.encode(error), serverResponse));
                            throw new Error(error.error);
                        }
                    }
                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.DELETE_VIEW, event.result, event.serverResponse));
                }
            }, failureFunction, "GET");

        } else {
            throwError(CouchDbEvent.DELETE_VIEW, INVALID_DB_NAME_DOCID);
        }
    }

    public function existsValidateFunction(db:String, designDocument:String):void {
        if ((null != db) && (0 < db.length) && (null != designDocument) && (0 < designDocument.length)) {
            executeRequest(getUrl() + "/" + db + "/" + designDocument, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    var serverResponse:ServerResponse = new ServerResponse();
                    serverResponse.contentType = event.serverResponse.contentType;
                    serverResponse.execTime = event.serverResponse.execTime;
                    serverResponse.data = doc.hasOwnProperty("validate_doc_update");

                    dispatchEvent(new CouchDbEvent(CouchDbEvent.VALIDATE_EXIST, event.result, serverResponse));
                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.VALIDATE_EXIST, event.result, event.serverResponse));
                }
            }, failureFunction, "GET");
        } else {
            throwError(CouchDbEvent.VALIDATE_EXIST, INVALID_DB_NAME_DOCID);
        }
    }

    public function setValidateFunction(db:String, designDocument:String, content:String):void {
        var execTime:Number;
        var updateHandler:Function = function (event:Object):void {
            var serverResponse:ServerResponse = new ServerResponse();
            serverResponse.contentType = event.serverResponse.contentType;
            serverResponse.data = com.adobe.serialization.json.JSON.decode(event.result);
            serverResponse.execTime = event.serverResponse.execTime + execTime;
            dispatchEvent(new CouchDbEvent(CouchDbEvent.VALIDATE_SET, event.result, serverResponse));
        };
        if ((null != db) && (0 < db.length) && (null != designDocument) && (0 < designDocument.length) &&
                (null != content) && (0 < content.length)) {
            executeRequest(getUrl() + "/" + db + "/" + designDocument, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    execTime = event.serverResponse.execTime;

                    if (!doc.hasOwnProperty("validate_doc_update")) {
                        doc["validate_doc_update"] = new Object();
                    }

                    doc["validate_doc_update"] = content;
                    customUpdateDocument(db, designDocument, doc, CouchDbEvent.VALIDATE_SET, updateHandler, failureFunction);
                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.VALIDATE_SET, event.result, event.serverResponse));
                }
            }, failureFunction, "GET");

        } else {
            throwError(CouchDbEvent.VALIDATE_SET, INVALID_DB_NAME_DOCID);
        }
    }

    public function getValidateFunction(db:String, designDocument:String):void {
        if ((null != db) && (0 < db.length) && (null != designDocument) && (0 < designDocument.length)) {
            executeRequest(getUrl() + "/" + db + "/" + designDocument, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    var serverResponse:ServerResponse = new ServerResponse();
                    serverResponse.contentType = event.serverResponse.contentType;
                    serverResponse.execTime = event.serverResponse.execTime;
                    if (doc.hasOwnProperty("validate_doc_update")) {
                        serverResponse.data = sanitizeOutput(doc["validate_doc_update"]);
                    }
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.VALIDATE_GET, event.result, serverResponse));
                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.VALIDATE_GET, event.result, event.serverResponse));
                }
            }, failureFunction, "GET");
        } else {
            throwError(CouchDbEvent.VALIDATE_GET, INVALID_DB_NAME_DOCID);
        }
    }

    public function deleteValidateFunction(db:String, designDocument:String):void {
        var execTime:Number;
        var updateHandler:Function = function (event:Object):void {
            var serverResponse:ServerResponse = new ServerResponse();
            serverResponse.contentType = event.serverResponse.contentType;
            serverResponse.data = com.adobe.serialization.json.JSON.decode(event.result);
            serverResponse.execTime = event.serverResponse.execTime + execTime;
            dispatchEvent(new CouchDbEvent(CouchDbEvent.DELETE_VALIDATE, event.result, serverResponse));
        };
        if ((null != db) && (0 < db.length) && (null != designDocument) && (0 < designDocument.length)) {
            executeRequest(getUrl() + "/" + db + "/" + designDocument, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    execTime = event.serverResponse.execTime;
                    if (null != doc["validate_doc_update"]) {
                        var result:Boolean = delete doc["validate_doc_update"];
                        customUpdateDocument(db, designDocument, doc, CouchDbEvent.DELETE_VALIDATE, updateHandler, failureFunction);
                    } else {
                        var serverResponse:ServerResponse = new ServerResponse();
                        var error:Object = new Object();
                        error.error = "The Design Document " + designDocument + " does not contain a Validate Function!";
                        serverResponse.data = error;
                        serverResponse.contentType = "text";
                        dispatchEvent(new CouchDbEvent(CouchDbEvent.DELETE_VALIDATE, com.adobe.serialization.json.JSON.encode(error), serverResponse));
                        throw new Error(error.error);
                    }
                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.DELETE_VALIDATE, event.result, event.serverResponse));
                }
            }, failureFunction, "GET");
        } else {
            throwError(CouchDbEvent.DELETE_VALIDATE, INVALID_DB_NAME_DOCID);
        }
    }

    public function setRewriteFunction(db:String, designDocument:String, rewriteFunctionNumber:int, content:String):void {
        var execTime:Number;
        var updateHandler:Function = function (event:Object):void {
            var serverResponse:ServerResponse = new ServerResponse();
            serverResponse.contentType = event.serverResponse.contentType;
            serverResponse.data = com.adobe.serialization.json.JSON.decode(event.result);
            serverResponse.execTime = event.serverResponse.execTime + execTime;
            dispatchEvent(new CouchDbEvent(CouchDbEvent.REWRITE_SET, event.result, serverResponse));
        };
        if ((null != db) && (0 < db.length) && (null != designDocument) && (0 < designDocument.length)) {
            executeRequest(getUrl() + "/" + db + "/" + designDocument, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    execTime = event.serverResponse.execTime;
                    if (null != doc["rewrites"]) {
                        var rewritesArray:Array = doc["rewrites"];
                        if ((rewritesArray.length > rewriteFunctionNumber) && (null != doc["rewrites"][rewriteFunctionNumber])) {
                            rewritesArray[rewriteFunctionNumber] = content;
                        } else {
                            rewritesArray.push(content);
                        }
                        doc["rewrites"] = rewritesArray;
                    } else {
                        var array:Array = new Array();
                        array.push(content);
                        doc["rewrites"] = array;
                    }

                    customUpdateDocument(db, designDocument, doc, CouchDbEvent.REWRITE_SET, updateHandler, failureFunction);
                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.REWRITE_SET, event.result, event.serverResponse));
                }
            }, failureFunction, "GET");

        } else {
            throwError(CouchDbEvent.REWRITE_SET, INVALID_DB_NAME_DOCID);
        }
    }

    public function getRewriteFunction(db:String, designDocument:String, rewriteFunctionNumber:int):void {
        var eventName:String = CouchDbEvent.REWRITE_GET;
        if ((null != db) && (0 < db.length) && (null != designDocument) && (0 < designDocument.length)) {
            executeRequest(getUrl() + "/" + db + "/" + designDocument, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    var serverResponse:ServerResponse = new ServerResponse();
                    serverResponse.contentType = event.serverResponse.contentType;
                    serverResponse.execTime = event.serverResponse.execTime;
                    if ((doc.hasOwnProperty("rewrites")) && (null != doc["rewrites"][rewriteFunctionNumber])) {
                        serverResponse.data = sanitizeOutput(doc["rewrites"][rewriteFunctionNumber]);
                    } else {
                        serverResponse.data = "";
                    }
                    dispatchEvent(new CouchDbEvent(eventName, event.result, serverResponse));
                } else {
                    dispatchEvent(new CouchDbEvent(eventName, event.result, event.serverResponse));
                }
            }, failureFunction, "GET");
        } else {
            throwError(eventName, INVALID_DB_NAME_DOCID);
        }
    }

    public function deleteRewriteFunction(db:String, designDocument:String, rewriteFunctionNumber:int):void {
        var execTime:Number;
        var eventName:String = CouchDbEvent.DELETE_REWRITE;
        var updateHandler:Function = function (event:Object):void {
            var serverResponse:ServerResponse = new ServerResponse();
            serverResponse.contentType = event.serverResponse.contentType;
            serverResponse.data = com.adobe.serialization.json.JSON.decode(event.result);
            serverResponse.execTime = event.serverResponse.execTime + execTime;
            dispatchEvent(new CouchDbEvent(eventName, event.result, serverResponse));
        };
        if ((null != db) && (0 < db.length) && (null != designDocument) && (0 < designDocument.length)) {
            executeRequest(getUrl() + "/" + db + "/" + designDocument, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    execTime = event.serverResponse.execTime;
                    if (null != doc["rewrites"][rewriteFunctionNumber]) {
                        var result:Boolean = delete doc["rewrites"][rewriteFunctionNumber];

                        if (result) {
                            var length:Number = 0;
                            for (var key:String in doc.rewrites) {
                                length++;
                                if (length >= 1)
                                    break;
                            }
                            if (0 == length)
                                delete doc.rewrites;
                        }
                        customUpdateDocument(db, designDocument, doc, eventName, updateHandler, failureFunction);
                    } else {
                        var serverResponse:ServerResponse = new ServerResponse();
                        var error:Object = new Object();
                        if (null == doc["rewrites"])
                            error.error = "The Design Document " + designDocument + " does not contain any Rewrite Functions!";
                        else
                            error.error = "The Rewrite Function number " + rewriteFunctionNumber + " does not exist!";
                        serverResponse.data = error;
                        serverResponse.contentType = "text";
                        dispatchEvent(new CouchDbEvent(eventName, com.adobe.serialization.json.JSON.encode(error), serverResponse));
                        throw new Error(error.error);
                    }
                } else {
                    dispatchEvent(new CouchDbEvent(eventName, event.result, event.serverResponse));
                }
            }, failureFunction, "GET");
        } else {
            throwError(eventName, INVALID_DB_NAME_DOCID);
        }
    }

    public function existsFilterFunction(db:String, designDocument:String, filterFunctionName:String):void {
        var eventName:String = CouchDbEvent.FILTER_EXIST;
        if ((null != db) && (0 < db.length) && (null != designDocument) && (0 < designDocument.length)) {
            executeRequest(getUrl() + "/" + db + "/" + designDocument, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    var serverResponse:ServerResponse = new ServerResponse();
                    serverResponse.contentType = event.serverResponse.contentType;
                    serverResponse.execTime = event.serverResponse.execTime;
                    if (null != doc["filters"])
                        serverResponse.data = doc["filters"].hasOwnProperty(filterFunctionName);
                    else
                        serverResponse.data = false;

                    dispatchEvent(new CouchDbEvent(eventName, event.result, serverResponse));
                } else {
                    dispatchEvent(new CouchDbEvent(eventName, event.result, event.serverResponse));
                }
            }, failureFunction, "GET");
        } else {
            throwError(eventName, INVALID_DB_NAME_DOCID);
        }
    }

    public function setFilterFunction(db:String, designDocument:String, filterFunctionName:String, content:String):void {
        var execTime:Number;
        var eventName:String = CouchDbEvent.FILTER_SET;
        var updateHandler:Function = function (event:Object):void {
            var serverResponse:ServerResponse = new ServerResponse();
            serverResponse.contentType = event.serverResponse.contentType;
            serverResponse.data = com.adobe.serialization.json.JSON.decode(event.result);
            serverResponse.execTime = event.serverResponse.execTime + execTime;
            dispatchEvent(new CouchDbEvent(eventName, event.result, serverResponse));
        };
        if ((null != db) && (0 < db.length) && (null != designDocument) && (0 < designDocument.length)) {
            executeRequest(getUrl() + "/" + db + "/" + designDocument, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    execTime = event.serverResponse.execTime;
                    var filterFunction:Object = null;
                    if (doc.hasOwnProperty("filters")) {
                        if (doc["filters"].hasOwnProperty(filterFunctionName)) {
                            filterFunction = doc["filters"][filterFunctionName];
                        }
                    } else {
                        doc["filters"] = new Object();
                    }

                    if (null == filterFunction) {
                        doc["filters"][filterFunctionName] = new Object();
                    }

                    doc["filters"][filterFunctionName] = content;
                    customUpdateDocument(db, designDocument, doc, eventName, updateHandler, failureFunction);
                } else {
                    dispatchEvent(new CouchDbEvent(eventName, event.result, event.serverResponse));
                }
            }, failureFunction, "GET");

        } else {
            throwError(eventName, INVALID_DB_NAME_DOCID);
        }
    }

    public function getFilterFunction(db:String, designDocument:String, filterFunctionName:String):void {
        var eventName:String = CouchDbEvent.FILTER_GET;
        if ((null != db) && (0 < db.length) && (null != designDocument) && (0 < designDocument.length)) {
            executeRequest(getUrl() + "/" + db + "/" + designDocument, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    var serverResponse:ServerResponse = new ServerResponse();
                    serverResponse.contentType = event.serverResponse.contentType;
                    serverResponse.execTime = event.serverResponse.execTime;
                    if ((doc.hasOwnProperty("filters")) && (null != doc["filters"][filterFunctionName])) {
                        serverResponse.data = sanitizeOutput(doc["filters"][filterFunctionName]);
                    } else {
                        serverResponse.data = "";
                    }
                    dispatchEvent(new CouchDbEvent(eventName, event.result, serverResponse));
                } else {
                    dispatchEvent(new CouchDbEvent(eventName, event.result, event.serverResponse));
                }
            }, failureFunction, "GET");
        } else {
            throwError(eventName, INVALID_DB_NAME_DOCID);
        }
    }

    public function deleteFilterFunction(db:String, designDocument:String, filterFunctionName:String):void {
        var execTime:Number;
        var eventName:String = CouchDbEvent.DELETE_FILTER;
        var updateHandler:Function = function (event:Object):void {
            var serverResponse:ServerResponse = new ServerResponse();
            serverResponse.contentType = event.serverResponse.contentType;
            serverResponse.data = com.adobe.serialization.json.JSON.decode(event.result);
            serverResponse.execTime = event.serverResponse.execTime + execTime;
            dispatchEvent(new CouchDbEvent(eventName, event.result, serverResponse));
        };
        if ((null != db) && (0 < db.length) && (null != designDocument) && (0 < designDocument.length)) {
            executeRequest(getUrl() + "/" + db + "/" + designDocument, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    execTime = event.serverResponse.execTime;
                    if (null != doc["filters"][filterFunctionName]) {
                        var result:Boolean = delete doc["filters"][filterFunctionName];
                        if (result) {
                            var length:Number = 0;
                            for (var key:String in doc.filters) {
                                length++;
                                if (length >= 1)
                                    break;
                            }
                            if (0 == length)
                                delete doc.filters;
                        }

                        customUpdateDocument(db, designDocument, doc, eventName, updateHandler, failureFunction);
                    } else {
                        var serverResponse:ServerResponse = new ServerResponse();
                        var error:Object = new Object();
                        if (null == doc["rewrites"])
                            error.error = "The Design Document " + designDocument + " does not contain any Filter Functions!";
                        else
                            error.error = "The Filter Function " + filterFunctionName + " does not exist!";
                        serverResponse.data = error;
                        serverResponse.contentType = "text";
                        dispatchEvent(new CouchDbEvent(eventName, com.adobe.serialization.json.JSON.encode(error), serverResponse));
                        throw new Error(error.error);
                    }
                } else {
                    dispatchEvent(new CouchDbEvent(eventName, event.result, event.serverResponse));
                }
            }, failureFunction, "GET");
        } else {
            throwError(eventName, INVALID_DB_NAME_DOCID);
        }
    }

    private function configureURLListeners(dispatcher:IEventDispatcher):void {
        dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        dispatcher.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpStatusHandler);
        dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
        dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
    }

    private function securityErrorHandler(event:SecurityErrorEvent):void {
        trace("securityErrorHandler: " + event.toString());
        dispatchEvent(new CouchDbEvent(CouchDbEvent.ERROR, event, null));
        throw new Error(event.toString());
    }

    private function httpStatusHandler(event:HTTPStatusEvent):void {
        trace("httpStatusHandler: " + event.toString());
    }

    private function ioErrorHandler(event:IOErrorEvent):void {
        trace("ioErrorHandler: " + event.toString());
        dispatchEvent(new CouchDbEvent(CouchDbEvent.ERROR, event, null));
        throw new Error(event.toString());
    }

    /***
     * Executes HTTP request on CouchDB application server
     * @param url
     * @param resultHandler
     * @param failureHandler
     * @param method
     * @param postData
     * @param contentType
     */
    private function executeRequest(url:String, resultHandler:Function, failureHandler:Function, method:String, postData:String = "", contentType:String = "text/plain", dataFormat:String=URLLoaderDataFormat.TEXT):void {
        var loader:URLLoader = new URLLoader();
        configureURLListeners(loader);
        loader.dataFormat = dataFormat;

        var startTime:Number = new Date().getTime();

        loader.addEventListener(Event.COMPLETE, function (event:Event):void {
            var loader:URLLoader = URLLoader(event.target);
            var endTime:Number = new Date().getTime();
            var serverResponse:ServerResponse = new ServerResponse();
            serverResponse.execTime = endTime - startTime;
            trace("Exec time - " + serverResponse.execTime + "ms");
            trace("data - " + loader.data);
            trace("dataFormat - " + loader.dataFormat);

            serverResponse.contentType = loader.dataFormat;
            resultHandler({result:loader.data, serverResponse:serverResponse});
        });

        var request:URLRequest = new URLRequest(url);
        switch (method.toUpperCase()) {
            case "GET":
                request.method = URLRequestMethod.GET;
                break;
            case "POST":
                request.method = URLRequestMethod.POST;
                request.data = postData;
                break;
            case "PUT":
                request.method = URLRequestMethod.PUT;
                request.data = postData;
                break;
            case "DELETE":
                request.method = URLRequestMethod.DELETE;
                break;
        }
        request.contentType = contentType;
        var authHeader:URLRequestHeader = new URLRequestHeader("Authorization", "Basic " + Base64.encode(username + ":" + password));
        var referrerHeader:URLRequestHeader = new URLRequestHeader("Referer", getUrl());
        request.requestHeaders.push(authHeader);
        request.requestHeaders.push(referrerHeader);
        try {
            loader.load(request);
        } catch (error:Error) {
            trace("Error - " + error.message);

            failureHandler({data:loader.data, error:error});
        }

    }

    private function getUrl():String {
        var url:String = "http://";
        if (useSsl) {
            url = "https://";
        }

        if (StringUtils.contains(host, "cloudant.com") && useSsl) {
            url += host;
        } else {
            if ((!StringUtils.isEmpty(_username)) || (!StringUtils.isEmpty(_password))) {
              //  url += username + ":" + password + "@";
            }
            url += host + ":" + port;
        }

        trace("url - " + url);
        return url;
    }

    private function sanitizeOutput(content:String):String {
        var result:String = content;
        const NEWLINE:String = String.fromCharCode("\n".charCodeAt(0));

        result = StringUtils.trim(result);
        result = StringUtil.replace(result, "\\r\\n", "THIS_IS_NOT_A_RETURN_NEWLINE");
        result = StringUtil.replace(result, "\r\n", NEWLINE);

        result = StringUtil.replace(result, "\\n", "THIS_IS_NOT_A_NEWLINE");
        result = StringUtil.replace(result, "\n", NEWLINE);

        result = StringUtil.replace(result, "THIS_IS_NOT_A_RETURN_NEWLINE", NEWLINE);
        result = StringUtil.replace(result, "THIS_IS_NOT_A_NEWLINE", NEWLINE);

        result = StringUtil.replace(result, "\\t", "THIS_IS_NOT_A_TAB");
        result = StringUtil.replace(result, "\t", "\t");
        result = StringUtil.replace(result, "THIS_IS_NOT_A_TAB", "\t");

        result = StringUtil.replace(result, "\\\"", "\"");
        result = StringUtil.replace(result, "\\\\", "\\");

        return result;
    }

    private function throwError(event:String, error:String, data:* = null, contentType:String = "text"):void {
        var serverResponse:ServerResponse = new ServerResponse();
        var err:Object = {error:error, data:data};
        serverResponse.data = err;
        serverResponse.contentType = contentType;
        dispatchEvent(new CouchDbEvent(event, com.adobe.serialization.json.JSON.encode(err), serverResponse));
        throw new Error(error);
    }

    private function customUpdateDocument(db:String, docId:String, content:*, eventName:String, updateHandler:Function, failureHandler:Function):void {
        var execTime:Number;
        executeRequest(getUrl() + "/" + db + "/" + docId, function (event:Object):void {
            var postData:Object;
            if (content as String) {
                postData = com.adobe.serialization.json.JSON.decode(content);
            } else {
                postData = content;
            }
            var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);

            if (null == doc.error) {
                if (null == postData._id) {
                    postData._id = docId;
                }
                if (null == postData._rev) {
                    postData._rev = doc._rev;
                }
                execTime = event.serverResponse.execTime;
                executeRequest(getUrl() + "/" + db, updateHandler, failureHandler, "POST", com.adobe.serialization.json.JSON.encode(postData), APPLICATION_JSON);
            } else {
                dispatchEvent(new CouchDbEvent(eventName, event.result, event.serverResponse));
            }
        }, failureFunction, 'GET');
    }

}
}
