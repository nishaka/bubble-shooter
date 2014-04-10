package field 
{
	import flash.geom.Point;
	import starling.display.Sprite;
	
	/**
	 * Balls layer
	 * @author jvirkovskiy
	 */
	public class Balls extends Sprite 
	{
		//------------------------
		//
		//------------------------
		
		private var _hexWidth:int;
		private var _hexHeight:int;
		
		private var _grid:HexGrid;
		
		private var _cue:Sprite;
		private var _cueStartPos:Point;
		private var _cueStack:Vector.<uint> = new Vector.<uint>();
		
		private var _lastLine:int;
		
		private var _busy:Boolean;
		
		private var _leftBorder:Number;
		private var _rightBorder:Number;
		private var _topBorder:Number;
		private var _bottomBorder:Number;
		
		// left and right borders reflection gate
		private var _angReflectionMin:Number;
		private var _angReflectionMax:Number;
		
		private var _r:Number;		// Ball radius
		
		//------------------------
		//
		//------------------------
		
		/**
		 * Constructor
		 * @param	hexWidth	width of grid in hexagons
		 * @param	hexHeight	height of grid in hexagons
		 * @param	grid		hexagonal grid
		 */
		public function Balls(hexWidth:int, hexHeight:int, grid:HexGrid) 
		{
			super();
			
			_hexWidth = hexWidth;
			_hexHeight = hexHeight;
			
			_grid = grid;
			
			_leftBorder = 0.0;
			_rightBorder = _grid.width;
			_topBorder = 0.0;
			_bottomBorder = _grid.height;
			
			_lastLine = hexHeight - 3;
			
			var pos:Point = _grid.getHexMiddlePoint(new Hex(0, _lastLine));
			_cueStartPos = new Point(_grid.width / 2, pos.y);
			
			_angReflectionMin = Math.atan(_cueStartPos.y / _cueStartPos.x);
			_angReflectionMax = Math.PI - _angReflectionMin;
			
			_r = Game.BALL_SIZE / 2.0;
			
			init();
		}
		
		/**
		 * Initialize field
		 */
		private function init():void
		{
			_cueStack = new Vector.<uint>();
			for (var i:int = 0; i < Game.CUE_STACK_LENGTH; i++)
				_cueStack.push(Game.BALL_COLORS[int(Math.random() * Game.BALL_COLORS.length)]);
			
			_cue = Dummy.getBall(Game.BALL_COLORS[int(Math.random() * Game.BALL_COLORS.length)]);
			_cue.x = _cueStartPos.x;
			_cue.y = _cueStartPos.y;
			
			addChild(_cue);
		}
		
		/**
		 * Some animation is in process
		 */
		public function get busy():Boolean
		{
			return _busy;
		}
		
		/**
		 * Cue start position
		 */
		public function get cueStartPos():Point
		{
			return _cueStartPos;
		}
		
		/**
		 * Shoot to specified position
		 * @param	targetPoint	target point
		 */
		public function shoot(targetPoint:Point):void
		{
			//_busy = true;
			
			var path:Vector.<Point> = new Vector.<Point>();
			path.push(_cueStartPos.clone());
			
			var ang:Number = Math.atan2(_cueStartPos.y - targetPoint.y, _cueStartPos.x - targetPoint.x);
			
			// Prevent "deadlocks"
			if (ang < 0)
				ang = targetPoint.x < _cueStartPos.x ? 0.0001 : Math.PI - 0.0001;
			
			// Calculate ball path
			var currentCuePos:Point = _cueStartPos.clone();
			
			while (currentCuePos.y  > 0.0)
			{
				var dx:Number = targetPoint.x - currentCuePos.x;
				var dy:Number = targetPoint.y - currentCuePos.y;
				var px:Number, py:Number;
				
				if (ang < _angReflectionMin)
				{
					// Reflect from left border
					
					trace ("left reflect");
					break;
				}
				else if (ang > _angReflectionMax)
				{
					// Reflect from right border
					
					trace ("right reflect");
					break;
				}
				else
				{
					// Throw
					px = _cueStartPos.x - dx / dy * _cueStartPos.y;
					py = 0.0;
				}
				
				currentCuePos.x = px;
				currentCuePos.y = py;
				
				path.push(currentCuePos.clone());
			}
			
			for each (var p:Point in path)
			{
				var cross:Sprite = Dummy.getCross();
				cross.x = p.x;
				cross.y = p.y;
				
				addChild(cross);
			}
		}
	}
}