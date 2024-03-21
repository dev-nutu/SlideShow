#include <Slideshow.au3>

Global $avImage[4] = [ _
    'https://lh5.googleusercontent.com/p/AF1QipM3jIOsqrISfcKwgYLYF8-9DyAzQiUyWmB35nBj=w540-h312-n-k-no', _
    'https://lh5.googleusercontent.com/p/AF1QipMPb5fGtzZz2ZJFd20CV2trNzmxNOYLv4abJSfi=w540-h312-n-k-no', _
    'https://lh5.googleusercontent.com/p/AF1QipPLOXRwTpKbFxNNLTmiLrIJlG_H3h4VU6HShLwf=w540-h312-n-k-no', _
    'https://lh5.googleusercontent.com/p/AF1QipPNiwx1lGPxcHJzKTMRl5Cyr1SOjS05yHbif8BE=w540-h312-n-k-no' _
]

Global $asCaptions[4] = ['Pico do Fogo', 'Praia da Chave', 'Buracona - Blue Eye Cave', 'Deserto de Viana']

Global $mKeys[]         ; Check _IsPressed() in help file for more virtual key codes
$mKeys['Prev'] = '25'   ; Left arrow button
$mKeys['Next'] = '27'   ; Right arrow button

Global $mOptions[]
$mOptions['ImageType'] = 'URL'
$mOptions['ShowSlides'] = True
$mOptions['ShowCaptions'] = True
$mOptions['Captions'] = $asCaptions
$mOptions['EnableKeys'] = True
$mOptions['Keys'] = $mKeys
$mOptions['Transition'] = True

Global $sTitle = 'Cape Verde'
Global $sText = 'Cape Verde or Cabo Verde, officially the Republic of Cabo Verde, is an archipelago and island country of West Africa in the central Atlantic Ocean, ' & _
'consisting of ten volcanic islands with a combined land area of about 4,033 square kilometres (1,557 sq mi). These islands lie between 600 and 850 kilometres ' & _
'(320 and 460 nautical miles) west of Cap-Vert, the westernmost point of continental Africa. The Cape Verde islands form part of the Macaronesia ecoregion, ' & _
'along with the Azores, the Canary Islands, Madeira, and the Savage Isles.'
Global $sExtraText = "Cape Verde's official language is Portuguese. The recognized national language is Cape Verdean Creole, which is spoken by the vast " & _
"majority of the population. As of the 2021 census the most populated islands were Santiago, where the capital Praia is located (269,370), São Vicente (74,016), " & _
"Santo Antão (36,632), Fogo (33,519) and Sal (33,347). The largest cities are Praia (137,868), Mindelo (69,013), Espargos (24,500) and Assomada (21,297)."
Global $sCopyright = 'Sources for pictures and data are from google.com and wikipedia.com'

Global $hGUI, $cTitle, $cText, $cExtra, $cCopyright, $mSlideshow

_GDIPlus_Startup()
$hGUI = GUICreate('Slideshow', 870, 450)
$cTitle = GUICtrlCreateLabel($sTitle, 10, 10, 300, 60)
$cText = GUICtrlCreateLabel($sText, 10, 90, 300, 240)
$cExtra = GUICtrlCreateLabel($sExtraText, 10, 330, 850, 80)
$cCopyright = GUICtrlCreateLabel($sCopyright, 10, 420, 850, 20)
$mSlideshow = _GUICtrlSlideshow_Create($hGUI, 320, 10, 540, 312, $avImage, $mOptions)
GUICtrlSetFont($cTitle, 35, 600, 0, 'Segoe UI')
GUICtrlSetFont($cText, 11, 500, 0, 'Segoe UI')
GUICtrlSetFont($cExtra, 11, 500, 0, 'Segoe UI')
GUICtrlSetFont($cCopyright, 11, 500, 2, 'Segoe UI')
GUICtrlSetColor($cTitle, 0x000060)
GUICtrlSetColor($cCopyright, 0x800000)
GUISetState(@SW_SHOW, $hGUI)

While True
    _GUICtrlSlideshow_KeyEvent($mSlideshow)
    If _GUICtrlSlideshow_ButtonEvent($mSlideshow, $SLIDESHOW_PREV_BTN) Then _GUICtrlSlideshow_ShowSlide($mSlideshow, $BTN_EVENT_PREV)
    If _GUICtrlSlideshow_ButtonEvent($mSlideshow, $SLIDESHOW_NEXT_BTN) Then _GUICtrlSlideshow_ShowSlide($mSlideshow, $BTN_EVENT_NEXT)
    Switch GUIGetMsg()
        Case -3
            ExitLoop
    EndSwitch
WEnd

_GUICtrlSlideshow_Delete($mSlideshow)
_GDIPlus_Shutdown()
