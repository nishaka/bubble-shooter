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
		
		private var _hexHighlightLayer:Image;
		private var _highlightedHex:Hex;
		
		private var _quadWidth:Number;		// quad grid cell width
		private var _quadHeight:Number;		// quad grid cell height
		
		private var _cellWidth:Number;		// width of one hexagon cell
		private var _cellHeight:Number;		// height of one hexagon cell
		
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
			
			_hexHighlightLayer = new Image(Texture.fromBitmapData(Dummy.getHexagon(hexSideSize, 0xffffff, 0.1)));
			_hexHighlightLayer.visible = false;
			addChild(_hexHighlightLayer);
			
			_gridLayer = new Image(Texture.fromBitmapData(Dummy.getHexGrid(hexWidth, hexHeight, hexSideSize, 0x000000, 0.15)));
			addChild(_gridLayer);
			
			_quadWidth = hexSideSize * 0.866;
			_quadHeight = hexSideSize + hexSideSize / 2;
			
			_cellWidth = _quadWidth * 2;
			_cellHeight = _l * 2;
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
		
		/**
		 * Highlight specified hexagon
		 * @param	hex	hexagon to highlighted
		 */
		public function highlightHex(hex:Hex):void
		{
			if (hex)
			{
				if (_highlightedHex && _highlightedHex.isEqual(hex))
					return;
				
				_highlightedHex = hex.clone();
				
				var pos:Point = getHexPos(_highlightedHex);
				_hexHighlightLayer.x = pos.x;
				_hexHighlightLayer.y = pos.y;
				
				_hexHighlightLayer.visible = true;
			}
			else
			{
				_hexHighlightLayer.visible = false;
			}
		}
		
		/**
		 * Get hexagon position
		 * @param	hex	hexagon
		 * @return	position of top left of hexagon
		 */
		public function getHexPos(hex:Hex):Point
		{
			var px:Number = hex.y % 2 ? hex.x * _cellWidth : hex.x * _cellWidth - _quadWidth;
			var py:Number = hex.y * _quadHeight - _l / 2;
			return new Point(px, py);
		}
		
		/**
		 * Get hexagon center point
		 * @param	hex	hexagon
		 * @return	position of center point of hexagon
		 */
		public function getHexMiddlePoint(hex:Hex):Point
		{
			var pos:Point = getHexPos(hex);
			pos.offset(_quadWidth, _l);
			return pos;
		}
	}
}