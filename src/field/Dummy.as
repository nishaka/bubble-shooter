package field 
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import starling.display.Image;
	import starling.textures.Texture;
	
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
										  lineColor:uint=0x000000, lineAlpha:Number=1.0,
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
		
		/**
		 * Create a hexagon
		 * @param	l			hexagon side size
		 * @param	hexColor	hexagon color
		 * @param	hexAlpha	hexagon alpha
		 * @return	created hexagon bitmap data
		 */
		public static function getHexagon(l:Number, hexColor:uint = 0xffffff, hexAlpha:Number = 1.0):BitmapData
		{
			var hl:Number = l * 0.866;		// difference between side height and whole hexagoh height divided by two
			var dh:Number = l / 2.0;		// hex middle x position
			
			var canvas:Sprite = new Sprite();
			
			canvas.graphics.beginFill(hexColor, hexAlpha);
			canvas.graphics.moveTo(hl, 0);
			canvas.graphics.lineTo(hl * 2, dh);
			canvas.graphics.lineTo(hl * 2, dh + l);
			canvas.graphics.lineTo(hl, l * 2);
			canvas.graphics.lineTo(0, dh + l);
			canvas.graphics.lineTo(0, dh);
			
			var res:BitmapData = new BitmapData(Math.ceil(canvas.width), Math.ceil(canvas.height), true, 0x00000000);
			res.draw(canvas, null, null, null, null, true);
			return res;
		}
		
		/**
		 * Create color ball
		 * @param	color	color
		 * @return	Starling sprite of ball with zero point in the middle
		 */
		public static function getBall(color:uint):starling.display.Sprite
		{
			var canvas:Sprite = new Sprite();
			
			canvas.graphics.beginFill(color);
			canvas.graphics.drawEllipse(0, 0, Game.BALL_SIZE, Game.BALL_SIZE);
			canvas.graphics.endFill();
			
			var bitmapData:BitmapData = new BitmapData(Math.ceil(canvas.width), Math.ceil(canvas.height), true, 0x00000000);
			bitmapData.draw(canvas, null, null, null, null, true);
			
			var image:Image = new Image(Texture.fromBitmapData(bitmapData));
			image.x = -Game.BALL_SIZE / 2.0;
			image.y = -Game.BALL_SIZE / 2.0;
			
			var res:starling.display.Sprite = new starling.display.Sprite();
			res.addChild(image);
			return res;
		}
		
		/**
		 * Create arrow to point shut directuin
		 * @param	color		color of arrow
		 * @param	borderColor	color of arrow border
		 * @param	showBorder	with or without border
		 * @return	Starling sprite of arrow with zero point in rotate axis
		 */
		public static function getArrow(color:uint, borderColor:uint=0x000000,
										showBorder:Boolean=true, size:Number=7.0):starling.display.Sprite
		{
			var canvas:Sprite = new Sprite();
			const vertices:Vector.<Point> = new <Point>[
				new Point(2.0, 0.0), new Point(4.0, 6.0), new Point(3.0, 6.0),
				new Point(3.0, 16.0), new Point(1.0, 16.0), new Point(1.0, 6.0), new Point(0.0, 6.0) ];
			
			if (showBorder)
				canvas.graphics.lineStyle(1.0, borderColor);
			
			canvas.graphics.beginFill(color);
			canvas.graphics.moveTo(vertices[0].x * size + 1, vertices[0].y * size)
			for (var i:int = 1; i < vertices.length; i++)
				canvas.graphics.lineTo(vertices[i].x * size + 1, vertices[i].y * size);
			canvas.graphics.endFill();
			
			if (showBorder)
				canvas.graphics.lineStyle();
			
			var bitmapData:BitmapData = new BitmapData(Math.ceil(canvas.width) + 2, Math.ceil(canvas.height), true, 0x00000000);
			bitmapData.draw(canvas, null, null, null, null, true);
			
			var image:Image = new Image(Texture.fromBitmapData(bitmapData));
			image.x = -canvas.width / 2.0;
			image.y = -20.0 * size;
			
			var res:starling.display.Sprite = new starling.display.Sprite();
			res.addChild(image);
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