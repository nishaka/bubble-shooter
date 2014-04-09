package field 
{
	/**
	 * Hexagon coordinate
	 * @author jvirkovskiy
	 */
	public class Hex 
	{
		//------------------------
		//
		//------------------------
		
		public var x:int;
		public var y:int;
		
		//------------------------
		//
		//------------------------
		
		/**
		 * Consctructor
		 * @param	x	horizontal position of hexagon
		 * @param	y	vertical position of hexagon
		 */
		public function Hex(x:int=0, y:int=0) 
		{
			this.x = x;
			this.y = y;
		}
		
		/**
		 * Check for hexagons equivalency
		 * @param	hex	compared hexagon
		 * @return true, if hexagons are equal
		 */
		public function isEqual(hex:Hex):Boolean
		{
			return x == hex.x && y == hex.y;
		}
		
		/**
		 * Get clone of this hexagon
		 * @return	clone object
		 */
		public function clone():Hex
		{
			return new Hex(x, y);
		}
	}
}