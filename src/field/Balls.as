package field 
{
	import flash.geom.Point;
	import starling.display.Sprite;
	import flash.utils.getTimer;
	import starling.events.Event;
	
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
		
		private var _animation:Vector.<Point> = new Vector.<Point>();
		
		private var _dt:Number;
		private var _timestamp:int;
		
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
			
			_dt = 1000.0 / Game.FPS;
			
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
			
			/*
			for each (var p:Point in path)
			{
				var cross:Sprite = Dummy.getCross();
				cross.x = p.x;
				cross.y = p.y;
				
				addChild(cross);
			}
			*/
			
			calcAnimation(path);
		}
		
		/**
		 * Calculate animation of cue
		 * @param	path	path vertices
		 */
		private function calcAnimation(path:Vector.<Point>):void
		{
			_animation = new Vector.<Point>();
			
			if (path.length < 2)
			{
				_busy = false;
				return;
			}
			
			var lineBegin:Point = path.shift();
			var rest:Number = 0.0;
			var lineEnd:Point;
			
			while (path.length > 0)
			{
				lineEnd = path.shift();
				
				var ang:Number = Math.atan2(lineEnd.y - lineBegin.y, lineEnd.x - lineBegin.x);
				var dx:Number = Math.cos(ang) * Game.BALL_SPEED;
				var dy:Number = Math.sin(ang) * Game.BALL_SPEED;
				
				var px:Number, py:Number;
				if (rest > 0)
				{
					px = lineBegin.x + Math.cos(ang) * rest;
					py = lineBegin.y + Math.sin(ang) * rest;
				}
				else
				{
					px = lineBegin.x;
					py = lineBegin.y;
				}
				
				var lineWidth:Number = Math.abs(lineEnd.x - lineBegin.x);
				var lineHeight:Number = Math.abs(lineEnd.y - lineBegin.y);
				
				while (Math.abs(px - lineBegin.x) <= lineWidth && Math.abs(py - lineBegin.y) <= lineHeight)
				{
					_animation.push(new Point(px, py));
					px += dx;
					py += dy;
				}
				
				dx = Math.abs(px - lineBegin.x) - lineWidth;
				dy = Math.abs(py - lineBegin.y) - lineHeight;
				rest = Math.sqrt(dx * dx + dy * dy);
				
				lineBegin = lineEnd;
			}
			
			/*
			for each (var p:Point in _animation)
			{
				var cross:Sprite = Dummy.getCross();
				cross.x = p.x;
				cross.y = p.y;
				
				addChild(cross);
			}
			*/
			
			playCueAnimation();
		}
		
		/**
		 * Play cue animation
		 */
		private function playCueAnimation():void
		{
			_timestamp = getTimer();
			
			if (!hasEventListener(Event.ENTER_FRAME))
				addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		/**
		 * Enter frame handler
		 * @param	event	event
		 */
		private function enterFrameHandler(event:Event):void
		{
			var now:int = getTimer();
			var currentFrame:int = Math.round((now - _timestamp) / _dt);
			if (currentFrame < 0) currentFrame = 0;
			
			if (currentFrame < _animation.length)
			{
				// next frame
				var pos:Point = _animation[currentFrame];
				if (_cue)
				{
					_cue.x = pos.x;
					_cue.y = pos.y;
				}
			}
			else
			{
				// complete
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
		}
	}
}