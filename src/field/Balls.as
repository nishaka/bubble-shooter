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
		
		private var _minOffset:Number;
		
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
			
			_r = Game.BALL_SIZE / 2.0;
			
			_leftBorder = _r;
			_rightBorder = _grid.width - _r;
			_topBorder = _r;
			_bottomBorder = _grid.height - _r;
			
			_lastLine = hexHeight - 3;
			var pos:Point = _grid.getHexMiddlePoint(new Hex(0, _lastLine));
			_cueStartPos = new Point(_grid.width / 2, pos.y);
			
			_minOffset = _cueStartPos.y - (_cueStartPos.x - _leftBorder) * Math.tan(Game.SHOOT_ANG_LIMIT);
			
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
			if (ang < Game.SHOOT_ANG_LIMIT && targetPoint.x < _cueStartPos.x)
			{
				ang = Game.SHOOT_ANG_LIMIT;
				targetPoint.x = _leftBorder;
				targetPoint.y = _minOffset;
			}
			else if (ang < 0 || ang > Math.PI - Game.SHOOT_ANG_LIMIT)
			{
				ang = Math.PI - Game.SHOOT_ANG_LIMIT;
				targetPoint.x = _rightBorder;
				targetPoint.y = _minOffset;
			}
			
			// Calculate ball path
			var currentCuePos:Point = _cueStartPos.clone();
			
			var iterLimit:int = 100;
			while (currentCuePos.y  > _topBorder && iterLimit--)
			{
				var dx:Number = targetPoint.x - currentCuePos.x;
				var dy:Number = targetPoint.y - currentCuePos.y;
				var px:Number, py:Number;
				
				var reflectionMinAng:Number = Math.atan((currentCuePos.y - _topBorder) / (currentCuePos.x - _leftBorder));
				var reflectionMaxAng:Number = Math.PI - Math.atan((currentCuePos.y - _topBorder) / (_rightBorder - currentCuePos.x));
				
				if (ang < reflectionMinAng)
				{
					// Reflect from left border
					px = _leftBorder;
					py = currentCuePos.y - (currentCuePos.x - _leftBorder) * dy / dx;
					if (py > _minOffset) py = _minOffset;
					
					targetPoint.x = _rightBorder;
					targetPoint.y = py - (_rightBorder - _leftBorder) * dy / dx;
				}
				else if (ang > reflectionMaxAng)
				{
					// Reflect from right border
					px = _rightBorder;
					py = currentCuePos.y + (_rightBorder - currentCuePos.x) * dy / dx;
					if (py > _minOffset) py = _minOffset;
					
					targetPoint.x = _leftBorder;
					targetPoint.y = py + (_rightBorder - _leftBorder) * dy / dx;
				}
				else
				{
					// Through
					px = currentCuePos.x - dx / dy * (currentCuePos.y - _topBorder);
					py = _topBorder;
				}
				
				ang = Math.PI - ang;
				
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