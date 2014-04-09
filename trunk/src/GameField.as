package  
{
	import feathers.controls.LayoutGroup;
	import feathers.controls.Screen;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import field.Hex;
	import field.HexGrid;
	import flash.geom.Point;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
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
			
			_grid = new HexGrid(10, 10, 30);
			_surface.addChild(_grid);
			
			var layoutGroup:LayoutGroup = new LayoutGroup();
			layoutGroup.addChild(_surface);
			layoutGroup.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
			
			addChild(layoutGroup);
			
		}
		
		private function touchEventHandler(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_surface);
			if (!touch)
				return;
			
			var pos:Point = touch.getLocation(_surface);
			var hex:Hex = _grid.getHex(pos);
			
			trace("x = " + pos.x + ", y = " + pos.y + "; hex " + hex.x + ":" + hex.y);
		}
	}
}