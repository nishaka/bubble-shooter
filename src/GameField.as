package  
{
	import feathers.controls.ButtonGroup;
	import feathers.controls.LayoutGroup;
	import feathers.controls.Screen;
	import feathers.data.ListCollection;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import field.Balls;
	import field.Hex;
	import field.HexGrid;
	import flash.geom.Point;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.Event;
	
	/**
	 * Game field
	 * @author jvirkovskiy
	 */
	public class GameField extends Screen 
	{
		//------------------------
		//
		//------------------------
		
		private var _surface:Sprite;
		private var _grid:HexGrid;
		private var _balls:Balls;
		
		//------------------------
		//
		//------------------------
		
		/**
		 * Constructor
		 */
		public function GameField() 
		{
			super();
			
			layout = new AnchorLayout();
			
			_surface = new Sprite();
			_surface.addEventListener(TouchEvent.TOUCH, touchEventHandler);
			
			_grid = new HexGrid(Game.GRID_WIDTH, Game.GRID_HEIGHT, Game.CELL_SIDE_SIZE);
			_surface.addChild(_grid);
			
			_balls 
			
			var layoutGroup:LayoutGroup = new LayoutGroup();
			layoutGroup.addChild(_surface);
			layoutGroup.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0.0, -25.0);
			
			addChild(layoutGroup);
			
			var buttonGroup:ButtonGroup = new ButtonGroup();
			buttonGroup.direction = ButtonGroup.DIRECTION_HORIZONTAL;
			buttonGroup.gap = 5;
			buttonGroup.dataProvider = new ListCollection([
				{ label: "Menu", triggered: onMenuHandler },
				{ label: "Score", triggered: onScoreHandler }
			]);
			buttonGroup.layoutData = new AnchorLayoutData(NaN, NaN, 20.0, NaN, 0.0, NaN);
			
			addChild(buttonGroup);
		}
		
		/**
		 * Touch event handler
		 * @param	event	event
		 */
		private function touchEventHandler(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_surface);
			if (!touch)
				return;
			
			var pos:Point = touch.getLocation(_surface);
			var hex:Hex = _grid.getHex(pos);
			
			_grid.highlightHex(hex);
		}
		
		/**
		 * Main menu button pressed
		 * @param	event	event
		 */
		private function onMenuHandler(event:Event):void
		{
			dispatchEventWith("onMainMenu");
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