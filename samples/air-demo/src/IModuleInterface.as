/**
 * Created with IntelliJ IDEA.
 * User: umashankar
 * Date: 05/04/12
 * Time: 23:35
 * To change this template use File | Settings | File Templates.
 */
package {
import flash.events.IEventDispatcher;

import spark.components.TextArea;

public interface IModuleInterface extends IEventDispatcher {
    function getModuleTitle():String;

    function setHost(host:String):void;

    function setPort(port:String):void;

    function setUser(user:String):void;

    function setPassword(password:String):void;

    function setResultOutput(result:TextArea):void;
}
}
