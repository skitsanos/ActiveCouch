/**
* Default Form Instance
* @author Evgenios Skitsanos
* @version 1.2.12292007
*/

package com.skitsanos.aswing.ui
{
	import caurina.transitions.Tweener;

	import com.skitsanos.aswing.events.EmptyFormEvent;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	
	import org.aswing.AsWingManager;
	import org.aswing.AsWingUtils;
	import org.aswing.Component;
	import org.aswing.JFrame;
	import org.aswing.event.FrameEvent;
	import org.aswing.event.ResizedEvent;
	import org.aswing.geom.IntRectangle;

	public class EmptyForm extends EventDispatcher
	{
		private var oc:Object;
		private var frame:JFrame;
		
		private var bounds:IntRectangle;
		
		public var title:String = "[Untitled Form]";
		public var child:Component = null;
		
		public var x:Number = 0;
		public var y:Number = 0;
		public var width:Number = 400;
		public var height:Number = 300;
		
		public var closable:Boolean = true;
		public var resizable:Boolean = true;
		public var disposable:Boolean = true;
		
		public function EmptyForm(container:Object):void 
		{
			oc = container;
			
			x = AsWingUtils.getScreenCenterPosition().x - this.width / 2;
			y = AsWingUtils.getScreenCenterPosition().y - this.height / 2;	
			
			bounds = new IntRectangle(0, 0, this.width, this.height);
			
			frame = new JFrame(oc, title, false);	//[true]pop-up as modal window
			frame.setLocationXY(x, y);
			
			//var bg:GradientBackground = new GradientBackground(GradientBrush.LINEAR, [0xF0F8FF, 0xffffff], [0.5, 1], [0, 255], AsWingConstants.SOUTH);
			//frame.setBackgroundDecorator(bg);
			
			frame.setClosable(closable);	//not allow to close the form
			frame.setResizable(resizable);	//not alllow to resize the form
			//frame.getContentPane().setLayout(new EmptyLayout());
			//frame.getContentPane().setBounds(bounds);
			
			frame.setSizeWH(width, height);			
			
			frame.addEventListener(Event.ADDED_TO_STAGE, renderFormContents);
			//frame.addEventListener(ResizedEvent.RESIZED, frame_resize);						
			frame.addEventListener(FrameEvent.FRAME_CLOSING, __closing);
			
			//var _self:EmptyForm = this;
			/*
			frame.addEventListener(FrameEvent.FRAME_ICONIFIED, function(e:FrameEvent):void{
				_self.dispatchEvent(new EmptyFormEvent(EmptyFormEvent.RESIZE, false, false, _self));
			});
			frame.addEventListener(FrameEvent.FRAME_MAXIMIZED, function(e:FrameEvent):void{
				_self.dispatchEvent(new EmptyFormEvent(EmptyFormEvent.RESIZE, false, false, _self));
			});
			frame.addEventListener(FrameEvent.FRAME_RESTORED, function(e:FrameEvent):void{
				_self.dispatchEvent(new EmptyFormEvent(EmptyFormEvent.RESIZE, false, false, _self));
			});*/		
			frame.addEventListener(FocusEvent.FOCUS_IN, __focusIn);
			frame.addEventListener(FocusEvent.FOCUS_OUT,__focusOut);
		}
		/**
		 * Shows form on the screen
		 */
		public function show():void 
		{	
			frame.setTitle(title);
			frame.setSizeWH(this.width, this.height);

			frame.show();

			//AsWingManager.getRoot()["desktop"].executeCommand(Desktop.FORM_SHOW, this);
		}
		
		public function hide():void
		{
			frame.hide();
			//AsWingManager.getRoot()["desktop"].executeCommand(Desktop.FORM_HIDE, this);
		}
		
		/**
		 * Active Window
		 */ 
		private function __focusIn(e:FocusEvent):void
		{
			frame.alpha = 1;			
			//AsWingManager.getRoot()["desktop"].executeCommand(Desktop.FORM_GOTFOCUS, this);
		}
		/**
		 * Non active window
		 */ 
		private function __focusOut(e:FocusEvent):void
		{
			frame.alpha = 0.5;
			//AsWingManager.getRoot()["desktop"].executeCommand(Desktop.FORM_LOSTFOCUS, this);
		}
		
		public function setFocus():void
		{
			frame.setFocusable(true);
		}
		
		private function renderFormContents(e:Event):void
		{
			if (child != null)
			{
				child.width = frame.width;
				child.height = frame.height;
				
				frame.getContentPane().append(child);
				child.validate();
			}
			
			//AsWingManager.getRoot()["desktop"].executeCommand(Desktop.FORM_LOADING, this);
		}
						
		private function frame_resize(e:ResizedEvent):void
		{
			if (child != null)
			{
				frame.getContentPane().getChildAt(1).width = e.currentTarget.width;
				frame.getContentPane().getChildAt(1).height = e.currentTarget.height;	
				this.dispatchEvent(new EmptyFormEvent(EmptyFormEvent.RESIZE, false, false, this));			
			}
			
			//AsWingManager.getRoot()["desktop"].executeCommand(Desktop.FORM_RESIZING, this);
		}
		/**
		 * Handle child objects disposal
		 */ 
		private function __closing(e:FrameEvent):void
		{			
			if(closable) return;

			if(disposable)
			{	
				frame.getContentPane().removeAll();
				frame.dispose();
					
				//AsWingManager.getRoot()["desktop"].executeCommand(Desktop.FORM_CLOSING, this);
			}
			else
			{
				var frame:JFrame = JFrame(e.currentTarget);
				frame.setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);
				this.dispatchEvent(new EmptyFormEvent(EmptyFormEvent.CLOSING, false, false, this));
			}									
		}
		
		public function dispose():void
		{
			frame.getContentPane().removeAll();
			frame.dispose();
					
			//AsWingManager.getRoot()["desktop"].executeCommand(Desktop.FORM_CLOSING, this);
		}
		
		public function centerOnStage():void
		{	
			if (frame.stage != null)
			{
				Tweener.addTween(frame, {y:frame.stage.stageHeight/2 - frame.getHeight()/2, x:frame.stage.stageWidth/2 - frame.getWidth()/2,	time:0.4});
			}
		}
	}	
}
