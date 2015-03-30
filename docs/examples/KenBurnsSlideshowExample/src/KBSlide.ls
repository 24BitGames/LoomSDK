package
{
    import loom2d.display.DisplayObjectContainer;
	import loom2d.display.Image;
	import loom2d.textures.Texture;
	
	import loom2d.animation.Tween;
	import loom2d.animation.Transitions;
	import loom2d.Loom2D;
	import loom2d.animation.Juggler;
	
	import loom2d.math.Point;
	

    //enum for the various Ken Burns slide transition effects
	public enum KBSlideEffect 
    {
        North, 
        South, 
        East, 
        West, 
        NorthEast, 
        SouthEast, 
        SouthWest, 
        NorthWest, 
        ZoomIn, 
        ZoomOut,
        NumEffects
    }

	
	// This slide uses the Ken Burns effect (http://en.wikipedia.org/wiki/Ken_Burns_effect) which eases in using a pan and zoom at the same time
	public class KBSlide extends Image
	{
        private var _width:int;
        private var _height:int;
		private var _easeInTime = 2;
		private var _easeOutTime = 1;		
        private var _maxSlideAmount = 1.0;
        private var _maxZoomIn:Number = 2.0;
        private var _maxZoomOut:Number = 0.5;
        private var _maxSlideX:Number = 0.0;
        private var _maxSlideY:Number = 0.0;

        private var _loadedInMemory:Boolean = false;
        
        //values to reset the slide to when it starts to ease in
		private var _startingPosition:Point;
		

        public function get LoadedInMemory():Boolean { return _loadedInMemory; }
        public function set LoadedInMemory(value:Boolean) { _loadedInMemory = value; }



        //constructor
		public function KBSlide(slideWidth:int,
                                slideHeight:int,
                                easeIn:Number = 2, 
                                easeOut:Number = 0.2,
                                maxDistance:Number = 50,
                                maxZoomIn:Number = 2.0,
                                maxZoomOut:Number = 0.5)
		{
            //start with 'empty' texture
			super(null);
            _width = slideWidth;
            _height = slideHeight;

            LoadedInMemory = false;
			_easeInTime = easeIn;
			_easeOutTime = easeOut;
            _maxSlideAmount = maxDistance;
            _maxZoomIn = maxZoomIn;
            _maxZoomOut = maxZoomOut;            
		}


        //initializes the slide with the given texture
        public function initialize(tex:Texture, parent:DisplayObjectContainer):void
        {
            texture = tex;
            LoadedInMemory = true;
            
            //adjust image size and positioning for the new texture
            setSize(_width, _height);
            x = _width / 2 / (_width / parent.stage.stageWidth);
            y = _height / 2 / (_height / parent.stage.stageHeight);
            center();
            alpha = 0;
            
            //clamp zoom out so that the image edges can never be seen
            var largestScale:Number = Math.max(parent.stage.stageWidth / _width, parent.stage.stageHeight / _height);
            _maxZoomOut = Math.max(_maxZoomOut, largestScale);

            //clamp slide distance so that the image edges can never be seen
            _maxSlideX = ((_width - parent.stage.stageWidth) / 2) * _maxSlideAmount;
            _maxSlideY = ((_height - parent.stage.stageHeight) / 2) * _maxSlideAmount;
    
            _startingPosition = new Point(x, y);
            
            // We only want to add the slide as a child once
            if (parent.getChildIndex(this) < 0)
            {
                parent.addChild(this);
            }
        }    


        //handle disposing of the slide's texture properly
        override public function dispose():void
        {
            //destroy our texture if it is loaded
            if(LoadedInMemory)
            {
                texture.dispose();
            }

            //dipose the Image
            super.dispose();
        }     
		

        //start easing in the slide
		public function easeIn(effect:KBSlideEffect):Tween
		{
			var tween:Tween = new Tween(this, _easeInTime, Transitions.EASE_OUT);
			
            //reset position & scale
            x = _startingPosition.x;
            y = _startingPosition.y;
            scale = 1.0;

			switch (effect)
			{
				case KBSlideEffect.North:
					tween.moveTo(x, y + _maxSlideY);
					break;
				case KBSlideEffect.South:
					tween.moveTo(x, y - _maxSlideY);
					break;
                case KBSlideEffect.East:
                    tween.moveTo(x - _maxSlideX, y);
                    break;
				case KBSlideEffect.West:
					tween.moveTo(x + _maxSlideX, y);
					break;
                case KBSlideEffect.NorthEast:
                    tween.moveTo(x + _maxSlideX, y + _maxSlideY);
                    break;
                case KBSlideEffect.SouthEast:
                    tween.moveTo(x - _maxSlideX, y - _maxSlideY);
                    break;
				case KBSlideEffect.SouthWest:
					tween.moveTo(x + _maxSlideX, y - _maxSlideY);
					break;
                case KBSlideEffect.NorthWest:
                    tween.moveTo(x - _maxSlideX, y + _maxSlideY);
                    break;
				case KBSlideEffect.ZoomIn:
					tween.scaleTo(_maxZoomIn);
					break;
				case KBSlideEffect.ZoomOut:
					tween.scaleTo(_maxZoomOut);
					break;
                    default:
			}
			
			tween.fadeTo(1.0);
			Loom2D.juggler.add(tween);	
            return tween;
		}
		 		

        //start easing out the slide
		public function easeOut():Tween
		{
            //kill any existing tweens on us
            Loom2D.juggler.removeTweens(this);

            ///tween out!
			var tween:Tween = new Tween(this, _easeOutTime, Transitions.EASE_OUT);
			tween.fadeTo(0.0);
			Loom2D.juggler.add(tween);	

            return tween;
		}      
	}
}