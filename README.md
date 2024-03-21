# SlideShow

This is a basic UDF to create customizable slide shows from images.

![An example of slide show.](/assets/slideshow.png)[^1]

Available functions in this UDF:
* _GUICtrlSlideshow_Create
* _GUICtrlSlideshow_Delete
* _GUICtrlSlideshow_ShowSlide
* _GUICtrlSlideshow_ButtonEvent
* _GUICtrlSlideshow_KeyEvent

# No preloaded images
If you don't want the images to be preloaded, just use **SlideshowEx.au3** and the images will be dinamically created. Using this extended library ***ImageType*** option is not available anymore but ***$avImage*** parameter can be a mixed array with local file paths, URLs or raw binary data.

> [!NOTE]
> Each function from SlideShow.au3 have a comment header where parameters and return codes are described.

> [!IMPORTANT]
> Call _GDIPlus_Startup() before using any function from this UDF and _GDIPlus_Shutdown() after you properly deleted all controls created with this UDF and there is no further need of any function from this UDF.

> [!TIP]
> If you have questions or if you need support for this UDF please visit AutoIt forum and post your questions [in this thread](https://www.autoitscript.com/forum/topic/211445-slideshow-udf/).

[^1]: Sources for pictures and data are from google.com and wikipedia.com
