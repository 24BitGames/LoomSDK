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
        NumEffects
    }

	
	// This slide uses the Ken Burns effect (http://en.wikipedia.org/wiki/Ken_Burns_effect) which eases in using a pan and zoom at the same time
	public class KBSlide extends Image
	{
        private var _width:int;
        private var _height:int;
        private var _duration:Number = 5.0;
		private var _fadeInTime:Number = 0.5;
		private var _fadeOutTime:Number = 0.2;		
        private var _maxSlideAmount:Number = 1.0;
        private var _zoomInWeight:Number = -1.0;
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
                                life:Number = 5.0, 
                                fadeIn:Number = 0.5, 
                                fadeOut:Number = 0.1,
                                maxDistance:Number = 50,
                                zoomInWeight:Number = 0.5,
                                maxZoomIn:Number = 2.0,
                                maxZoomOut:Number = 0.5)
		{
            //start with 'empty' texture
			super(null);
            _width = slideWidth;
            _height = slideHeight;

            LoadedInMemory = false;
            _duration = life;
			_fadeInTime = fadeIn;
			_fadeOutTime = fadeOut;
            _maxSlideAmount = maxDistance;
            _zoomInWeight = zoomInWeight;
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
		public function startEffect(effect:KBSlideEffect):Tween
		{
			var effectTween:Tween = new Tween(this, _duration, Transitions.LINEAR);
			
            //reset position & scale
            x = _startingPosition.x;
            y = _startingPosition.y;
            scale = 1.0;

            //figure out our effect tween target(s)
            var targetX:Number = x;
            var targetY:Number = y;
            var targetScale:Number = scale;
			switch (effect)
			{
				case KBSlideEffect.North:
                    targetY = y + _maxSlideY;
					break;
				case KBSlideEffect.South:
					targetY = y - _maxSlideY;
					break;
                case KBSlideEffect.East:
                    targetX = x - _maxSlideX;
                    break;
				case KBSlideEffect.West:
					targetX = x + _maxSlideX;
					break;
                case KBSlideEffect.NorthEast:
                    targetX = x + _maxSlideX;
                    targetY = y + _maxSlideY;
                    break;
                case KBSlideEffect.SouthEast:
                    targetX = x - _maxSlideX;
                    targetY = y - _maxSlideY;
                    break;
				case KBSlideEffect.SouthWest:
					targetX = x + _maxSlideX;
                    targetY = y - _maxSlideY;
					break;
                case KBSlideEffect.NorthWest:
                    targetX = x - _maxSlideX;
                    targetY = y + _maxSlideY;
                    break;
			}			

            //add zoom based on the weight (<.0.0 weight means don't scale at all)
            if(_zoomInWeight >= 0.0)
            {
                targetScale = (Random.rand() < _zoomInWeight) ? _maxZoomIn : _maxZoomOut;
            }

            //add the slide effect tween
            effectTween.moveTo(targetX, targetY);
            effectTween.scaleTo(targetScale);
			Loom2D.juggler.add(effectTween);	

            //prep the fade out tween now and set it to fire at the end of the movement effect tween
            var outTween:Tween = new Tween(this, _fadeOutTime, Transitions.LINEAR);
            outTween.fadeTo(0.0);
            effectTween.nextTween = outTween;

            //add separate tween for the fade in
            var inTween:Tween = new Tween(this, _fadeInTime, Transitions.LINEAR);
            inTween.fadeTo(1.0);
            Loom2D.juggler.add(inTween);  

            return effectTween;
		}    
	}
}