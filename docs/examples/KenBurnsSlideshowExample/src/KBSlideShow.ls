package
{
	import loom2d.display.DisplayObject;
	import loom2d.display.Image;
	import loom2d.display.Sprite;
	import loom2d.math.Point;
	import loom2d.textures.Texture;
	import loom2d.events.Event;
	import loom2d.Loom2D;
    import loom2d.animation.Tween;
	
	import KBSlide;
	import KBSlideEffect;
	

    //class that manages showing images with a "Ken Burns Slideshow Effect"
	public class KBSlideShow extends Sprite
	{
		// The total amount of images there are in the slideshow
		private var totalImageNumber = 0;

		// The number of images that we'll load into memory at once, less than or equal to 0 = load all of the images
		private var imageBufferSize = 0;

		private var currentImagePrefix:String = "";
		private var currentImageExtension:String = "";
		private var currentSlideIndex = -1;
        private var _startOnAdd:Boolean = false;
		
		// A flag signaling that we're waiting for a new slide texture to load from memory before we can transition to the next slide
        private var previousSlideEffect:KBSlideEffect = KBSlideEffect.NumEffects;
		private var slides:Dictionary.<String, KBSlide>;


        //constructor
		public function KBSlideShow(imagePrefix:String, 
                                    slideWidth:int,
                                    slideHeight:int,
                                    totalImageCount:Number, 
                                    imageBufferLength:Number = 3, 
                                    imageExtension:String = ".jpg",
                                    slideDuration:Number = 5.0,
                                    slideFadeInTime:Number = 0.5,
                                    slideFadeOutTime:Number = 0.1,
                                    slideMaxDist:Number = 1.0,
                                    slideZoomIn:Number = 2.0,
                                    slideZoomOut:Number = 0.5,
                                    startOnAdd:Boolean = true)
		{
			slides = new Dictionary.<String, KBSlide>();
			totalImageNumber = totalImageCount;
            _startOnAdd = startOnAdd;
			
			// <= 0 means load all of the images (clamp to min of 3 ortotalImageCount)
			imageBufferSize = (imageBufferLength <= 0) ? totalImageCount : imageBufferLength;
            imageBufferSize = Math.max(imageBufferSize, Math.min(totalImageCount, 3));
			currentImagePrefix = imagePrefix;
			currentImageExtension = imageExtension;
			
			// Create dictionary entries for every image we can possibly load
			for (var i = 0; i < totalImageNumber; i++)
			{
                var slideName:String = getSliderName(imagePrefix, imageExtension, i);
				slides[slideName] = new KBSlide(slideWidth,
                                                slideHeight,
                                                slideDuration, 
                                                slideFadeInTime, 
                                                slideFadeOutTime, 
                                                slideMaxDist, 
                                                slideZoomIn, 
                                                slideZoomOut);
			}
			
			// Load the initial slides once this object is added to the stage
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);	
		}


        //dispose the slides correctly
        override public function dispose():void
        {
            //dipose our images and textures
            for each(var slide:KBSlide in slides)
            {
                slide.dispose();
            }

            super.dispose();
        }


        //create all slides when the slideshow is added to the scene
		private function onAddedToStage(event:Event)
		{
			// Only load the amount of textures specified by the buffer number
			for (var i = 0; i < imageBufferSize; i++)
			{
                var texName:String = getSliderName(currentImagePrefix, currentImageExtension, i);
                slides[texName].initialize(Texture.fromAsset(texName), this);
			}

            //start on add?
            if(_startOnAdd)
            {
                nextSlide(KBSlideEffect.NumEffects);
            }
		}


        //wrapper to get a full slide name
        private function getSliderName(prefix:String, ext:String, idx:int):String
        {
            return currentImagePrefix + idx.toFixed(0) + currentImageExtension;
        }
		

		// Used to index the dictionary
		private function slideIndexToKey(index:Number):String
		{
            return getSliderName(currentImagePrefix, currentImageExtension, index);
		}
		

        //callback that handles initializing the slide once its texture has completed loading
		private function onTextureLoaded(tex:Texture):void
		{
			// texture for the slide was sucessfully loaded
            slides[tex.assetPath].initialize(tex, this);
		}


        //request transition to the next slide
		public function nextSlide(effect:KBSlideEffect)
		{
            //random effect?
            if(effect == KBSlideEffect.NumEffects)
            {
                //never choose same effect as previous one!            
                do
                {
                    effect = Random.randRangeInt(0, KBSlideEffect.NumEffects-1);
                }while(effect == previousSlideEffect);
            }
            previousSlideEffect = effect;

            //get our new slide
            var newSlideIndex:int = (currentSlideIndex + 1) % totalImageNumber;
            var newSlideTex:String = slideIndexToKey(newSlideIndex);
            var newSlide:KBSlide = slides[newSlideTex];
trace("---new slide: " + newSlideIndex);                    

            //handle buffering if we have enough of a buffer to work with
            if(totalImageNumber > 3)
            {
                //unload the previous slide
                var deadSlideIndex:int = (currentSlideIndex - 1) % totalImageNumber;
                var deadSlide:KBSlide = slides[slideIndexToKey(deadSlideIndex)];
                if (deadSlide.LoadedInMemory) 
                {
trace("---kill slide: " + deadSlideIndex);                    
                    deadSlide.texture.dispose();
                    deadSlide.LoadedInMemory = false;
                    removeChild(deadSlide, false);
                }

                //pre-load another slide at the end of the buffer if necessary
                var bufferSlideIndex:int = (currentSlideIndex - 1 + imageBufferSize) % totalImageNumber;
                var bufferSlideTex:String = slideIndexToKey(bufferSlideIndex);
                var bufferSlide:KBSlide = slides[bufferSlideTex];
                if (!bufferSlide.LoadedInMemory) 
                {
trace("---buffer slide: " + bufferSlideIndex);                    
                    Texture.fromAssetAsync(bufferSlideTex, onTextureLoaded, false); 
                }
            }

			//start showing the next slide
			currentSlideIndex = (currentSlideIndex + 1) % totalImageNumber;			
			var tweenIn:Tween = slides[slideIndexToKey(currentSlideIndex)].startEffect(effect);	

            //when we complete this tween, go to the next slide automatically!
            tweenIn.onComplete = nextSlide;
            tweenIn.onCompleteArgs = [KBSlideEffect.NumEffects];
		}
    }
}