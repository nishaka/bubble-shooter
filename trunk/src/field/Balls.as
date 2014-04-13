package field 
{
	import adobe.utils.CustomActions;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import starling.animation.Tween;
	import flash.utils.getTimer;
	import starling.events.Event;
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.animation.Transitions;
	
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
		private var _box:Box;
		
		private var _cue:Bubble;
		private var _cueStartPos:Point;
		
		private var _cueStack:Vector.<Bubble> = new Vector.<Bubble>();
		
		private var _lastLine:int;
		
		private var _busy:Boolean;
		private var _gameOver:Boolean = false;
		private var _win:Boolean = false;
		
		private var _r:Number;		// Ball radius
		
		private var _field:Vector.<Vector.<Bubble>> = new Vector.<Vector.<Bubble>>();
		
		private var _signalListeners:Dictionary = new Dictionary(true);
		
		private var _shootCtr:int = 0;
		private var _animationsQueue:Dictionary = new Dictionary();
		
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
			_box = new Box(pos.x, _grid.width - pos.x, pos.y, _grid.height);
			
			_lastLine = _hexHeight - 5 + (_hexHeight % 2);
			
			pos = _grid.getHexMiddlePoint(new Hex(0, _lastLine + 2 - (_hexHeight % 2)));
			_cueStartPos = new Point(_grid.width / 2, pos.y);
			
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
				fillLine(line, by);
			}
		}
		
		/**
		 * Helper for fill line with random bubbles
		 * @param	line	line
		 * @param	yPos	y position of line
		 */
		private function fillLine(line:Vector.<Bubble>, yPos:int):void
		{
			var bx:int, numBubbles:int;
			
			if (yPos % 2)
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
				var pos:Point = _grid.getHexMiddlePoint(new Hex(bx, yPos));
				
				bubble.x = pos.x;
				bubble.y = pos.y;
				
				addChild(bubble);
				line.push(bubble);
			}
			
			if (numBubbles < _hexWidth)
				line.push(null);
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
		 * Busy signal handler (function(isBusy:Boolean):void)
		 */
		public function set onBusy(value:Function):void
		{
			_signalListeners["onBusy"]  = value;
		}
		
		/**
		 * Game over signal handler (function():void)
		 */
		public function set onGameOver(value:Function):void
		{
			_signalListeners["onGameOver"]  = value;
		}
		
		/**
		 * You win signal handler (function():void)
		 */
		public function set onWin(value:Function):void
		{
			_signalListeners["onWin"]  = value;
		}
		
		/**
		 * Handle cpecified event
		 * @param	event	event name
		 * @param	args	handler arguments
		 */
		private function handle(event:String, args:Array):void
		{
			var handler:Function = _signalListeners[event] as Function;
			if (handler != null)
				handler.apply(this, args);
		}
		
		/**
		 * Some animation is in process
		 */
		public function get busy():Boolean
		{
			return _busy || _gameOver || _win;
		}
		
		/**
		 * Game over flag
		 */
		public function get gameOver():Boolean
		{
			return _gameOver;
		}
		
		/**
		 * You win flag
		 */
		public function get win():Boolean
		{
			return _win;
		}
		
		/**
		 * Helper for set busy flag and execute listener, if common state changed
		 * @param	value	new value of busy flag
		 */
		private function setBusy(value:Boolean):void
		{
			var oldValue:Boolean = busy;
			_busy = value;
			if (busy != oldValue)
				handle("onBusy", [ busy ]);
		}
		
		/**
		 * Helper for set game over flag and execute necessary listeners
		 * @param	value	new value of game over flag
		 */
		private function setGameOver(value:Boolean):void
		{
			if (value == _gameOver)
				return;
			
			var oldBusyValue:Boolean = busy;
			_gameOver = value;
			if (busy != oldBusyValue)
				handle("onBusy", [ busy ]);
			
			if (_gameOver)
				handle("onGameOver", null);
		}
		
		/**
		 * Helper for set win flag and execute necessary listeners
		 * @param	value	new value of win flag
		 */
		private function setWin(value:Boolean):void
		{
			if (value == _win)
				return;
			
			var oldBusyValue:Boolean = busy;
			_win = value;
			if (busy != oldBusyValue)
				handle("onBusy", [ busy ]);
			
			if (_win)
				handle("onWin", null);
			
			if (_win)
				setGameOver(true);
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
			if (busy)
				return;
			
			setBusy(true);
			
			_cue.x = _cueStartPos.x;
			_cue.y = _cueStartPos.y;
			
			var path:Vector.<Point> = _box.getPath(_cueStartPos, targetPoint);
			
			if (path.length > 1)
			{
				_shootCtr++;
				
				checkForIntersections(path);
				
				registerAnimation("shoot");
				animateCue(path);
			}
		}
		
		/**
		 * Check path for intersections with existing bubbles
		 * @param	path	path vertices
		 */
		private function checkForIntersections(path:Vector.<Point>):void
		{
			// TODO: Refactor this
			
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
			
			// path line
			var endPoint:Point;
			var startPoint:Point = path[0];
			
			var rawCheckpoints:Vector.<Hex> = new Vector.<Hex>();
			
			var limitHex:Hex	// hex, where bubble collide with others
			var finalHex:Hex;	// final hex, where the bubble is stopped
			
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
					if (crossPosition >= _box.left && crossPosition <= _box.right)
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
						(dx > 0 && endPoint.x == _box.right ||
						 dx < 0 && endPoint.x == _box.left))
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
				
				var checkpoints:Vector.<Hex>;
				if (rawCheckpoints.length > 1)
				{
					checkpoints = new Vector.<Hex>();
					
					// Add in-between hexagons, if needed
					var endHex:Hex;
					var startHex:Hex = rawCheckpoints[0];
					for (var i3:int = 1; i3 < rawCheckpoints.length; i3++)
					{
						checkpoints.push(startHex);
						
						endHex = rawCheckpoints[i3];
						
						if (!_grid.isNeighbours(startHex, endHex))
						{
							var hdy:int = endHex.x - startHex.x;
							
							if (hdy > 0)
							{
								for (var i4:int = 1; i4 <= hdy; i4++)
									checkpoints.push(new Hex(startHex.x + i4, startHex.y));
							}
							else
							{
								for (i4 = -1; i4 >= hdy; i4--)
									checkpoints.push(new Hex(startHex.x + i4, startHex.y));
							}
						}
						
						startHex = endHex;
					}
					checkpoints.push(endHex);
				}
				else
				{
					checkpoints = rawCheckpoints;
				}
				
				for (i4 = 0; i4 < checkpoints.length; i4++)
				{
					var checkpoint:Hex = checkpoints[i4];
					var nextCheckpoint:Hex = i4 < checkpoints.length - 1 ? checkpoints[i4 + 1] : checkpoint;
					
					// Collision checker
					var isCollide:Function = function(hex:Hex):Boolean {
						var bubble:Bubble = getBubble(hex);
						if (bubble && hex.isEqual(nextCheckpoint))
						{
							finalHex = checkpoint;
							return true;
						}
						return false;
					};
					
					var topHex:Hex = checkpoint.y % 2 ? new Hex(checkpoint.x, checkpoint.y - 1) : new Hex(checkpoint.x - 1, checkpoint.y - 1);
					if (isCollide(topHex))
						break;
					
					topHex = checkpoint.y % 2 ? new Hex(checkpoint.x + 1, checkpoint.y - 1) : new Hex(checkpoint.x, checkpoint.y - 1);
					if (isCollide(topHex))
						break;
					
					var sideHex:Hex = new Hex(checkpoint.x - 1, checkpoint.y);
					if (isCollide(sideHex))
						break;
					
					sideHex = new Hex(checkpoint.x + 1, checkpoint.y);
					if (isCollide(sideHex))
						break;
				}
				
				if (finalHex)
				{
					path[i1] = _grid.getHexMiddlePoint(finalHex);
					
					var rest:int = path.length - (i1 + 1);
					if (rest)
						path.splice(i1 + 1, rest);
					
					if (!insertBubble(_cue, finalHex))
						setGameOver(true);
				}
				
				startPoint = endPoint;
			}
			
			if (!finalHex)
			{
				// No collisions detected
				finalHex = _grid.getHex(endPoint);
				path[path.length - 1] = _grid.getHexMiddlePoint(finalHex);
				
				if (!insertBubble(_cue, finalHex))
					setGameOver(true);
			}
		}
		
		/**
		 * Get bubble from specified hexagon
		 * @param	hex				hexagon
		 * @param	bubblesField	field
		 * @return	bubble in specified position
		 */
		private function getBubble(hex:Hex, bubblesField:Vector.<Vector.<Bubble>>=null):Bubble
		{
			if (!bubblesField)
				bubblesField = _field;
				
			if (hex.y >= 0 && hex.y < bubblesField.length)
			{
				var line:Vector.<Bubble> = bubblesField[hex.y];
				if (hex.x >= 0 && hex.x < line.length)
					return line[hex.x];
			}
			return null;
		}
		
		/**
		 * Insert bubble to specified cell of field
		 * @param	bubble			bubble
		 * @param	hex				cell position
		 * @param	bubblesField	field
		 * @return	true, if success
		 */
		private function insertBubble(bubble:Bubble, hex:Hex, bubblesField:Vector.<Vector.<Bubble>>=null):Boolean
		{
			if (!bubblesField)
				bubblesField = _field;
				
			if (hex.x >= 0 && hex.x < _hexWidth &&
				hex.y >= 0 && hex.y <= _lastLine)
			{
				while (hex.y >= bubblesField.length)
					bubblesField.push(new Vector.<Bubble>());
				
				var line:Vector.<Bubble> = bubblesField[hex.y];
				while (hex.x >= line.length)
					line.push(null);
				
				line[hex.x] = bubble;
				
				return true;
			}
			return false;
		}
		
		/**
		 * Remove bubble from specified cell
		 * @param	hex				cell
		 * @param	bubblesField	field
		 * @return	true, if success
		 */
		private function removeBubble(hex:Hex, bubblesField:Vector.<Vector.<Bubble>>=null):Boolean
		{
			if (!bubblesField)
				bubblesField = _field;
				
			if (hex.y >= 0 && hex.y < bubblesField.length)
			{
				var line:Vector.<Bubble> = bubblesField[hex.y];
				if (hex.x >= 0 && hex.x < line.length)
				{
					line[hex.x] = null;
					return true;
				}
			}
			return false;
		}
		
		/**
		 * Clone specified field
		 * @param	bubblesField	source field
		 * @return	clone
		 */
		private function cloneField(bubblesField:Vector.<Vector.<Bubble>>):Vector.<Vector.<Bubble>>
		{
			var res:Vector.<Vector.<Bubble>> = new Vector.<Vector.<Bubble>>();
			for (var i:int = 0; i < bubblesField.length; i++)
				res.push(bubblesField[i].slice());
			return res;
		}
		
		/**
		 * Check field
		 * @param	bubblesField	field
		 * @return	true, if field has no any bubble
		 */
		private function fieldIsEmpty(bubblesField:Vector.<Vector.<Bubble>> = null):Boolean
		{
			if (!bubblesField)
				bubblesField = _field;
				
			for (var hy:int = 0; hy < bubblesField.length; hy++)
			{
				var line:Vector.<Bubble> = bubblesField[hy];
				for (var hx:int = 0; hx < line.length; hx++)
				{
					if (line[hx])
						return false;
				}
			}
			return true;
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
				
				unregisterAnimation("shoot");
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
			registerAnimation("recharge");
			
			_cue = _cueStack.shift();
			
			var tween:Tween = new Tween(_cue, 0.3);
			tween.animate("x", _cueStartPos.x);
			tween.animate("y", _cueStartPos.y);
			tween.onComplete = function():void {
				for each (var b:Bubble in _cueStack)
					removeChild(b);
				_cueStack.push(new Bubble(Game.BALL_COLORS[int(Math.random() * Game.BALL_COLORS.length)]));
				arrangeCueStack();
				
				unregisterAnimation("recharge");
			};
			
			Starling.juggler.add(tween);
		}
		
		private function registerAnimation(animName:String):void
		{
			_animationsQueue[animName] = true;
		}
		
		private function unregisterAnimation(animName:String):void
		{
			_animationsQueue[animName] = false;
			
			for each (var flag:Boolean in _animationsQueue)
				if (flag)
					return;
			
			// No active animations
			setBusy(false);
		}
		
		/**
		 * Check bubble shoot result
		 * @param	bubble	ex cue
		 */
		private function processBubble(bubble:Bubble):void
		{
			var color:uint = bubble.color;
			
			var blackList:Vector.<Hex> = new Vector.<Hex>();
			var checkList:Vector.<Hex> = new Vector.<Hex>();
			checkList.push(_grid.getHex(new Point(bubble.x, bubble.y)))
			
			var alreadyInBlackList:Function = function(h:Hex):Boolean {
				for each (var b:Hex in blackList)
					if (b.isEqual(h))
						return true;
				return false;
			};
			
			while (checkList.length > 0)
			{
				var newCheckList:Vector.<Hex> = new Vector.<Hex>();
				
				for each (var hex:Hex in checkList)
				{
					var neighbours:Vector.<Hex> = _grid.getNeighbours(hex);
					for each (var neighbour:Hex in neighbours)
					{
						if (!alreadyInBlackList(neighbour))
						{
							bubble = getBubble(neighbour);
							if (bubble && bubble.color == color)
								newCheckList.push(neighbour);
						}
					}
				}
				
				blackList = blackList.concat(checkList);
				checkList = newCheckList;
			}
			
			if (blackList.length > 1)
			{
				// Has bubbles for remove
				batchRemoveBubbles(blackList, "removeBubbles", checkHangingBubbles);
			}
			else
			{
				checkHangingBubbles();
			}
		}
		
		/**
		 * Check for "hanging" bubbles
		 */
		private function checkHangingBubbles():void
		{
			var tmpField:Vector.<Vector.<Bubble>> = cloneField(_field);
			var blackList:Vector.<Hex> = new Vector.<Hex>();
			
			do {
				var island:Vector.<Hex> = new Vector.<Hex>();
				
				for (var hy:int = 0; hy < tmpField.length; hy++)
				{
					var line:Vector.<Bubble> = tmpField[hy];
					
					for (var hx:int = 0; hx < line.length; hx++)
					{
						var bubble:Bubble = line[hx];
						if (bubble)
						{
							var newCells:Vector.<Hex> = new Vector.<Hex>();
							var hex:Hex = new Hex(hx, hy);
							
							newCells.push(hex);
							removeBubble(hex, tmpField);
							
							while (newCells.length > 0)
							{
								var tmp:Vector.<Hex> = new Vector.<Hex>();
								
								for each (hex in newCells)
								{
									var neighbours:Vector.<Hex> = _grid.getNeighbours(hex);
									for each (var neighbour:Hex in neighbours)
									{
										if (getBubble(neighbour, tmpField))
										{
											tmp.push(neighbour);
											removeBubble(neighbour, tmpField);
										}
									}
								}
								
								island = island.concat(newCells);
								newCells = tmp;
							}
							
							break;
						}
					}
					
					if (island.length > 0)
						break;
				}
				
				var isHanging:Boolean = island.length > 0;
				for each (hex in island)
				{
					if (hex.y == 0)
					{
						isHanging = false;
						break;
					}
				}
				
				if (isHanging)
					blackList = blackList.concat(island);
				
			} while (island.length > 0);
			
			if (blackList.length > 0)
				batchRemoveBubbles(blackList, "removeHanging", processFall);
			else
				processFall();
		}
		
		/**
		 * Helper for remove from scene set of bubbles
		 * @param	list			set of removed bubbles
		 * @param	animationName	animation name
		 * @param	completeHandler	animation complete handler
		 */
		private function batchRemoveBubbles(list:Vector.<Hex>, animationName:String, completeHandler:Function):void
		{
			registerAnimation(animationName);
			var bubblesForRemove:Vector.<Bubble> = new Vector.<Bubble>();
			
			for each (var hex:Hex in list)
			{
				var bubble:Bubble = getBubble(hex);
				bubblesForRemove.push(bubble);
				removeBubble(hex);
				
				var tween:Tween = new Tween(bubble, 0.5, Transitions.EASE_IN_BACK);
				tween.scaleTo(0.1);
				Starling.juggler.add(tween);
			}
			
			tween.onComplete = function():void {
				for each (var b:Bubble in bubblesForRemove)
					removeChild(b);
				
				if (completeHandler != null)
					completeHandler();
				
				unregisterAnimation(animationName);
			};
		}
		
		/**
		 * Check if fall is needed, and start fall animation
		 */
		private function processFall():void
		{
			if (fieldIsEmpty())
			{
				setWin(true);
				return;
			}
			
			if ((_shootCtr % Game.FALL_STEP) == 0)
			{
				// time to fall
				
				registerAnimation("fall");
				var tween:Tween;
				
				for (var hy:int = 0; hy < _field.length; hy++)
				{
					var line:Vector.<Bubble> = _field[hy];
					var lineIsEmpty:Boolean = true;
					
					for (var hx:int = 0; hx < line.length; hx++)
					{
						var bubble:Bubble = line[hx];
						if (bubble)
						{
							var pos:Point = _grid.getHexMiddlePoint(new Hex(hx, hy + 2));
							tween = new Tween(bubble, 0.5, Transitions.EASE_IN);
							tween.moveTo(pos.x, pos.y);
							Starling.juggler.add(tween);
							
							lineIsEmpty = false;
						}
					}
					
					if (lineIsEmpty)
					{
						var rest:int = _field.length - (hy + 1);
						if (rest > 0)
						{
							_field.splice(hy, rest);
							break;
						}
					}
				}
				
				if (tween)
					tween.onComplete = insertNewBubbles;
				else
					unregisterAnimation("fall");
			}
		}
		
		/**
		 * Insert two lines in begin of field
		 */
		private function insertNewBubbles():void
		{
			registerAnimation("incoming");
			unregisterAnimation("fall");
			
			var tween:Tween;
			for (var i:int = 1; i >= 0; i--)
			{
				var bubbleLine:Vector.<Bubble> = new Vector.<Bubble>();
				fillLine(bubbleLine, i);
				
				for each(var bubble:Bubble in bubbleLine)
				{
					if (!bubble)
						continue;
					
					bubble.scaleX = 0.1;
					bubble.scaleY = 0.1;
					
					tween = new Tween(bubble, 0.5, Transitions.EASE_OUT_BACK);
					tween.scaleTo(1.0);
					Starling.juggler.add(tween);
				}
				
				_field.unshift(bubbleLine);
			}
			
			if (tween)
			{
				tween.onComplete = function():void {
					unregisterAnimation("incoming");
					checkForFail();
				};
			}
			else
			{
				unregisterAnimation("incoming");
			}
		}
		
		/**
		 * Check for user is loose
		 */
		private function checkForFail():void
		{
			if (_field.length >= _lastLine)
				setGameOver(true);
		}
	}
}