package field 
{
	import flash.geom.Point;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	/**
	 * Display and manage point coordinates for hexagonal sprite
	 * @author jvirkovskiy
	 */
	public class HexGrid extends Sprite 
	{
		//------------------------
		//
		//------------------------
		
		private var _hexWidth:int;
		private var _hexHeight:int;
		
		private var _l:Number;
		
		private var _gridLayer:Image;
		
		private var _quadWidth:Number;		// quad grid cell width
		private var _quadHeight:Number;		// quad grid cell height
		
		//------------------------
		//
		//------------------------
		
		/**
		 * Constructor
		 * @param	hexWidth	width of grid in hexagons
		 * @param	hexHeight	height of grid in hexagons
		 * @param	hexSideSize	size of hexagon side
		 */
		public function HexGrid(hexWidth:int, hexHeight:int, hexSideSize:Number) 
		{
			super();
			
			_hexWidth = hexWidth;
			_hexHeight = hexHeight;
			_l = hexSideSize;
			
			_gridLayer = new Image(Texture.fromBitmapData(Dummy.getHexGrid(hexWidth, hexHeight, hexSideSize, 0x000000, 0.15)));
			addChild(_gridLayer);
			
			_quadWidth = hexSideSize * 0.866;
			_quadHeight = hexSideSize + hexSideSize / 2;
		}
		
		/**
		 * Get hexagon in the specified coordinates
		 * @param	pos	coordinates
		 * @return	hexagon in specified coordinates
		 */
		public function getHex(pos:Point):Hex
		{
			var quadX:int = pos.x / _quadWidth;
			var quadY:int = pos.y / _quadHeight;
			
			var offsetX:Number = pos.x - _quadWidth * quadX;
			var offsetY:Number = pos.y - _quadHeight * quadY;
			
			var hx:int, hy:int;
			if (quadY % 2)
			{
				hx = quadX / 2;
				
				if (quadX % 2)
				{
					if (offsetY > _l + _l / 2.0 - (_l / 2.0) / (_l * 0.866) * offsetX)
					{
						hy =  quadY + 1;
						hx += 1;
					}
					else
					{
						hy = quadY;
					}
				}
				else
				{
					if (offsetY > _l + (_l / 2.0) / (_l * 0.866) * offsetX)
					{
						hy = quadY + 1;
					}
					else
					{
						hy = quadY;
					}
				}
			}
			else
			{
				hx = (quadX + 1) / 2;
				
				if (quadX % 2)
				{
					if (offsetY > _l + (_l / 2.0) / (_l * 0.866) * offsetX)
					{
						hy = quadY + 1;
						hx -= 1;
					}
					else
					{
						hy = quadY;
					}
				}
				else
				{
					if (offsetY > _l + _l / 2.0 - (_l / 2.0) / (_l * 0.866) * offsetX)
					{
						hy = quadY + 1;
					}
					else
					{
						hy = quadY;
					}
				}
			}
			
			return new Hex(hx, hy);
		}
	}
}