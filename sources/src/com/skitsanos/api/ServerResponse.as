package com.skitsanos.api {
import flash.utils.ByteArray;

public class ServerResponse {

    private var _contentType:String;
    private var _data:*;
    private var _execTime:Number;

    public function ServerResponse() {
    }

    public function get contentType():String {
        return _contentType;
    }

    public function set contentType(value:String):void {
        _contentType = value;
    }

    public function get data():* {
        return _data;
    }

    public function set data(value:*):void {
        _data = value;
    }

    public function get execTime():Number {
        return _execTime;
    }

    public function set execTime(value:Number):void {
        _execTime = value;
    }
}
}