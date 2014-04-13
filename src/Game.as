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
		
		public static const CELL_SIDE_SIZE:Number = 20.0;
		public static const BALL_SIZE:Number = 25.0;
		
		public static const GRID_WIDTH:int = 16;
		public static const GRID_HEIGHT:int = 24;
		
		public static const BALL_COLORS:Vector.<uint> = new <uint>[ 0x00ff00, 0xff0000, 0x0000ff, 0xff00ff, 0x00ffff ];
		public static const CUE_STACK_LENGTH:int = 3;
		
		public static const SHOOT_ANG_LIMIT:Number = 0.1;
		
		public static const BALL_SPEED:Number = 400.0;	// Pixels pes second
		
		public static const START_LINES_NUM:int = 3;
		
		public static const FALL_STEP:int = 3;			// Number of shoots to fall
		
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