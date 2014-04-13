package field 
{
	import flash.geom.Point;
	/**
	 * Box with bubbles
	 * @author jvirkovskiy
	 */
	public class Box 
	{
		//------------------------
		//
		//------------------------
		
		private var _leftBorder:Number;
		private var _rightBorder:Number;
		private var _topBorder:Number;
		private var _bottomBorder:Number;
		
		//------------------------
		//
		//------------------------
		
		/**
		 * Constructor
		 * @param	left	left border
		 * @param	right	right border
		 * @param	top		top border
		 * @param	bottom	bottom border
		 */
		public function Box(left:Number, right:Number, top:Number, bottom:Number) 
		{
			_leftBorder = left;
			_rightBorder = right;
			_topBorder = top;
			_bottomBorder = bottom;
		}
		
		/**
		 * Left border
		 */
		public function get left():Number
		{
			return _leftBorder;
		}
		
		/**
		 * Right border
		 */
		public function get right():Number
		{
			return _rightBorder;
		}
		
		/**
		 * Top border
		 */
		public function get top():Number
		{
			return _topBorder;
		}
		
		/**
		 * Left border
		 */
		public function get bottom():Number
		{
			return _bottomBorder;
		}
		
		/**
		 * Return path of bubble started from start point to target point
		 * with all reflections from the box sides
		 * @param	startPoint	start point
		 * @param	targetPoint	target point
		 * @return	vertices of bubble path
		 */
		public function getPath(startPoint:Point, targetPoint:Point):Vector.<Point>
		{
			var minOffset:Number = startPoint.y - (startPoint.x - _leftBorder) * Math.tan(Game.SHOOT_ANG_LIMIT);
			
			var path:Vector.<Point> = new Vector.<Point>();
			
			path.push(startPoint.clone());
			
			var ang:Number = Math.atan2(startPoint.y - targetPoint.y, startPoint.x - targetPoint.x);
			
			// Prevent "deadlocks"
			if (ang < Game.SHOOT_ANG_LIMIT && targetPoint.x < startPoint.x)
			{
				ang = Game.SHOOT_ANG_LIMIT;
				targetPoint.x = _leftBorder;
				targetPoint.y = minOffset;
			}
			else if (ang < 0 || ang > Math.PI - Game.SHOOT_ANG_LIMIT)
			{
				ang = Math.PI - Game.SHOOT_ANG_LIMIT;
				targetPoint.x = _rightBorder;
				targetPoint.y = minOffset;
			}
			
			// Calculate ball path
			var currentCuePos:Point = startPoint.clone();
			
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
					if (py > minOffset) py = minOffset;
					
					targetPoint.x = _rightBorder;
					targetPoint.y = py - (_rightBorder - _leftBorder) * dy / dx;
				}
				else if (ang > reflectionMaxAng)
				{
					// Reflect from right border
					px = _rightBorder;
					py = currentCuePos.y + (_rightBorder - currentCuePos.x) * dy / dx;
					if (py > minOffset) py = minOffset;
					
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
			
			return path;
		}
	}

}