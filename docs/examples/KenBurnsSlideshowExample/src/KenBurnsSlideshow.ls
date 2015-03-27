package
{
    import loom.Application;
    import loom2d.display.StageScaleMode;

	import SlideShow;
	
	import loom2d.events.KeyboardEvent;
	import loom.platform.LoomKey;
	import KBSlideDirection;

    public class KenBurnsSlideshow extends Application
    {	
		var slideShow:SlideShow;
		var slideDirectionIndex = 0;
		
        override public function run():void
        {
			// Comment out this line to turn off automatic scaling.
            stage.scaleMode = StageScaleMode.LETTERBOX;
			
			slideShow = new SlideShow("tex_", ".jpg", 4, 3);
			
			stage.addChild(slideShow);
			//slideShow.nextSlide();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        }
		
		function onKeyDown(event:KeyboardEvent)
		{
			if (event.keyCode == LoomKey.RIGHT_ARROW)
			{
				slideShow.nextSlide();
			}
			
			if (event.keyCode == LoomKey.SPACEBAR)
			{
				slideDirectionIndex = (slideDirectionIndex + 1) % 10;
				
				switch (slideDirectionIndex)
				{
					case 0: slideShow.setSlidingDirection(KBSlideDirection.DOWN); slideShow.nextSlide(); break;
					case 1: slideShow.setSlidingDirection(KBSlideDirection.DOWNLEFT); slideShow.nextSlide(); break;
					case 2: slideShow.setSlidingDirection(KBSlideDirection.DOWNRIGHT); slideShow.nextSlide(); break;
					case 3: slideShow.setSlidingDirection(KBSlideDirection.LEFT); slideShow.nextSlide(); break;
					case 4: slideShow.setSlidingDirection(KBSlideDirection.RIGHT); slideShow.nextSlide(); break;
					case 5: slideShow.setSlidingDirection(KBSlideDirection.UP); slideShow.nextSlide(); break;
					case 6: slideShow.setSlidingDirection(KBSlideDirection.UPLEFT); slideShow.nextSlide(); break;
					case 7: slideShow.setSlidingDirection(KBSlideDirection.UPRIGHT); slideShow.nextSlide(); break;
					case 8: slideShow.setSlidingDirection(KBSlideDirection.ZOOMIN); slideShow.nextSlide(); break;
					case 9: slideShow.setSlidingDirection(KBSlideDirection.ZOOMOUT); slideShow.nextSlide(); break;
				}
			}
		}
    }
}