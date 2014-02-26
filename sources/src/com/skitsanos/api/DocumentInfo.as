/**
 * Created by IntelliJ IDEA.
 * User: uladha
 * Date: 3/22/12
 * Time: 6:50 PM
 * To change this template use File | Settings | File Templates.
 */
package com.skitsanos.api {
public class DocumentInfo {
    private var _id:String;
    private var _revision:String;

    public function DocumentInfo() {

    }

    public function get id():String {
        return _id;
    }

    public function set id(value:String):void {
        _id = value;
    }

    public function get revision():String {
        return _revision;
    }

    public function set revision(value:String):void {
        _revision = value;
    }
}
}
