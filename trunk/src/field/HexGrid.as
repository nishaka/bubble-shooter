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
		
		private static const oddOffsets:Vector.<Hex> = new <Hex>[ new Hex(0, -1), new Hex(1, -1), new Hex(1, 0), new Hex(1, 1), new Hex(0, 1), new Hex(-1, 0) ];
		private static const evenOffsets:Vector.<Hex> = new <Hex>[ new Hex(-1, -1), new Hex(0, -1), new Hex(1, 0), new Hex(0, 1), new Hex(-1, 1), new Hex(-1, 0) ];
		
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
			else if (_hexHighlightLayer.visible)
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
		
		/**
		 * Get the neighbour hexagons for specified cell
		 * @param	hex	cell
		 * @return	list of cell neighbours
		 */
		public function getNeighbours(hex:Hex):Vector.<Hex>
		{
			var res:Vector.<Hex> = new Vector.<Hex>();
			var offsets:Vector.<Hex> = hex.y % 2 ? oddOffsets : evenOffsets;
			
			for each (var offset:Hex in offsets)
			{
				var hx:int = hex.x + offset.x;
				var hy:int = hex.y + offset.y;
				
				if (hx >= 0 && hx < _hexWidth && hy >= 0 && hy < _hexHeight)
					res.push(new Hex(hx, hy));
			}
			
			return res;
		}
		
		/**
		 * Check, if hexagons are neighbours
		 * @param	hex1	first hexagon
		 * @param	hex2	second hexagon
		 * @return	true, if hexagons are neighbours
		 */
		public function isNeighbours(hex1:Hex, hex2:Hex):Boolean
		{
			var offsets:Vector.<Hex> = hex1.y % 2 ? oddOffsets : evenOffsets;
			
			for each (var offset:Hex in offsets)
			{
				if (hex1.x + offset.x == hex2.x && hex1.y + offset.y == hex2.y)
					return true;
			}
			
			return false;
		}
	}
}