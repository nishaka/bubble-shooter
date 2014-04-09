package  
{
	import feathers.controls.ScreenNavigator;
	import feathers.controls.ScreenNavigatorItem;
	import feathers.motion.transitions.ScreenSlidingStackTransitionManager;
	import feathers.themes.AeonDesktopTheme;
	import feathers.events.FeathersEventType;
	import starling.events.Event;
	
	/**
	 * Vain view
	 * @author jvirkovskiy
	 */
	public class Game extends ScreenNavigator 
	{
		//------------------------
		//
		//------------------------
		
		private var _transitionManager:ScreenSlidingStackTransitionManager;
		
		//------------------------
		//
		//------------------------
		
		/**
		 * Constructor
		 */
		public function Game():void 
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
			new AeonDesktopTheme();
			
			clipContent = true;
			
			_transitionManager = new ScreenSlidingStackTransitionManager(this);
			_transitionManager.duration = 0.5;
			
			addScreen(ScreenId.MAIN_MENU, new ScreenNavigatorItem(MainMenu, { onPlay: ScreenId.GAME_FIELD } ));
			addScreen(ScreenId.GAME_FIELD, new ScreenNavigatorItem(GameField, { onMainMenu: ScreenId.MAIN_MENU } ));
			
			showScreen(ScreenId.MAIN_MENU);
		}
	}
}