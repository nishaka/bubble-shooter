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
	import feathers.core.PopUpManager;
	
	/**
	 * Main menu
	 * @author jvirkovskiy
	 */
	public class MainMenu extends Screen 
	{
		//------------------------
		//
		//------------------------
		
		private var _statistics:Statistics;
		
		//------------------------
		//
		//------------------------
		
		/**
		 * Constructor
		 */
		public function MainMenu(statistics:Statistics=null)
		{
			super();
			
			_statistics = statistics;
			
			layout = new AnchorLayout();
			
			var buttonGroup:ButtonGroup = new ButtonGroup();
			buttonGroup.direction = ButtonGroup.DIRECTION_VERTICAL;
			buttonGroup.gap = 5;
			buttonGroup.dataProvider = new ListCollection([
				{ label: "Play", triggered: onPlayHandler },
				{ label: "Score", triggered: onScoreHandler }
			]);
			buttonGroup.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0.0, 0.0);
			
			addChild(buttonGroup);
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
			if (_statistics)
				PopUpManager.addPopUp(_statistics);
		}
	}
}