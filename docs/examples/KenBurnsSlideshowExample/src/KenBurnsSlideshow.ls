package
{
    import loom.Application;
    import loom2d.display.StageScaleMode;

	import KBSlideShow;
	
	import loom2d.events.KeyboardEvent;
	import loom.platform.LoomKey;
    import loom.platform.Mobile;

	import KBSlideEffect;



    public class KenBurnsSlideshow extends Application
    {	
		var slideShow:KBSlideShow;
		var slideDirectionIndex = 0;
		
        override public function run():void
        {
            Mobile.allowScreenSleep(false);

			// Comment out this line to turn off automatic scaling.
            stage.scaleMode = StageScaleMode.LETTERBOX;
			
            //create and add(start) the slideshow
            var slideWidth:int = stage.stageWidth * 1.5;
            var slideHeight:int = stage.stageHeight * 1.5;
			slideShow = new KBSlideShow("assets/slideshow1/lobby_", 
                                        slideWidth, 
                                        slideHeight, 
                                        15, 5,          //num images in the sequence, num images loaded in memory at once
                                        ".jpg", 
                                        5, 0.3, 0.6,    //slide duration, fade in time, fade out time
                                        0.35, 1.2, 0.9,  //max move %, max zoom in %, max zoom out %
                                        true);
			stage.addChild(slideShow);
        }
    }
}