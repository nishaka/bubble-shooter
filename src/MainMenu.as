package  
{
	import feathers.controls.ButtonGroup;
	import feathers.controls.Screen;
	import feathers.data.ListCollection;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import feathers.events.FeathersEventType;
	
	/**
	 * Main menu
	 * @author jvirkovskiy
	 */
	public class MainMenu extends Screen 
	{
		//------------------------
		//
		//------------------------
		
		private var _group:ButtonGroup;
		
		//------------------------
		//
		//------------------------
		
		/**
		 * Constructor
		 */
		public function MainMenu() 
		{
			super();
			addEventListener(FeathersEventType.INITIALIZE, initializeHandler);
		}
		
		/**
		 * Initialize handler
		 * @param	event	event
		 */
		private function initializeHandler(event:Event):void
		{
			layout = new AnchorLayout();
			
			_group = new ButtonGroup();
			_group.direction = ButtonGroup.DIRECTION_VERTICAL;
			_group.gap = 5;
			_group.dataProvider = new ListCollection([
				{ label: "Play", triggered: onPlayHandler },
				{ label: "Score", triggered: onScoreHandler }
			]);
			_group.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
			
			addChild(_group);
		}
		
		/**
		 * Play button pressed
		 * @param	event	event
		 */
		private function onPlayHandler(event:Event):void
		{
			dispatchEventWith("onPlay");
		}
		
		/**
		 * Score button pressed
		 * @param	event	event
		 */
		private function onScoreHandler(event:Event):void
		{
			
		}
	}
}