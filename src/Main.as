package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import starling.core.Starling;
	
	/**
	 * Bubble shooter
	 * @author jvirkovskiy
	 */
	[SWF (width="600", height="800", frameRate="30", backgroundColor="#ffffff")]
	public class Main extends Sprite 
	{
		//------------------------
		//
		//------------------------
		
		private var _starling:Starling;
		
		//------------------------
		//
		//------------------------
		
		/**
		 * Constructor
		 */
		public function Main():void 
		{
			super();
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/**
		 * Added to stage point
		 * @param	event	event
		 */
		private function init(event:Event = null):void 
		{
			if (Event)
				removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_starling = new Starling(Game, stage);
			_starling.start();
		}
	}
}