package
{
	import loom2d.display.Image;
	import loom2d.textures.Texture;
	
	import loom2d.animation.Tween;
	import loom2d.animation.Transitions;
	import loom2d.Loom2D;
	import loom2d.animation.Juggler;
	
	import loom2d.math.Point;
	
	public enum KBSlideDirection {UP, DOWN, LEFT, RIGHT, UPRIGHT, UPLEFT, DOWNRIGHT, DOWNLEFT, ZOOMIN, ZOOMOUT}
	
	// This slide uses the Ken Burns effect (http://en.wikipedia.org/wiki/Ken_Burns_effect) which eases in using a pan and zoom at the same time
	public class KenBurnsSlide extends Image implements ISlide
	{
		private var loadedInMemory:Boolean = false;
		
		public var easeInTime = 2;
		public var easeOutTime = 1;
		
		public var slideDirection:KBSlideDirection = KBSlideDirection.DOWNRIGHT;
		public var slidingDistance = 60;
		public var zoomAmount = 0.1;
		public var startingPosition:Point;
		public var startingScale:Number = 1;
		
		public function KenBurnsSlide(texture:Texture, easeInDuration:Number = 2, easeOutDuration:Number = 0.2, directionToSlide:KBSlideDirection = KBSlideDirection.DOWNRIGHT)
		{
			super(texture);
			easeInTime = easeInDuration;
			easeOutTime = easeOutDuration;
			
			slideDirection = directionToSlide;	
		}
		
		public function easeIn():void
		{
			var tween:Tween = new Tween(this, easeInTime, Transitions.EASE_OUT);
			
			switch (slideDirection)
			{
				case KBSlideDirection.UP:
				{
					x = startingPosition.x;
					y = startingPosition.y;
					scale = startingScale;
					tween.moveTo(0, startingPosition.y + slidingDistance);
					break;
				}
				case KBSlideDirection.DOWN:
				{
					x = startingPosition.x;
					y = startingPosition.y;
					scale = startingScale;
					tween.moveTo(0, startingPosition.y - slidingDistance);
					break;
				}
				case KBSlideDirection.LEFT:
				{
					x = startingPosition.x;
					y = startingPosition.y;
					scale = startingScale;
					tween.moveTo(startingPosition.x + slidingDistance, 0);
					break;
				}
				case KBSlideDirection.RIGHT:
				{
					x = startingPosition.x;
					y = startingPosition.y;
					scale = startingScale;
					tween.moveTo(startingPosition.x - slidingDistance, 0);
					break;
				}
				case KBSlideDirection.UPLEFT:
				{
					x = startingPosition.x;
					y = startingPosition.y;
					scale = startingScale;
					tween.moveTo(startingPosition.x - slidingDistance, startingPosition.y + slidingDistance);
					break;
				}
				case KBSlideDirection.UPRIGHT:
				{
					x = startingPosition.x;
					y = startingPosition.y;
					scale = startingScale;
					tween.moveTo(startingPosition.x + slidingDistance, startingPosition.y + slidingDistance);
					break;
				}
				case KBSlideDirection.DOWNLEFT:
				{
					x = startingPosition.x;
					y = startingPosition.y;
					scale = startingScale;
					tween.moveTo(startingPosition.x + slidingDistance, startingPosition.y - slidingDistance);
					break;
				}
				case KBSlideDirection.DOWNRIGHT:
				{
					x = startingPosition.x;
					y = startingPosition.y;
					scale = startingScale;
					tween.moveTo(startingPosition.x - slidingDistance, startingPosition.y - slidingDistance);
					break;
				}
				case KBSlideDirection.ZOOMIN:
				{
					x = startingPosition.x;
					y = startingPosition.y;
					scale = startingScale;
					trace(startingScale);
					tween.scaleTo(0.4);
					break;
				}
				case KBSlideDirection.ZOOMOUT:
				{
					x = startingPosition.x;
					y = startingPosition.y;
					scale = startingScale;
					tween.scaleTo(0.9);
					break;
				}
			}
			
			tween.fadeTo(1);
			Loom2D.juggler.add(tween);	
		}
		 		
		public function easeOut()
		{
			var tween:Tween = new Tween(this, easeOutTime, Transitions.EASE_OUT);
			tween.fadeTo(0);
			Loom2D.juggler.add(tween);		
		}
		
		public function isLoadedInMemory():Boolean
		{
			return loadedInMemory;
		}
		
		public function setLoadedInMemory(loadedState:Boolean):void
		{
			loadedInMemory = loadedState;
		}
	}
}