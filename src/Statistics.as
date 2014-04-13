package  
{
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.layout.VerticalLayout;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import feathers.core.PopUpManager;
	/**
	 * Game statistics
	 * @author jvirkovskiy
	 */
	public class Statistics extends Sprite
	{
		//------------------------
		//
		//------------------------
		
		private static var WINDOW_WIDTH:Number = 180.0;
		private static var WINDOW_HEIGHT:Number = 190.0;
		
		private var _labels:Vector.<Label>;
		
		private var _results:Array = [];
		
		//------------------------
		//
		//------------------------
		
		/**
		 * Constructor
		 */
		public function Statistics() 
		{
			super();
			
			var back:Quad = new Quad(WINDOW_WIDTH, WINDOW_HEIGHT, 0x000000);
			addChild(back);
			
			back = new Quad(WINDOW_WIDTH - 2.0, WINDOW_HEIGHT - 2.0, 0xf0f0f0);
			back.x = 1.0;
			back.y = 1.0;
			addChild(back);
			
			var group:LayoutGroup = new LayoutGroup();
			group.width = WINDOW_WIDTH;
			group.height = WINDOW_HEIGHT;
			
			var layout:VerticalLayout = new VerticalLayout();
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			layout.paddingTop = 10.0;
			layout.gap = 15.0;
			
			group.layout = layout;
			
			var labelGroup:LayoutGroup = new LayoutGroup();
			var labelLayout:VerticalLayout = new VerticalLayout();
			labelLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			labelGroup.layout = labelLayout;
			
			_labels = new Vector.<Label>();
			for (var i:int = 0; i < 10; i++)
			{
				var label:Label = new Label();
				label.text = "---";
				_labels.push(label);
				
				labelGroup.addChild(label);
			}
			
			validateLabels();
			group.addChild(labelGroup);
			
			var button:Button = new Button();
			button.label = "Ok";
			button.addEventListener(Event.TRIGGERED, onOkHandler);
			group.addChild(button);
			
			addChild(group);
			
		}
		
		/**
		 * Ok button pressed
		 * @param	event	event
		 */
		private function onOkHandler(event:Event):void
		{
			PopUpManager.removePopUp(this);
		}
		
		/**
		 * Add new score
		 * @param	shoots			number of shoots
		 * @param	removedBubbles	number of total removed bubbles
		 */
		public function setScore(shoots:int, removedBubbles:int):void
		{
			_results.unshift( { shoots: shoots, removed: removedBubbles } );
			validateLabels();
		}
		
		/**
		 * Helper for fill labels with actual data
		 */
		private function validateLabels():void
		{
			if (_labels)
			{
				for (var i:int = 0; i < _labels.length; i++)
				{
					if (i < _results.length)
						_labels[i].text = _results[i].removed + " / " + _results[i].shoots;
					else
						break;
				}
			}
		}
	}
}