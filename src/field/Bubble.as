package field 
{
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	/**
	 * Bubble
	 * @author jvirkovskiy
	 */
	public class Bubble extends Sprite 
	{
		//------------------------
		//
		//------------------------
		
		private var _color:uint;
		
		//------------------------
		//
		//------------------------
		
		/**
		 * Constructor
		 * @param	color	the color of bubble
		 */
		public function Bubble(color:uint) 
		{
			super();
			_color = color;
			
			var image:Image = new Image(Texture.fromBitmapData(Dummy.getBall(_color, Game.BALL_SIZE)));
			image.x = -Game.BALL_SIZE / 2.0;
			image.y = -Game.BALL_SIZE / 2.0;
			
			addChild(image);
		}
		
		/**
		 * Color of bubble
		 */
		public function get color():uint
		{
			return _color;
		}
	}
}