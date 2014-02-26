package com.skitsanos.aswing.events
{
	import com.skitsanos.aswing.ui.EmptyForm;

	import flash.events.Event;

	import org.aswing.event.AWEvent;

	public class EmptyFormEvent extends AWEvent
	{
		public static const LOAD:String = "onFormLoad";
		public static const MINIMIZE:String = "onFormMinimize";
		public static const RESTORE:String = "onFormRestore";
		public static const CLOSING:String = "onFormClosing";
		public static const RESIZE:String = "onFormResize";

		private var form:EmptyForm;

		public function EmptyFormEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, form:EmptyForm = null):void
		{
			super(type, bubbles, cancelable);
			this.form = form;
		}

		public override function clone():Event
		{
			return new EmptyFormEvent(type, bubbles, cancelable, form);
		}

	}
}