#include-once
#include <GDIPlus.au3>

; ===============================================================================================================================================================
;   Title: Slideshow UDF
;   AutoIt Version : 3.3.16.1
;   Description: Slideshow control.
;   Author: Andreik
;   Dependencies: GDI+
;   Call _GDIPlus_Startup() before using any function from this UDF and _GDIPlus_Shutdown() after you properly deleted all controls created with this UDF
;   and there is no further need of any function from this UDF.
;   URL: https://www.autoitscript.com/forum/topic/211445-slideshow-udf/
;   Special thanks to UEZ (https://www.autoitscript.com/forum/profile/29844-uez/) for slides transition idea and sample code.
; ===============================================================================================================================================================

; #CURRENT# =====================================================================================================================================================
;   _GUICtrlSlideshow_Create
;   _GUICtrlSlideshow_Delete
;   _GUICtrlSlideshow_ShowSlide
;   _GUICtrlSlideshow_ButtonEvent
;   _GUICtrlSlideshow_KeyEvent
; ===============================================================================================================================================================

; #CONSTANTS# ===================================================================================================================================================
Global Enum $SLIDESHOW_PREV_BTN, $SLIDESHOW_NEXT_BTN
Global Enum $BTN_EVENT_PREV, $BTN_EVENT_NEXT
; ===============================================================================================================================================================

; #GLOBAL SETTINGS# =============================================================================================================================================
Global $__mSlideshows[]
$__mSlideshows['Count'] = 0         ; For internal use - DO NOT CHANGE!!!
$__mSlideshows['Refresh'] = 1000    ; Minimum refresh rate
$__mSlideshows['EventsRate'] = 250  ; Minimum interval between mouse events
$__mSlideshows['Max'] = 3           ; Maximum numbers of controls. You can increase this but the performance will decrease
                                    ; if there are too many slideshows
; ===============================================================================================================================================================

; #FUNCTION# ====================================================================================================================================================
; Name:         _GUICtrlSlideshow_Create
; Description:  Creates a slideshow control.
; Syntax:       _GUICtrlSlideshow_Create($hGUI, $iX, $iY, $iWidth, $iHeight, $avImage [, $mOptions = Null])
; Parameters:   $hGUI - The handle of the parent window.
;               $iX - Position of the left side of the control.
;               $iY - Position of the top side of the control.
;               $iW - The width of the control.
;               $iH - The height of the control.
;               $avImage - An array that contains the images for the slideshow. Each element of this array contains a slide image. This can be an array of local file paths, URLs
;                          or raw binary data but can't be mixed data. If the array contains URLs or raw binary data then ImageType must to be set as option.
;               $mOptions - [Optional] - A map with all customisable properties (each property it's a key).
;                 Available properties:
;                    * ImageType - load images from $avImage by their type. Can be set as Local, URL or Binary [Default: Local]
;                    * Delay - delay between slides transitions. This value cannot be less than global refresh rate [Default: 3000 ms]
;                    * Autoplay - automatically change slides after {Delay} ms. This value must be True or False [Default: True]
;                    * PlayDirection - Direction of transitions. When this value is True the transition is from left to right and when it's False from right to left [Default: True]
;                    * ErrorFont - Font name for slides with no images [Default: Segoe UI]
;                    * ErrorFontSize - Font size of text for slides with no images [Default: 15]
;                    * ErrorBkColor - Background color for slides with no images in AARRGGBB format [Default: 0xFFD0CECE]
;                    * ErrorColor - Text color for slides with no images in AARRGGBB format [Default: 0xFF595959]
;                    * CornerRadius - Radius of each corner of the slides. Set this at value 1 for rectangular slides [Default: 10]
;                    * ShowSlides - Show slides indicators in the top part of the slideshow control [Default: True]
;                    * SlidesSpace - Space between slides indicators in pixels [Default: 10]
;                    * SlideHeight - Height of the slides indicators in pixels [Default: 3]
;                    * SlideColor - Color of the slides indicators in AARRGGBB format [Default: 0x80FFFFFF]
;                    * SlideActive - Color of the active slide indicator in AARRGGBB format [Default: 0xFFFFFFFF]
;                    * ShowButtons - Display control buttons. If {AutoPlay} is False then this setting is automatically set to True[Default: True]
;                    * ButtonsPosition - Sets position of control buttons. Can be set as left, center or right [Default: right]
;                    * ButtonsSize - Buttons size in pixels. Maximum available size is 60px [Default: 40]
;                    * ButtonsColor - Background color of the buttons in AARRGGBB format [Default: 0xD0000000]
;                    * ButtonsGlyphColor - Glyphs color of the buttons in AARRGGBB format [Default: 0xFFFFFFFF]
;                    * ButtonsLineWidth - Glyphs line with of the buttons [Default: 2]
;                    * ShowCaptions - Display captions for slides. If this is set as True then {Captions} must be an array with the same size as $avImage [Default: False]
;                    * Captions - An array of the same size as $avImage that contains captions for each slide.
;                    * CaptionsFont - Font name used for captions [Default: Segoe UI]
;                    * CaptionsFontSize - Font size used for captions [Default: 12]
;                    * CaptionsFontStyle - Font style used for captions. This can be a combination of these values: 0 - Normal, 1 - Bold, 2 - Italic, 4 - Underline, 8 - Strikethrough [Default: 0]
;                    * CaptionsTextColor - Text color used for captions [Default: 0xFFFFFFFF]
;                    * Transition - Enable or disable transitions between slides change slides. This value must be True or False [Default: True]
;                    * TransitionFrames - Number of frames between transitions [Default: 40]
;                    * EnableKeys - Enable keyboard support to change slides. This value must be True or False [Default: True]
;                    * Keys - It's a map with two mandatory keys [Prev and Next] and their paired values are virtual-key code. This property must be set if EnableKeys is set to True.
;                             For a list of available codes please check _IsPressed() documentation in help file.
; Return value:  Success - Returns a map with all properties and settings.
;                Failure - Returns Null.
;                    @error = 1 - $avImage is not an array
;                    @error = 2 - $avImage is an empty array
;                    @error = 3 - $mOptions is not a map
;                    @error = 4 - Maximum limit of controls has been reached
;                    @error = 5 - Captions are enabled but no captions has been provided
;                    @error = 6 - Mismatch between slides and captions
;                    @error = 7 - Keys are not a map or Prev/Next entries are not defined
;                       @extended = 1 - Invalid keys map
;                       @extended = 2 - Prev key it's not defined
;                       @extended = 3 - Next key it's not defined
; Author:        Andreik
; Remarks:       When a slideshow control is not needed anymore, use _GUICtrlSlideshow_Delete() to release the resources.
; ===============================================================================================================================================================
Func _GUICtrlSlideshow_Create($hGUI, $iX, $iY, $iWidth, $iHeight, $avImage, $mOptions = Null)
  If Not IsArray($avImage) Then Return SetError(1, 0, Null)
  Local $iCount = UBound($avImage)
  If $iCount = 0 Then Return SetError(2, 0, Null)
  If $mOptions <> Null And Not IsMap($mOptions) Then Return SetError(3, 0, Null)
  If MapExists($__mSlideshows, $__mSlideshows['Max']) Then Return SetError(4, 0, Null)

  Local $iImageType = (MapExists($mOptions, 'ImageType') ? $mOptions['ImageType'] : 'Local')
  Local $iDelay = (MapExists($mOptions, 'Delay') ? $mOptions['Delay'] : 3000)
  Local $fTransition = (MapExists($mOptions, 'Transition') ? $mOptions['Transition'] : True)
  Local $iTransitionFrames = (MapExists($mOptions, 'TransitionFrames') ? $mOptions['TransitionFrames'] : 40)
  Local $fAutoPlay = (MapExists($mOptions, 'Autoplay') ? $mOptions['Autoplay'] : True)
  Local $fPlayDirection = (MapExists($mOptions, 'PlayDirection') ? $mOptions['PlayDirection'] : True)
  Local $sErrorFont = (MapExists($mOptions, 'ErrorFont') ? $mOptions['ErrorFont'] : 'Segoe UI')
  Local $iErrorFontSize = (MapExists($mOptions, 'ErrorFontSize') ? $mOptions['ErrorFontSize'] : 15)
  Local $iErrorBkColor = (MapExists($mOptions, 'ErrorBkColor') ? $mOptions['ErrorBkColor'] : 0xFFD0CECE)
  Local $iErrorColor = (MapExists($mOptions, 'ErrorColor') ? $mOptions['ErrorColor'] : 0xFF595959)
  Local $iRadius = (MapExists($mOptions, 'CornerRadius') ? $mOptions['CornerRadius'] : 10)
  Local $fShowSlides = (MapExists($mOptions, 'ShowSlides') ? $mOptions['ShowSlides'] : True)
  Local $iSlidesSpace = (MapExists($mOptions, 'SlidesSpace') ? $mOptions['SlidesSpace'] : 10)
  Local $iSlideHeight = (MapExists($mOptions, 'SlideHeight') ? $mOptions['SlideHeight'] : 3)
  Local $iSlideColor = (MapExists($mOptions, 'SlideColor') ? $mOptions['SlideColor'] : 0x80FFFFFF)
  Local $iSlideActive = (MapExists($mOptions, 'SlideActive') ? $mOptions['SlideActive'] : 0xFFFFFFFF)
  Local $fShowButtons = (MapExists($mOptions, 'ShowButtons') ? $mOptions['ShowButtons'] : True)
  Local $sButtonsPosition = (MapExists($mOptions, 'ButtonsPosition') ? $mOptions['ButtonsPosition'] : 'right')
  Local $iButtonsSize = (MapExists($mOptions, 'ButtonsSize') ? $mOptions['ButtonsSize'] : 40)
  Local $iButtonsColor = (MapExists($mOptions, 'ButtonsColor') ? $mOptions['ButtonsColor'] : 0xD0000000)
  Local $iButtonsGlyphColor = (MapExists($mOptions, 'ButtonsGlyphColor') ? $mOptions['ButtonsGlyphColor'] : 0xFFFFFFFF)
  Local $iButtonsLineWidth = (MapExists($mOptions, 'ButtonsLineWidth') ? $mOptions['ButtonsLineWidth'] : 2)
  Local $fCaptions = (MapExists($mOptions, 'ShowCaptions') ? $mOptions['ShowCaptions'] : False)
  Local $asCaptions = (MapExists($mOptions, 'Captions') ? $mOptions['Captions'] : Null)
  Local $sCaptionsFont = (MapExists($mOptions, 'CaptionsFont') ? $mOptions['CaptionsFont'] : 'Segoe UI')
  Local $iCaptionsFontSize = (MapExists($mOptions, 'CaptionsFontSize') ? $mOptions['CaptionsFontSize'] : 12)
  Local $iCaptionsFontStyle = (MapExists($mOptions, 'CaptionsFontStyle') ? $mOptions['CaptionsFontStyle'] : 0)
  Local $iCaptionsTextColor = (MapExists($mOptions, 'CaptionsTextColor') ? $mOptions['CaptionsTextColor'] : 0xFFFFFFFF)
  Local $fKeys = (MapExists($mOptions, 'EnableKeys') ? $mOptions['EnableKeys'] : False)
  Local $mKeys = (MapExists($mOptions, 'Keys') ? $mOptions['Keys'] : Null)

  If $fCaptions Then
    If Not IsArray($asCaptions) Then Return SetError(5, 0, Null)
    If $iCount <> UBound($asCaptions) Then Return SetError(6, 0, Null)
  EndIf

  If $fKeys Then
    If Not IsMap($mKeys) Then Return SetError(7, 1, Null)
    If Not MapExists($mKeys, 'Prev') Then Return SetError(7, 2, Null)
    If Not MapExists($mKeys, 'Next') Then Return SetError(7, 3, Null)
  EndIf

  Switch $iImageType
    Case 'Local'
      __GetLocalImages($avImage, $iCount, $iWidth, $iHeight)
    Case 'URL'
      __GetImagesFromResource($avImage, $iCount, $iWidth, $iHeight, True)
    Case 'Binary'
      __GetImagesFromResource($avImage, $iCount, $iWidth, $iHeight, False)
  EndSwitch

  Local $mSlideshow[]
  $mSlideshow['GUI'] = $hGUI
  $mSlideshow['Images'] = $avImage
  $mSlideshow['Index'] = 0
  $mSlideshow['PrevIndex'] = 0
  $mSlideshow['Count'] = $iCount
  $mSlideshow['Width'] = $iWidth
  $mSlideshow['Height'] = $iHeight
  $mSlideshow['Radius'] = $iRadius
  $mSlideshow['Delay'] = ($iDelay < $__mSlideshows['Refresh'] ? $__mSlideshows['Refresh'] : $iDelay)
  $mSlideshow['Transition'] = ($fTransition ? True : False)
  $mSlideshow['TransitionFrames'] = $iTransitionFrames
  $mSlideshow['NoImage'] = __NoImage($iWidth, $iHeight, $iErrorBkColor, $iErrorColor, $sErrorFont, $iErrorFontSize)
  $mSlideshow['Ctrl'] = GUICtrlCreatePic('', $iX, $iY, $iWidth, $iHeight, ($iRadius > 0 ? Default : 0x1000))  ; $SS_SUNKEN
  $mSlideshow['ShowSlides'] = $fShowSlides
  $mSlideshow['SlidesSpace'] = $iSlidesSpace
  $mSlideshow['SlideWidth'] = Int(($iWidth - (($iCount + 1) * $mSlideshow['SlidesSpace'])) / $iCount)
  $mSlideshow['SlideHeight'] = $iSlideHeight
  $mSlideshow['SlideColor'] = $iSlideColor
  $mSlideshow['SlideActive'] = $iSlideActive
  $mSlideshow['ShowButtons'] = ($fAutoPlay ? $fShowButtons : True)
  $mSlideshow['ButtonsPosition'] = $sButtonsPosition
  $mSlideshow['ButtonsSize'] = ($iButtonsSize > 60 ? 60 : $iButtonsSize)
  $mSlideshow['ButtonsColor'] = $iButtonsColor
  $mSlideshow['ButtonsGlyphColor'] = $iButtonsGlyphColor
  $mSlideshow['ButtonsLineWidth'] = $iButtonsLineWidth
  $mSlideshow['ShowCaptions'] = $fCaptions
  $mSlideshow['Captions'] = $asCaptions
  $mSlideshow['CaptionsFont'] = $sCaptionsFont
  $mSlideshow['CaptionsFontStyle'] = $iCaptionsFontStyle
  $mSlideshow['CaptionsFontSize'] = $iCaptionsFontSize
  $mSlideshow['CaptionsTextColor'] = $iCaptionsTextColor
  $mSlideshow['Autoplay'] = $fAutoPlay
  $mSlideshow['PlayDirection'] = $fPlayDirection
  $mSlideshow['EnableKeys'] = ($fKeys ? True : False)
  $mSlideshow['Keys'] = $mKeys
  $mSlideshow['User32'] = $fKeys ? DllOpen('user32.dll') : Null
  $mSlideshow['LastUpdate'] = TimerInit()
  $mSlideshow['LastEvent'] = TimerInit()

  $__mSlideshows['Count'] = $__mSlideshows['Count'] + 1
  $mSlideshow['Ref'] = $__mSlideshows['Count']
  $__mSlideshows[$__mSlideshows['Count']] = $mSlideshow

  __Slide($mSlideshow)

  Return $mSlideshow
EndFunc

; #FUNCTION# ====================================================================================================================================================
; Name:           _GUICtrlSlideshow_Delete
; Description:    Deletes a slideshow control.
; Syntax:         _GUICtrlSlideshow_Delete($mSlideshow)
; Parameters:     $mSlideshow - A map variable that represents a slideshow control.
; Return value:   Success - None
;                 Failure - Returns Null.
;                     @error = 1 - $mSlideshow is not a map
; Author:         Andreik
; ===============================================================================================================================================================
Func _GUICtrlSlideshow_Delete(ByRef $mSlideshow)
  Local $nIndex, $mNew
  If Not IsMap($mSlideshow) Then Return SetError(1, 0, Null)
  Local $ahImage = $mSlideshow['Images']
  For $nIndex = 0 To $mSlideshow['Count'] - 1
    If $ahImage[$nIndex] <> Null Then _GDIPlus_BitmapDispose($ahImage[$nIndex])
  Next
  _GDIPlus_BitmapDispose($mSlideshow['NoImage'])
  GUICtrlDelete($mSlideshow['Ctrl'])
  If $mSlideshow['EnableKeys'] Then DllClose($mSlideshow['User32'])
  For $nIndex = $mSlideshow['Ref'] + 1 To $__mSlideshows['Count']
    $mNew = $__mSlideshows[$nIndex]
    $mNew['Ref'] = $nIndex - 1
    $__mSlideshows[$nIndex - 1] = $mNew
  Next
  MapRemove($__mSlideshows, $__mSlideshows['Count'])
  $__mSlideshows['Count'] -= 1
  If $__mSlideshows['Count'] = 0 Then AdlibUnRegister('__Slideshow_Proc')
EndFunc

; #FUNCTION# ====================================================================================================================================================
; Name:           _GUICtrlSlideshow_ShowSlide
; Description:    Shows previous or next slide based on an event.
; Syntax:         _GUICtrlSlideshow_ShowSlide($mSlideshow, $iEvent)
; Parameters:     $mSlideshow - A map variable that represents a slideshow control.
;                 $iEvent - An event. Can be one of the following $BTN_EVENT_PREV or $BTN_EVENT_NEXT
; Return value:   Success - True
;                 Failure - False
; Author:         Andreik
; ===============================================================================================================================================================
Func _GUICtrlSlideshow_ShowSlide($mSlideshow, $iEvent)
  If Not IsMap($mSlideshow) Then Return False
  If $iEvent = $BTN_EVENT_PREV Or $iEvent = $BTN_EVENT_NEXT Then __Slide($mSlideshow, $iEvent)
  Return True
EndFunc

; #FUNCTION# ====================================================================================================================================================
; Name:           _GUICtrlSlideshow_ButtonEvent
; Description:    Check if a certain button from a slideshow has been clicked.
; Syntax:         _GUICtrlSlideshow_ButtonEvent($mSlideshow, $iSlideshowBtn)
; Parameters:     $mSlideshow - A map variable that represents a slideshow control.
;                 $iSlideshowBtn - A constant that represents the expected event. This can be set as $SLIDESHOW_PREV_BTN or $SLIDESHOW_NEXT_BTN
; Return value:   Success - True
;                 Failure - False
; Author:         Andreik
; ===============================================================================================================================================================
Func _GUICtrlSlideshow_ButtonEvent(ByRef $mSlideshow, $iSlideshowBtn)
  If Not IsMap($mSlideshow) Then Return False
  If TimerDiff($mSlideshow['LastEvent']) < $__mSlideshows['EventsRate'] Then Return False
  If WinActive($mSlideshow['GUI']) Then
    Local $aInfo = GUIGetCursorInfo($mSlideshow['GUI'])
    If @error Then Return False
    If $aInfo[4] <> $mSlideshow['Ctrl'] Then Return False
    Local $aCtrl = ControlGetPos($mSlideshow['GUI'], '' , $mSlideshow['Ctrl'])
    $aInfo[0] -= $aCtrl[0]
    $aInfo[1] -= $aCtrl[1]
    Local $iButton, $iCircleX, $iCircleY
    Switch $mSlideshow['ButtonsPosition']
      Case 'left'
        $iButton = ($iSlideshowBtn = $SLIDESHOW_PREV_BTN ? 20 :  30 + $mSlideshow['ButtonsSize'])
      Case 'center'
        $iButton = ($iSlideshowBtn = $SLIDESHOW_PREV_BTN ? Int($mSlideshow['Width'] / 2 - $mSlideshow['ButtonsSize'] - 5) : Int($mSlideshow['Width'] / 2 + 5))
      Case 'right'
        $iButton = ($iSlideshowBtn = $SLIDESHOW_PREV_BTN ? $mSlideshow['Width'] - 30 - (2 * $mSlideshow['ButtonsSize']) : $mSlideshow['Width'] - 20 - $mSlideshow['ButtonsSize'])
    EndSwitch
    $iCircleX = Int($iButton + $mSlideshow['ButtonsSize'] / 2)
    $iCircleY = Int($mSlideshow['Height'] - 20 - $mSlideshow['ButtonsSize'] / 2)
    If ($aInfo[0] - $iCircleX) ^ 2 + ($aInfo[1] - $iCircleY) ^ 2 < Int($mSlideshow['ButtonsSize'] / 2) ^ 2 And $aInfo[2] Then
      $mSlideshow['LastEvent'] = TimerInit()
      Return True
    EndIf
  EndIf
  Return False
EndFunc

; #FUNCTION# ====================================================================================================================================================
; Name:           _GUICtrlSlideshow_KeyEvent
; Description:    Check if a key is pressed.
; Syntax:         _GUICtrlSlideshow_KeyEvent($mSlideshow)
; Parameters:     $mSlideshow - A map variable that represents a slideshow control.
; Return value:   Success - True
;                 Failure - False
; Author:         Andreik
; ===============================================================================================================================================================
Func _GUICtrlSlideshow_KeyEvent(ByRef $mSlideshow)
    If Not IsMap($mSlideshow) Then Return False
    If Not $mSlideshow['EnableKeys'] Then Return False
    If Not WinActive($mSlideshow['GUI']) Then Return False
    If TimerDiff($mSlideshow['LastEvent']) < $__mSlideshows['EventsRate'] Then Return False
    Local $mKeys = $mSlideshow['Keys']
    If __Pressed($mKeys['Prev'], $mSlideshow['User32']) Then
        $mSlideshow['LastEvent'] = TimerInit()
        __Slide($mSlideshow, $BTN_EVENT_PREV)
        Return True
    EndIf
    If __Pressed($mKeys['Next'], $mSlideshow['User32']) Then
        $mSlideshow['LastEvent'] = TimerInit()
        __Slide($mSlideshow, $BTN_EVENT_NEXT)
        Return True
    EndIf
EndFunc

; #INTERNAL_USE_ONLY# ; =========================================================================================================================================
;   The following functions are for internal use only and should never be directly called.
; ===============================================================================================================================================================

Func __Slideshow_Proc()
  __Slide()
EndFunc

Func __Slide($mSlideshow = Null, $iEvent = Null)
  AdlibUnRegister('__Slideshow_Proc')
  Local $nSlideshows = $__mSlideshows['Count']
  If $nSlideshows = 0 Then Return
  Local $iStart = ($mSlideshow = Null ? 1 : $mSlideshow['Ref'])
  Local $iStop = ($mSlideshow = Null ? $nSlideshows : $mSlideshow['Ref'])
  Local $mCurrent, $avImage, $hBitmap, $hClone, $hGraphics, $iCount, $hDisplayImage, $hPath, $iWidth, $iHeight, $iRadius
  Local $iPrevButtonPos, $iNextButtonPos, $hPen, $hFontFamily, $hFont, $hFormat, $tRect, $asCaptions, $nSlideStart
  Local $hAttributes, $hTransition, $hTransitionGraphics, $tMatrix
  Local $hBrush = _GDIPlus_BrushCreateSolid()
  Local $hPen = _GDIPlus_PenCreate()
  _GDIPlus_PenSetLineCap($hPen, 2, 2, 2)
  For $nIndex = $iStart To $iStop
    $mCurrent = $__mSlideshows[$nIndex]
    $iCount = $mCurrent['Count']
    If $mSlideshow = Null Then
      If Not $mCurrent['Autoplay'] Then ContinueLoop
      If TimerDiff($mCurrent['LastUpdate']) < $mCurrent['Delay'] Then ContinueLoop
      If $mCurrent['PlayDirection'] Then
        $mCurrent['Index'] = $mCurrent['Index'] + 1 < $iCount ?  $mCurrent['Index'] + 1 : 0
      Else
        $mCurrent['Index'] = $mCurrent['Index'] - 1 < 0 ? $iCount - 1 : $mCurrent['Index'] - 1
      EndIf
    Else
      Switch $iEvent
        Case $BTN_EVENT_PREV
          $mCurrent['Index'] = $mCurrent['Index'] - 1 < 0 ? $iCount - 1 : $mCurrent['Index'] - 1
        Case $BTN_EVENT_NEXT
          $mCurrent['Index'] = $mCurrent['Index'] + 1 < $iCount ?  $mCurrent['Index'] + 1 : 0
      EndSwitch
    EndIf
    $avImage = $mCurrent['Images']
    $iWidth = $mCurrent['Width']
    $iHeight = $mCurrent['Height']
    $iRadius = $mCurrent['Radius']
    $asCaptions = $mCurrent['Captions']
    $hBitmap = $avImage[$mCurrent['Index']]
    $hDisplayImage = _GDIPlus_BitmapCreateFromScan0($iWidth, $iHeight)
    $hClone = _GDIPlus_BitmapCloneArea($hBitmap = Null ? $mCurrent['NoImage'] : $hBitmap, 0, 0, $mCurrent['Width'], $mCurrent['Height'])
    $hGraphics =  _GDIPlus_ImageGetGraphicsContext($hDisplayImage)
    _GDIPlus_GraphicsSetCompositingQuality($hGraphics, $GDIP_COMPOSITINGQUALITY_HIGHQUALITY)
    _GDIPlus_GraphicsSetSmoothingMode($hGraphics, 4)
    _GDIPlus_GraphicsSetPixelOffsetMode($hGraphics, 4)
    If $iRadius > 0 Then
      $hPath = _GDIPlus_PathCreate()
      _GDIPlus_PathAddArc($hPath, $iWidth - $iRadius * 2, 0, $iRadius * 2, $iRadius * 2, 270, 90)
      _GDIPlus_PathAddArc($hPath, $iWidth - $iRadius * 2, $iHeight - $iRadius * 2, $iRadius * 2, $iRadius * 2, 0, 90)
      _GDIPlus_PathAddArc($hPath, 0, $iHeight - $iRadius * 2, $iRadius * 2, $iRadius * 2, 90, 90)
      _GDIPlus_PathAddArc($hPath, 0, 0, $iRadius * 2, $iRadius * 2, 180, 90)
      _GDIPlus_PathCloseFigure($hPath)
      _GDIPlus_GraphicsSetClipPath($hGraphics, $hPath)
    EndIf
    _GDIPlus_GraphicsDrawImageRectRect($hGraphics, $hClone, 0, 0, $iWidth, $iHeight, 0, 0, $iWidth, $iHeight)
    If $mCurrent['ShowSlides'] Then
      For $nSlide = 0 To $iCount - 1
        $nSlideStart = ($nSlide * $mCurrent['SlideWidth']) + ($nSlide * $mCurrent['SlidesSpace']) + $mCurrent['SlidesSpace']
        _GDIPlus_PenSetColor($hPen, $nSlide = $mCurrent['Index'] ? $mCurrent['SlideActive'] : $mCurrent['SlideColor'])
        _GDIPlus_PenSetWidth($hPen, $mCurrent['SlideHeight'])
        _GDIPlus_GraphicsDrawLine($hGraphics, $nSlideStart, 10, $nSlideStart + $mCurrent['SlideWidth'], 10, $hPen)
      Next
    EndIf
    If $mCurrent['ShowCaptions'] Then
      $hFontFamily = _GDIPlus_FontFamilyCreate($mCurrent['CaptionsFont'])
      $hFont = _GDIPlus_FontCreate($hFontFamily, $mCurrent['CaptionsFontSize'], $mCurrent['CaptionsFontStyle'])
      $hFormat = _GDIPlus_StringFormatCreate()
      _GDIPlus_StringFormatSetAlign($hFormat, 0)
      _GDIPlus_StringFormatSetLineAlign($hFormat, 0)
      _GDIPlus_BrushSetSolidColor($hBrush, $mCurrent['CaptionsTextColor'])
      $tRect = _GDIPlus_RectFCreate($mCurrent['SlidesSpace'], $mCurrent['ShowSlides'] ? $mCurrent['SlideHeight'] + 20 : 10, $iWidth - 2 * $mCurrent['SlidesSpace'], 60)
      _GDIPlus_GraphicsDrawStringEx($hGraphics, $asCaptions[$mCurrent['Index']], $hFont, $tRect, $hFormat, $hBrush)
      _GDIPlus_StringFormatDispose($hFormat)
      _GDIPlus_FontDispose($hFont)
      _GDIPlus_FontFamilyDispose($hFontFamily)
    EndIf
    If $mCurrent['ShowButtons'] Then
      Switch $mCurrent['ButtonsPosition']
        Case 'left'
          $iPrevButtonPos = 20
          $iNextButtonPos = 30 + $mCurrent['ButtonsSize']
        Case 'center'
          $iPrevButtonPos = Int($iWidth / 2 - $mCurrent['ButtonsSize'] - 5)
          $iNextButtonPos = Int($iWidth / 2 + 5)
        Case 'right'
          $iPrevButtonPos = $iWidth - 30 - (2 * $mCurrent['ButtonsSize'])
          $iNextButtonPos = $iWidth - 20 - $mCurrent['ButtonsSize']
      EndSwitch
      _GDIPlus_BrushSetSolidColor($hBrush, $mCurrent['ButtonsColor'])
      _GDIPlus_GraphicsFillEllipse($hGraphics, $iPrevButtonPos, $iHeight - $mCurrent['ButtonsSize'] - 20,  $mCurrent['ButtonsSize'], $mCurrent['ButtonsSize'], $hBrush)
      _GDIPlus_GraphicsFillEllipse($hGraphics, $iNextButtonPos, $iHeight - $mCurrent['ButtonsSize'] - 20, $mCurrent['ButtonsSize'], $mCurrent['ButtonsSize'], $hBrush)
      _GDIPlus_PenSetColor($hPen, $mCurrent['ButtonsGlyphColor'])
      _GDIPlus_PenSetWidth($hPen, $mCurrent['ButtonsLineWidth'])
      _GDIPlus_GraphicsDrawLine($hGraphics, $iPrevButtonPos + 10, Int($iHeight - 20 - $mCurrent['ButtonsSize'] / 2), $iPrevButtonPos + $mCurrent['ButtonsSize'] - 15, $iHeight - $mCurrent['ButtonsSize'] - 8, $hPen)
      _GDIPlus_GraphicsDrawLine($hGraphics, $iPrevButtonPos + 10, Int($iHeight - 20 - $mCurrent['ButtonsSize'] / 2), $iPrevButtonPos + $mCurrent['ButtonsSize'] - 15, $iHeight - 32, $hPen)
      _GDIPlus_GraphicsDrawLine($hGraphics, $iNextButtonPos + $mCurrent['ButtonsSize'] - 10, Int($iHeight - 20 - $mCurrent['ButtonsSize'] / 2), $iNextButtonPos + 15, $iHeight - $mCurrent['ButtonsSize'] - 8, $hPen)
      _GDIPlus_GraphicsDrawLine($hGraphics, $iNextButtonPos + $mCurrent['ButtonsSize'] - 10, Int($iHeight - 20 - $mCurrent['ButtonsSize'] / 2), $iNextButtonPos + 15, $iHeight - 32, $hPen)
    EndIf
    If $mCurrent['Transition'] Then
      For $iOpacity = -1 To 0 Step (1 / $mCurrent['TransitionFrames'])
        $hAttributes = _GDIPlus_ImageAttributesCreate()
        $hTransition = _GDIPlus_BitmapCreateFromScan0($iWidth, $iHeight)
        $hTransitionGraphics = _GDIPlus_ImageGetGraphicsContext($hTransition)
        _GDIPlus_GraphicsSetPixelOffsetMode($hTransitionGraphics, 4)
        If $iRadius > 0 Then _GDIPlus_GraphicsSetClipPath($hTransitionGraphics, $hPath)
        $tMatrix = _GDIPlus_ColorMatrixCreateTranslate(0, 0, 0, $iOpacity)
        _GDIPlus_ImageAttributesSetColorMatrix($hAttributes, 0, True, DllStructGetPtr($tMatrix))
        _GDIPlus_GraphicsDrawImageRect($hTransitionGraphics, $avImage[$mCurrent['PrevIndex']], 0, 0, $iWidth, $iHeight)
        _GDIPlus_GraphicsDrawImageRectRect($hTransitionGraphics, $hDisplayImage, 0, 0, $iWidth, $iHeight, 0, 0, $iWidth, $iHeight, $hAttributes)
        __BitmapToCtrl($hTransition, $mCurrent['Ctrl'])
        _GDIPlus_GraphicsDispose($hTransitionGraphics)
        _GDIPlus_BitmapDispose($hTransition)
        _GDIPlus_ImageAttributesDispose($hAttributes)
      Next
    EndIf
    __BitmapToCtrl($hDisplayImage, $mCurrent['Ctrl'])
    If $iRadius > 0 Then _GDIPlus_PathDispose($hPath)
    _GDIPlus_GraphicsDispose($hGraphics)
    _GDIPlus_BitmapDispose($hClone)
    _GDIPlus_BitmapDispose($hDisplayImage)
    $mCurrent['FirstUpdate'] = True
    $mCurrent['LastUpdate'] = TimerInit()
    $mCurrent['PrevIndex'] = $mCurrent['Index']
    $__mSlideshows[$nIndex] = $mCurrent
  Next
  _GDIPlus_PenDispose($hPen)
  _GDIPlus_BrushDispose($hBrush)
  AdlibRegister('__Slideshow_Proc', $__mSlideshows['Refresh'])
EndFunc

Func __GetLocalImages(ByRef $avImage, $iCount, $iWidth, $iHeight)
  Local $nIndex, $hImage, $hBitmap, $hGraphics, $aDim
  For $nIndex = 0 To $iCount - 1
    If Not FileExists($avImage[$nIndex]) Then
      $avImage[$nIndex] = Null
      ContinueLoop
    EndIf
    $hImage = _GDIPlus_ImageLoadFromFile($avImage[$nIndex])
    If @error Then
      $avImage[$nIndex] = Null
      ContinueLoop
    EndIf
    $aDim = _GDIPlus_ImageGetDimension($hImage)
    $hBitmap = _GDIPlus_BitmapCreateFromScan0($iWidth, $iHeight)
    If @error Then
      _GDIPlus_ImageDispose($hImage)
      $avImage[$nIndex] = Null
      ContinueLoop
    EndIf
    $hGraphics = _GDIPlus_ImageGetGraphicsContext($hBitmap)
    _GDIPlus_GraphicsDrawImageRectRect($hGraphics, $hImage, 0, 0, $aDim[0], $aDim[1], 0, 0, $iWidth, $iHeight)
    _GDIPlus_GraphicsDispose($hGraphics)
    _GDIPlus_ImageDispose($hImage)
    $avImage[$nIndex] = $hBitmap
  Next
EndFunc

Func __GetImagesFromResource(ByRef $avImage, $iCount, $iWidth, $iHeight, $fDownload = False)
  Local $nIndex, $hImage, $hBitmap, $hGraphics, $aDim
  For $nIndex = 0 To $iCount - 1
    If $fDownload Then
      $avImage[$nIndex] = InetRead($avImage[$nIndex], 1)
      If @error Then
        $avImage[$nIndex] = Null
        ContinueLoop
      EndIf
    EndIf
    $hImage = _GDIPlus_BitmapCreateFromMemory($avImage[$nIndex])
    If @error Then
      $avImage[$nIndex] = Null
      ContinueLoop
    EndIf
    $aDim = _GDIPlus_ImageGetDimension($hImage)
    $hBitmap = _GDIPlus_BitmapCreateFromScan0($iWidth, $iHeight)
    If @error Then
      _GDIPlus_ImageDispose($hImage)
      $avImage[$nIndex] = Null
      ContinueLoop
    EndIf
    $hGraphics = _GDIPlus_ImageGetGraphicsContext($hBitmap)
    _GDIPlus_GraphicsDrawImageRectRect($hGraphics, $hImage, 0, 0, $aDim[0], $aDim[1], 0, 0, $iWidth, $iHeight)
    _GDIPlus_GraphicsDispose($hGraphics)
    _GDIPlus_ImageDispose($hImage)
    $avImage[$nIndex] = $hBitmap
  Next
EndFunc

Func __NoImage($iWidth, $iHeight, $iErrorBkColor, $iErrorColor, $sErrorFont, $iErrorFontSize)
  Local $hBitmap = _GDIPlus_BitmapCreateFromScan0($iWidth, $iHeight)
  If @error Then Return SetError(1, 0, Null)
  Local $hGraphics = _GDIPlus_ImageGetGraphicsContext($hBitmap)
  _GDIPlus_GraphicsSetCompositingQuality($hGraphics, $GDIP_COMPOSITINGQUALITY_HIGHQUALITY)
  _GDIPlus_GraphicsSetSmoothingMode($hGraphics, 4)
  _GDIPlus_GraphicsSetPixelOffsetMode($hGraphics, 4)
  _GDIPlus_GraphicsClear($hGraphics, $iErrorBkColor)
  Local $hFontFamily = _GDIPlus_FontFamilyCreate($sErrorFont)
  Local $hFont = _GDIPlus_FontCreate($hFontFamily, $iErrorFontSize, 1)
  Local $hFormat = _GDIPlus_StringFormatCreate()
  _GDIPlus_StringFormatSetAlign($hFormat, 1)
  _GDIPlus_StringFormatSetLineAlign($hFormat, 1)
  Local $hBrush = _GDIPlus_BrushCreateSolid($iErrorColor)
  _GDIPlus_GraphicsDrawStringEx($hGraphics, 'No image', $hFont, _GDIPlus_RectFCreate(0, 0, $iWidth, $iHeight), $hFormat, $hBrush)
  _GDIPlus_BrushDispose($hBrush)
  _GDIPlus_StringFormatDispose($hFormat)
  _GDIPlus_FontDispose($hFont)
  _GDIPlus_FontFamilyDispose($hFontFamily)
  _GDIPlus_GraphicsDispose($hGraphics)
  Return $hBitmap
EndFunc

Func __BitmapToCtrl($hBitmap, $cCtrl)
  Local Static $STM_SETIMAGE = 0x0172, $IMAGE_BITMAP = 0
  Local $hHBITMAP = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap)
  _WinAPI_DeleteObject(GUICtrlSendMsg($cCtrl, $STM_SETIMAGE, $IMAGE_BITMAP, $hHBITMAP))
  _WinAPI_DeleteObject($hHBITMAP)
EndFunc

Func __Pressed($sHexKey, $hDLL)
    ; Nothing fancy here, it's just _IsPressed() but I hate to include a header for a single function
	Local $aCall = DllCall($hDLL, 'short', 'GetAsyncKeyState', 'int', '0x' & $sHexKey)
	If @error Then Return SetError(@error, @extended, False)
	Return BitAND($aCall[0], 0x8000) <> 0
EndFunc
