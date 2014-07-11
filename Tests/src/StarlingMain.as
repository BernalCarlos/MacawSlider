package
{
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.extensions.macawslider.MacawSlider;

	public class StarlingMain extends Sprite
	{
		private var _macawSlider: MacawSlider;
		
		public function StarlingMain()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage($event: Event): void{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			_macawSlider = new MacawSlider(stage.stageWidth, stage.stageHeight);
			_macawSlider.addItemFromUrl('http://blog.jimdo.com/wp-content/uploads/2014/01/tree-247122.jpg');
			_macawSlider.addItemFromUrl('http://www.picturesnew.com/media/images/images-background.jpg');
			_macawSlider.addItemFromUrl('http://static.ddmcdn.com/gif/storymaker-best-hubble-space-telescope-images-20092-514x268.jpg');
			_macawSlider.addItemFromUrl('http://blog.gettyimages.com/wp-content/uploads/2012/10/81076116-Chip-Somodevilla-Getty-Images-e1351541533518.jpg');
			_macawSlider.addItemFromUrl('http://ichef.bbci.co.uk/wwfeatures/624_351/images/live/p0/1p/5y/p01p5ygs.jpg');
			_macawSlider.addItemFromUrl('http://wpmedia.o.canada.com/2014/04/528968726.jpg');
			_macawSlider.addItemFromUrl('http://www.eyeopening.info/wp-content/uploads/2014/02/powerful-photos-13.jpg');
			_macawSlider.isVerticalSlider = false;
			_macawSlider.wrapSlider = true;
			
			this.addChild(_macawSlider);
			_macawSlider.initialize();
		}
	}
}