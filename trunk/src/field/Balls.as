package field 
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import starling.animation.Tween;
	import flash.utils.getTimer;
	import starling.events.Event;
	import starling.core.Starling;
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
		
		private var _cue:Bubble;
		private var _cueStartPos:Point;
		
		private var _cueStack:Vector.<Bubble> = new Vector.<Bubble>();
		
		private var _lastLine:int;
		
		private var _busy:Boolean;
		
		private var _leftBorder:Number;
		private var _rightBorder:Number;
		private var _topBorder:Number;
		private var _bottomBorder:Number;
		
		private var _minOffset:Number;
		
		private var _r:Number;		// Ball radius
		
		private var _field:Vector.<Vector.<Bubble>> = new Vector.<Vector.<Bubble>>();
		
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
			
			var pos:Point = _grid.getHexMiddlePoint(new Hex(0, 0));
			
			_leftBorder = pos.x;
			_rightBorder = _grid.width - pos.x;
			_topBorder = pos.y;
			_bottomBorder = _grid.height;
			
			_lastLine = _hexHeight - 3;
			pos = _grid.getHexMiddlePoint(new Hex(0, _lastLine));
			_cueStartPos = new Point(_grid.width / 2, pos.y);
			
			_minOffset = _cueStartPos.y - (_cueStartPos.x - _leftBorder) * Math.tan(Game.SHOOT_ANG_LIMIT);
			
			init();
		}
		
		/**
		 * Initialize field
		 */
		private function init():void
		{
			_cueStack = new Vector.<Bubble>();
			for (var i:int = 0; i < Game.CUE_STACK_LENGTH; i++)
				_cueStack.push(new Bubble(Game.BALL_COLORS[int(Math.random() * Game.BALL_COLORS.length)]));
			
			arrangeCueStack();
			
			_cue = new Bubble(Game.BALL_COLORS[int(Math.random() * Game.BALL_COLORS.length)]);
			_cue.x = _cueStartPos.x;
			_cue.y = _cueStartPos.y;
			
			addChild(_cue);
			
			var numLines:int = Game.START_LINES_NUM > _lastLine - 1 ? _lastLine - 1 : Game.START_LINES_NUM;
			for (var by:int = 0; by < numLines; by++)
			{
				var line:Vector.<Bubble> = new Vector.<Bubble>();
				_field[by] = line;
				
				var bx:int, numBubbles:int;
				
				if (by % 2)
				{
					bx = 0;
					numBubbles = _hexWidth - 1;
				}
				else
				{
					bx = 1;
					numBubbles = _hexWidth;
					line.push(null);
				}
				
				for (; bx < numBubbles; bx++)
				{
					var bubble:Bubble = new Bubble(Game.BALL_COLORS[int(Math.random() * Game.BALL_COLORS.length)]);
					var pos:Point = _grid.getHexMiddlePoint(new Hex(bx, by));
					
					bubble.x = pos.x;
					bubble.y = pos.y;
					
					addChild(bubble);
					line.push(bubble);
				}
				
				if (numBubbles < _hexWidth)
					line.push(null);
			}
		}
		
		/**
		 * Arrange cue stack items helper
		 */
		private function arrangeCueStack():void
		{
			var ctr:int = 0;
			for (var i:int = Game.CUE_STACK_LENGTH - 1; i >= 0 ; i--)
			{
				var bubble:Bubble = _cueStack[i];
				bubble.x = _grid.width - (Game.BALL_SIZE + ctr++ * Game.BALL_SIZE * 0.7);
				bubble.y = _grid.height - Game.BALL_SIZE;
				addChild(bubble);
			}
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
			if (_busy)
				return;
			
			_busy = true;
			
			var path:Vector.<Point> = new Vector.<Point>();
			
			_cue.x = _cueStartPos.x;
			_cue.y = _cueStartPos.y;
			
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
			
			checkForIntersections(path);
			animateCue(path);
		}
		
		/**
		 * Check path for intersections with existing balls
		 * @param	path	path vertices
		 */
		private function checkForIntersections(path:Vector.<Point>):void
		{
			if (path.length < 2)
				return;
			
			var linesForCheck:Array = [];
			
			for (var by:int = 0; by < _field.length; by++)
			{
				var line:Vector.<Bubble> = _field[by];
				for (var bx:int = 0; bx < line.length; bx++)
				{
					var bubble:Bubble = line[bx];
					if (bubble)
					{
						// The line has bubbles
						var pos:Point = _grid.getHexMiddlePoint(new Hex(0, by + 1));
						linesForCheck.push({ line: by, axis: pos.y });
						break;
					}
				}
			}
			linesForCheck.sortOn("line", Array.NUMERIC | Array.DESCENDING);
			
			var endPoint:Point;
			var startPoint:Point = path[0];
			var rawCheckpoints:Vector.<Hex> = new Vector.<Hex>();
			var limitHex:Hex;
			for (var i1:int = 1; i1 < path.length; i1++)
			{
				endPoint = path[i1];
				
				var dx:Number = endPoint.x - startPoint.x;
				var dy:Number = endPoint.y - startPoint.y;
				var k:Number = dx / dy;
				
				rawCheckpoints.splice(0, rawCheckpoints.length);
				
				for (var i2:int = 0; i2 < linesForCheck.length; i2++)
				{
					var checkedLine:int = linesForCheck[i2].line;
					var axis:Number = linesForCheck[i2].axis;
					
					var crossPosition:Number = startPoint.x - (startPoint.y - axis) * k;
					if (crossPosition >= _leftBorder && crossPosition <= _rightBorder)
					{
						// This line of path cross the line of bubbles
						var crossHex:Hex = _grid.getHex(new Point(crossPosition, axis));
						
						if (limitHex)
						{
							rawCheckpoints.push(limitHex);
							limitHex = null;
						}
						
						rawCheckpoints.push(crossHex);
					}
				}
				
				if (i1 == path.length - 1)
				{
					if (limitHex)
					{
						rawCheckpoints.push(limitHex);
						limitHex = null;
					}
					
					rawCheckpoints.push(_grid.getHex(endPoint));
				}
				else
				{
					if (rawCheckpoints.length > 0 &&
						(dx > 0 && endPoint.x == _rightBorder ||
						 dx < 0 && endPoint.x == _leftBorder))
					{
						limitHex = _grid.getHex(endPoint);
						if (limitHex.y >= 0)
							rawCheckpoints.push(limitHex);
						else
							limitHex = null;
					}
					else
					{
						limitHex = null;
					}
				}
				
				if (rawCheckpoints.length == 0)
				{
					startPoint = endPoint;
					continue;
				}
				
				var checkpoints:Vector.<Hex> = new Vector.<Hex>();
				if (rawCheckpoints.length > 1)
				{
					/*
					// Add in-between hexagons, if needed
					var endHex:Hex;
					var startHex:Hex = rawCheckpoints[0];
					for (var i2:int = 1; i2 < rawCheckpoints.length; i2++)
					{
						checkpoints.push(startHex);
						
						endHex = rawCheckpoints[i2];
						
						if (!_grid.isNeighbours(startHex, endHex))
						{
							var hdy:int = endHex.x - startHex.x;
							
							if (hdy > 0)
							{
								for (var i3:int = 1; i3 <= hdy; i3++)
									checkpoints.push(new Hex(startHex.x + i3, startHex.y));
							}
							else
							{
								for (i3 = -1; i3 >= hdy; i3--)
									checkpoints.push(new Hex(startHex.x + i3, startHex.y));
							}
						}
						
						startHex = endHex;
					}
					checkpoints.push(endHex);
				}
				else
				{
					checkpoints = rawCheckpoints;*/
				}
				
				for each (var cp:Hex in rawCheckpoints)
				{
					var cross:Sprite = Dummy.getCross();
					var p:Point = _grid.getHexMiddlePoint(cp);
					cross.x = p.x;
					cross.y = p.y;
					addChild(cross);
				}
				
				startPoint = endPoint;
			}
			
			
		}
		
		/**
		 * Execute animation of cue
		 * @param	path	path vertices
		 */
		private function animateCue(path:Vector.<Point>):void
		{
			if (path.length < 2)
			{
				processBubble(_cue);
				animateNextCue();
				return;
			}
			
			var startPoint:Point = path.shift();
			var endPoint:Point = path[0];
			
			var dx:Number = endPoint.x - startPoint.x;
			var dy:Number = endPoint.y - startPoint.y;
			var pathLen:Number = Math.sqrt(dx * dx + dy * dy);
			
			var tween:Tween = new Tween(_cue, pathLen / Game.BALL_SPEED);
			tween.animate("x", endPoint.x);
			tween.animate("y", endPoint.y);
			tween.onCompleteArgs = [ path ];
			tween.onComplete = animateCue;
			
			Starling.juggler.add(tween);
		}
		
		/**
		 * Execute next cue incoming animation
		 */
		private function animateNextCue():void
		{
			_cue = _cueStack.shift();
			
			var tween:Tween = new Tween(_cue, 0.3);
			tween.animate("x", _cueStartPos.x);
			tween.animate("y", _cueStartPos.y);
			tween.onComplete = function():void {
				for each (var b:Bubble in _cueStack)
					removeChild(b);
				_cueStack.push(new Bubble(Game.BALL_COLORS[int(Math.random() * Game.BALL_COLORS.length)]));
				arrangeCueStack();
				
				_busy = false;
			};
			
			Starling.juggler.add(tween);
		}
		
		/**
		 * Check bubble shoot result
		 * @param	bubble	ex cue
		 */
		private function processBubble(bubble:Bubble):void
		{
			
		}
	}
}