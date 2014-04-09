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
	}
}