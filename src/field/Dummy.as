package field 
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	/**
	 * Helper static class for creating dummy objects
	 * @author jvirkovskiy
	 */
	public class Dummy 
	{
		//------------------------
		//
		//------------------------
		
		/**
		 * Create image of hexagonal grid
		 * @param	w	width in hexes
		 * @param	h	height in hexes
		 * @param	l	side size
		 * @return	created grid bitmap data
		 */
		public static function getHexGrid(w:int, h:int, l:Number,
										  lineColor:uint = 0x000000, lineAlpha:Number = 1.0,
										  backColor:uint=0xfffffff, backAlpha:Number=0.0):BitmapData
		{
			var canvas:Sprite = new Sprite();
			
			var hl:Number = l * 0.866;		// difference between side height and whole hexagoh height divided by two
			var dh:Number = l / 2.0;		// hex middle x position
			var hw:Number = hl * 2;			// hexagon width
			
			var width:Number = hl * 2 * w - hl;
			var height:Number = (l + dh) * h;
			
			canvas.graphics.beginFill(backColor, backAlpha);
			canvas.graphics.drawRect(0, 0, width, height);
			canvas.graphics.endFill();
			
			canvas.graphics.lineStyle(1.0, lineColor, lineAlpha);
			
			var top:Number = 0;
			for (var i:int = 0; i < h; i++)
			{
				var startPos:Number;
				var from:int, to:int;
				if (i % 2)
				{
					startPos = 0.0;
					from = 0;
					to = w;
				}
				else
				{
					startPos = -hl;
					from = 1;
					to = w + 1;
					
					canvas.graphics.moveTo(0, top + l + dh);
					canvas.graphics.lineTo(hl, top + l);
				}
				
				for (var j:int = from; j < to; j++)
				{
					canvas.graphics.moveTo(startPos + hw * j, top);
					canvas.graphics.lineTo(startPos + hw * j, top + l);
					canvas.graphics.lineTo(startPos + hw * j + hl, top + l + dh);
					canvas.graphics.lineTo(startPos + hw * j + hw, top + l);
				}
				
				top += l + dh;
			}
			
			canvas.graphics.lineStyle();
			
			var res:BitmapData = new BitmapData(Math.min(width, 2048), Math.min(height, 2048), true, 0x00000000);
			res.draw(canvas, null, null, null, null, true);
			return res;
		}
		
		//------------------------
		//
		//------------------------
		
		public function Dummy() 
		{
		}
	}
}