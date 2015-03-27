package 
{   
	import loom2d.display.Image;
//TODO_AHMED: Is this better implemented as an abstract class?
	// This interface describes a slide to be used in a slideshow. Each slide should have an easing in animation and an easing out animation.
    public interface ISlide extends Image
    {
        function easeIn():void  
		function easeOut():void
		
		// We want slides to be able to report whether they've been loaded into memory or not
		function isLoadedInMemory():Boolean
		function setLoadedInMemory(loadedState:Boolean):void
    }
}