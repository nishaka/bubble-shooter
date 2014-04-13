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
	import field.Dummy;
	import starling.events.TouchPhase;
	
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
		private var _arrow:Sprite;
		
		private var _mouseDowned:Boolean;
		private var _lastMousePos:Point = new Point();
		
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
			
			_balls = new Balls(Game.GRID_WIDTH, Game.GRID_HEIGHT, _grid);
			_balls.onBusy = ballsOnBusy;
			_balls.onGameOver = ballsOnGameOver;
			_surface.addChild(_balls);
			
			_arrow = Dummy.getArrow(0x39b54a);
			_arrow.x = _balls.cueStartPos.x;
			_arrow.y = _balls.cueStartPos.y;
			_arrow.visible = false;
			_surface.addChild(_arrow);
			
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
			{
				_mouseDowned = false;
				_grid.highlightHex(null);
				_arrow.visible = false;
				return;
			}
			
			switch (touch.phase)
			{
				case TouchPhase.BEGAN:
				{
					_mouseDowned = true;
					break;
				}
				case TouchPhase.ENDED:
				{
					_mouseDowned = false;
					
					var pos:Point = touch.getLocation(_surface);
					_balls.shoot(pos);
					
					_arrow.visible = false;
					break;
				}
				default:
				{
					_mouseDowned = false;
					
					pos = touch.getLocation(_surface);
					if (!_lastMousePos.equals(pos))
					{
						_lastMousePos = pos;
						var hex:Hex = _grid.getHex(pos);
						
						var arrowAng:Number = Math.atan2(_balls.cueStartPos.y - pos.y, _balls.cueStartPos.x - pos.x);
						if (arrowAng < Game.SHOOT_ANG_LIMIT && pos.x < _balls.cueStartPos.x) arrowAng = Game.SHOOT_ANG_LIMIT;
						else if (arrowAng < 0 || arrowAng > Math.PI - Game.SHOOT_ANG_LIMIT) arrowAng = Math.PI - Game.SHOOT_ANG_LIMIT;
						
						_arrow.rotation = arrowAng - Math.PI / 2.0;
						
						_grid.highlightHex(hex);
						_arrow.visible = !_balls.busy;
					}
				}
			}
		}
		
		/**
		 * Balls busy handler
		 * @param	isBusy	is busy flag
		 */
		private function ballsOnBusy(isBusy:Boolean):void
		{
			_arrow.visible = !isBusy;
		}
		
		/**
		 * Balls game over handler
		 */
		public function ballsOnGameOver():void
		{
			trace ("game over");
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