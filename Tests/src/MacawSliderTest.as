package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import starling.core.Starling;
	
	[SWF(width="500", height="300", frameRate="60")]
	public class MacawSliderTest extends Sprite
	{
		private var _starling: Starling;
		
		public function MacawSliderTest()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
		}
		
		private function onAddedToStage($event: Event): void{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			_starling = new Starling(StarlingMain, this.stage, new Rectangle(0, 0, stage.stageWidth, stage.stageHeight), null, 'auto', 'auto');
			_starling.showStats = true;
			_starling.antiAliasing = 1;
			_starling.start();
		}
	}
}