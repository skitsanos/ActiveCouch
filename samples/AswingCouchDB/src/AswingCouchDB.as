package
{

	import com.skitsanos.api.CouchDb;
	import com.skitsanos.api.CouchDbEvent;
	import com.skitsanos.api.ServerResponse;
	import com.skitsanos.aswing.ui.EmptyForm;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import org.aswing.AsWingManager;
	import org.aswing.JButton;
	import org.aswing.JPanel;

	public class AswingCouchDB extends Sprite
	{
		private var couchDbHost:String = 'kanapeside.iriscouch.com';
		private var couchDbPort:int = 80;
		private var couchDbUsername:String = '';
		private var couchDbPassword:String = '';

		public function AswingCouchDB()
		{
			super();

			if (stage != null)
			{
				init();
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}

		public function init(e:Event = null):void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, resizeHandler);
			stage.showDefaultContextMenu = false;

			AsWingManager.initAsStandard(this, true);

			var frm:EmptyForm = new EmptyForm(this);
			frm.title = 'Aswing CouchDB Demo';
			frm.closable = false;

			//content
			var content:JPanel = new JPanel();

			var btnConnect:JButton = new JButton('Check');
			btnConnect.addEventListener(MouseEvent.CLICK, function(mouse_click_event:MouseEvent):void
			{
				btnConnect.setText('Connecting...');
				var couchdb:CouchDb = new CouchDb(couchDbHost, couchDbPort, couchDbUsername, couchDbPassword);
				couchdb.addEventListener(CouchDbEvent.DB_EXIST, function(db_exists_event:CouchDbEvent, result:*, response:ServerResponse):void
				{
					btnConnect.setText('Check');
					//add your actions here
				});
				couchdb.databaseExists("demo");
			});
			content.append(btnConnect);

			frm.child = content;

			frm.show();
			frm.centerOnStage();
		}

		private function resizeHandler(e:Event):void
		{

		}
	}
}
