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

[Event(name="couchdb_user_exists",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_user_add",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_user_get",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_user_delete",type="com.skitsanos.api.CouchDbEvent")]
[Event(name="couchdb_user_update",type="com.skitsanos.api.CouchDbEvent")]

public class CouchDbUser extends EventDispatcher{
    private static const INVALID_USER_NAME:String = "Invalid User name";
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

    public function CouchDbUser(host:String = "", port:int = 5984, userName:String = "", password:String = "") {
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

    public function isExists(userId:String):void {
        executeRequest(getUrl() + "/_users/org.couchdb.user:" + userId, function (event:Object):void {
            var serverResponse:ServerResponse = new ServerResponse();
            var decoder:Object = com.adobe.serialization.json.JSON.decode(event.result);
            serverResponse.contentType = event.serverResponse.contentType;
            serverResponse.data = decoder;
            serverResponse.execTime = event.serverResponse.execTime;
            dispatchEvent(new CouchDbEvent(CouchDbEvent.USER_EXISTS, event.result, event.serverResponse));
        }, failureFunction, 'GET');
    }

    public function getUser(userId:String):void {
        executeRequest(getUrl() + "/_users/org.couchdb.user:" + userId, function (event:Object):void {
            var serverResponse:ServerResponse = new ServerResponse();
            var decoder:Object = com.adobe.serialization.json.JSON.decode(event.result);
            serverResponse.contentType = event.serverResponse.contentType;
            serverResponse.data = decoder;
            serverResponse.execTime = event.serverResponse.execTime;
            dispatchEvent(new CouchDbEvent(CouchDbEvent.USER_GET, event.result, event.serverResponse));
        }, failureFunction, 'GET');
    }

    public function addUser(userId:String, password:String, roles:Array):void {
        var postData:String = new String();
        var user:Object = new Object();
        user._id = "org.couchdb.user:"+userId;
        user.name = userId;
        user.roles = roles;
        user.type = "user";
        user.password = password;

        postData = com.adobe.serialization.json.JSON.encode(user);

        executeRequest(getUrl() + "/_users/" + user._id, function (event:Object):void {
            var serverResponse:ServerResponse = new ServerResponse();
            var decoder:Object = com.adobe.serialization.json.JSON.decode(event.result);
            serverResponse.contentType = event.serverResponse.contentType;
            serverResponse.data = decoder;
            serverResponse.execTime = event.serverResponse.execTime;
            dispatchEvent(new CouchDbEvent(CouchDbEvent.USER_ADD, event.result, event.serverResponse));
        }, failureFunction, 'PUT', postData,  APPLICATION_JSON);
    }

    public function deleteUser(userId:String):void {
        var execTime:Number;
        if ((null != userId) && (0 < userId.length)) {
            executeRequest(getUrl() + "/_users/org.couchdb.user:" + userId, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if (null == doc.error) {
                    execTime = event.serverResponse.execTime;
                    executeRequest(getUrl() + "/_users/org.couchdb.user:"+ userId + "?rev=" + doc._rev, resultHandler,
                            failureFunction, "DELETE");
                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.USER_DELETE, event.result, event.serverResponse));
                }
            }, failureFunction, 'GET');
            var resultHandler:Function = function (event:Object):void {
                var serverResponse:ServerResponse = new ServerResponse();
                serverResponse.contentType = event.serverResponse.contentType;
                serverResponse.data = com.adobe.serialization.json.JSON.decode(event.result);
                serverResponse.execTime = event.serverResponse.execTime + execTime;
                dispatchEvent(new CouchDbEvent(CouchDbEvent.USER_DELETE, event.result, serverResponse));
            };
        } else {
            throwError(CouchDbEvent.USER_DELETE, INVALID_USER_NAME);
        }
    }

    public function updateUser(userId:String, password:String, roles:Array):void {
        var execTime:Number;
        var resultHandler:Function = function (event:Object):void {
            var serverResponse:ServerResponse = new ServerResponse();
            serverResponse.contentType = event.serverResponse.contentType;
            serverResponse.data = com.adobe.serialization.json.JSON.decode(event.result);
            serverResponse.execTime = event.serverResponse.execTime + execTime;
            dispatchEvent(new CouchDbEvent(CouchDbEvent.USER_UPDATE, event.result, serverResponse));
        };
        if ((null != userId) && (0 < userId.length)) {
            executeRequest(getUrl() + "/_users/org.couchdb.user:" + userId, function (event:Object):void {
                var doc:Object = com.adobe.serialization.json.JSON.decode(event.result);
                if ((null == doc.error) && (StringUtils.contains(doc.name, userId))) {
                    doc.roles = roles;
                    doc.password = password;

                    execTime = event.serverResponse.execTime;
                    executeRequest(getUrl() + "/_users/org.couchdb.user:" + userId, resultHandler, function (failure:Object):void {
                            },
                            "PUT", com.adobe.serialization.json.JSON.encode(doc), APPLICATION_JSON);
                } else {
                    dispatchEvent(new CouchDbEvent(CouchDbEvent.USER_UPDATE, event.result, event.serverResponse));
                }
            }, failureFunction, 'GET');

        } else {
            throwError(CouchDbEvent.USER_UPDATE, INVALID_USER_NAME);
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
               // url += username + ":" + password + "@";
            }
            url += host + ":" + port;
        }

        trace("url - " + url);
        return url;
    }


    private function throwError(event:String, error:String, data:* = null, contentType:String = "text"):void {
        var serverResponse:ServerResponse = new ServerResponse();
        var err:Object = {error:error, data:data};
        serverResponse.data = err;
        serverResponse.contentType = contentType;
        dispatchEvent(new CouchDbEvent(event, com.adobe.serialization.json.JSON.encode(err), serverResponse));
        throw new Error(error);
    }
}
}
