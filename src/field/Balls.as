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
			
			_lastLine = hexHeight - 3;
			
			init();
		}
		
		/**
		 * Initialize field
		 */
		private function init():void
		{
			var pos:Point = _grid.getHexMiddlePoint(new Hex(0, _lastLine));
			_cueStartPos = new Point(_grid.width / 2, pos.y);
			
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
			
		}
	}
}