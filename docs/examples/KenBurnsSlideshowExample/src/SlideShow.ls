package
{
	import loom2d.display.DisplayObject;
	import loom2d.display.Image;
	import loom2d.display.Sprite;
	import loom2d.math.Point;
	import loom2d.textures.Texture;
	import loom2d.events.Event;
	import loom2d.Loom2D;
	
	import KenBurnsSlide;
	import KBSlideDirection;
	
	public class SlideShow extends Sprite
	{
		// The total amount of images there are in the slideshow
		private var totalImageNumber = 0;
		// The number of images that we'll load into memory at once, less than or equal to 0 = load all of the images
		private var imageBufferSize = 0;
		private var currentImagePrefix:String = "";
		private var currentImageExtension:String = "";
		private var currentSlideIndex = 0;
		
		// A flag signaling that we're waiting for a new slide texture to load from memory before we can transition to the next slide
		private var slideLoadRequested:Boolean;
		
		public var slides:Dictionary.<String, ISlide>;
		public var sliderImages:Vector.<ISlide>;
		
		public function SlideShow(imagePrefix:String = "", imageExtension:String = ".jpg", totalImageCount:Number = 0, imageBufferLength:Number = 0)
		{
			slides = new Dictionary.<String, ISlide>();
			sliderImages = new Vector.<KenBurnsSlide>();
			totalImageNumber = totalImageCount;
			
			// <= 0 means load all of the images
			if (imageBufferLength <= 0)
			{
				imageBufferSize = totalImageCount;
			}
			else
			{
				imageBufferSize = imageBufferLength;
			}
			
			currentImagePrefix = imagePrefix;
			currentImageExtension = imageExtension;
			
			// Create dictionary entries for every image we can possibly load
			for (var i = 0; i < totalImageNumber; i++)
			{
				slides["assets/slideShow/" + imagePrefix + i.toFixed(0) + imageExtension] = new KenBurnsSlide(null, 5, 2);	
			}
			
			// Load the initial slides once this object is added to the stage
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);	
		}
		
		private function onAddedToStage(event:Event)
		{
			// Only load the amount of textures specified by the buffer number
			for (var i = 0; i < imageBufferSize; i++)
			{
				var currentSlidePath = "assets/slideShow/" + currentImagePrefix + i.toFixed(0) + currentImageExtension;
				slides[currentSlidePath].texture = Texture.fromAsset(currentSlidePath);	
				slides[currentSlidePath].setLoadedInMemory(true);
							
				slides[currentSlidePath].width = stage.stageWidth * 2;
				slides[currentSlidePath].height = stage.stageHeight * 2;
				
				slides[currentSlidePath].center();
				slides[currentSlidePath].x = stage.stageWidth / 2;
				slides[currentSlidePath].y = stage.stageHeight / 2;
				
				if (slides[currentSlidePath] is KenBurnsSlide)
				{
					KenBurnsSlide(slides[currentSlidePath]).startingPosition = new Point(stage.stageWidth / 2, stage.stageHeight / 2);
					KenBurnsSlide(slides[currentSlidePath]).startingScale = slides[currentSlidePath].scale;
				}
				
				slides[currentSlidePath].alpha = 0;
				
				// We only want to add the slide as a child once, onTextureLoaded can be called many times
				if (getChildIndex(slides[currentSlidePath]) < 0)
				{
					addChild(slides[currentSlidePath]);
				}
			}	
		}
		
		// Used to index the dictionary
		private function slideIndexToKey(index:Number):String
		{
			return "assets/slideShow/" + currentImagePrefix + index.toFixed(0) + currentImageExtension;
		}
		
		private function onTextureLoaded(p0:Texture):void
		{
			// Slide was sucessfully loaded
			slides[p0.assetPath].setLoadedInMemory(true);
			slides[p0.assetPath].texture = p0;
						
			slides[p0.assetPath].width = stage.stageWidth * 2;
			slides[p0.assetPath].height = stage.stageHeight * 2;
			
			slides[p0.assetPath].center();
			slides[p0.assetPath].x = stage.stageWidth / 2;
			slides[p0.assetPath].y = stage.stageHeight / 2;
			
			if (slides[p0.assetPath] is KenBurnsSlide)
			{
				KenBurnsSlide(slides[p0.assetPath]).startingPosition = new Point(stage.stageWidth / 2, stage.stageHeight / 2);
				KenBurnsSlide(slides[p0.assetPath]).startingScale = slides[p0.assetPath].scale;
			}
			
			slides[p0.assetPath].alpha = 0;
			
			// We only want to add the slide as a child once, onTextureLoaded can be called many times
			if (getChildIndex(slides[p0.assetPath]) < 0)
			{
				addChild(slides[p0.assetPath]);
			}
			
			if (slideLoadRequested)
			{
				slideLoadRequested = false;
				nextSlide();
			}
		}
		
		public function loadImages(imagePrefix:String = "tex_", imageExtension:String = ".jpg", imageCount:Number = 0)
		{			
			for (var i = 0; i < imageCount; i++)
			{
				var sliderImage = new KenBurnsSlide(Texture.fromAsset("assets/slideShow/" + imagePrefix + i.toFixed(0) + imageExtension), 5, 2);
				sliderImages.pushSingle(sliderImage);
			}	
		}
		
		public function nextSlide()
		{
			// First check if the next slide is loaded, if it isn't, request it
			if (!slides[ slideIndexToKey((currentSlideIndex + 1) % totalImageNumber) ].isLoadedInMemory()) 
			{
				slideLoadRequested = true;
				
				// Load the requested slide into memory
				Texture.fromAssetAsync(slideIndexToKey((currentSlideIndex + 1) % totalImageNumber), onTextureLoaded, false); 
//TODO_AHMED: Check this logic
				// Unload the slide at the back of the loading queue, but only if we're not going to wrap around
				// i.e we have slides 0, 1, 2. We've loaded 0 and 1. Now want to load 2, we load it. BUT the next slide after 2 is 0
				// which means we want to unload 2 and load 0! No Bueno
				if (currentSlideIndex + 1 != totalImageNumber - 1)
				{
					slides[slideIndexToKey((currentSlideIndex + 1) % totalImageNumber - imageBufferSize)].texture.dispose();
					slides[slideIndexToKey((currentSlideIndex + 1) % totalImageNumber - imageBufferSize)].setLoadedInMemory(false);
				}
				
				// Early exit from this function. When the texture load completes, this function will be called again, except with isLoadedInMemory set to true
				return;
			}
			
			Loom2D.juggler.removeTweens(slides[slideIndexToKey(currentSlideIndex)]);
			slides[slideIndexToKey(currentSlideIndex)].easeOut();
			
			// Make the slider index point to the next slide and wrap it around the max index
			currentSlideIndex = (currentSlideIndex + 1) % totalImageNumber;
			
			slides[slideIndexToKey(currentSlideIndex)].easeIn();	
		}
		
		public function randomSlide()
		{
			Loom2D.juggler.removeTweens(slides[slideIndexToKey(currentSlideIndex)]);
			slides[slideIndexToKey(currentSlideIndex)].easeOut();
			
			// Make the slider index point to a random slide and wrap it around the max index
			currentSlideIndex = Random.randRangeInt(0, sliderImages.length);
			
			slides[slideIndexToKey(currentSlideIndex)].easeIn();	
		}
		
		public function setSlidingDirection(direction:KBSlideDirection)
		{
			for (var i = 0; i < totalImageNumber; i++)
			{
				if (slides[slideIndexToKey(i)] is KenBurnsSlide)
				{
					KenBurnsSlide(slides[slideIndexToKey(i)]).slideDirection = direction;
				}
			}
		}
	}
}