import XMonad hiding ( (|||) )
import qualified XMonad.StackSet as W
-- import qualified XMonad.Actions.FlexibleResize as Flex
import Colors

import XMonad.Util.Cursor
import XMonad.Layout.Spacing
import XMonad.Layout.Gaps
import XMonad.Layout.LayoutCombinators
import XMonad.Layout.ResizableTile
import XMonad.Layout.TwoPane
import XMonad.Layout.NoBorders
import XMonad.Layout.Minimize
import XMonad.Layout.SimplestFloat
import XMonad.Layout.ThreeColumns
import XMonad.Layout.BinarySpacePartition

import XMonad.Util.Run   -- for spawnPipe and hPutStrLn
import XMonad.Util.NamedScratchpad
import XMonad.Util.EZConfig (additionalKeysP, additionalMouseBindings)
import XMonad.Util.Loggers

import XMonad.Prompt
import XMonad.Prompt.Window
import XMonad.Prompt.FuzzyMatch

-- import XMonad.Hooks.WorkspaceHistory (workspaceHistoryHook)
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
-- import XMonad.Hooks.WindowSwallowing

import XMonad.Actions.Navigation2D
import XMonad.Actions.CycleWS
import XMonad.Actions.UpdatePointer
import XMonad.Actions.EasyMotion (selectWindow, EasyMotionConfig(..))
import XMonad.Actions.NoBorders
import XMonad.Actions.CopyWindow
import XMonad.Actions.FloatSnap


main :: IO()
main = xmonad
     -- . ewmhFullscren
     . ewmh
     . docks
     . withEasySB (statusBarProp "xmobar" (pure myXmobarPP)) defToggleStrutsKey
     $ myConfig


myConfig = def
        { terminal = "kitty"
        , modMask = mod4Mask
        , normalBorderColor  = color6
        , focusedBorderColor = color1
        , borderWidth = 3
        , startupHook = setWMName "LG3D" >> setDefaultCursor xC_left_ptr
        , manageHook = myManageHook <+> manageHook def
        , layoutHook = spacingRaw True (Border 0 5 5 5) True (Border 5 5 5 5) True $ myLayout
        -- , handleEventHook = handleEventHook def <+> swallowEventHook (className =? "Alacritty" <||> className =? "Termite") (return True)
        -- , logHook = updatePointer (0.5, 0.5) (1, 1)
        }
        `additionalKeysP` myKeys
       --  `additionalMouseBindings`
       --  [
       --  ((mod4Mask,               button1), (\w -> focus w >> mouseMoveWindow w >> afterDrag (snapMagicMove (Just 50) (Just 50) w)))
       -- , ((mod4Mask .|. shiftMask, button1), (\w -> focus w >> mouseMoveWindow w >> afterDrag (snapMagicResize [L,R,U,D] (Just 50) (Just 50) w)))
       -- , ((mod4Mask .|. shiftMask,               button3), (\w -> focus w >> mouseResizeWindow w >> afterDrag (snapMagicResize [R,D] (Just 50) (Just 50) w)))
       --     , ((mod4Mask, button3), (\w -> focus w >> Flex.mouseResizeWindow w))
       --  ]

myKeys = [
        -- Layouts
         ("M-s",   withFocused toggleBorder)
        , ("M-S-C-j", sendMessage MirrorShrink)
        , ("M-S-C-k", sendMessage MirrorExpand)
        , ("M-<Tab>", toggleWS)

        -- Apps
        , ("M-S-f",     spawn "librewolf")
        , ("M-S-t",     spawn "thunar")
        , ("C-<Print>", spawn "ss_ocr")
        , ("<Print>",   spawn "scrot -s")
        , ("M-S-l",     spawn "slock")
        , ("M-d",       spawn "rofi -modi run,drun,window -show")
        , ("M-S-u",     spawn "wal -a 65 --saturate 0.5 -i  ~/media/img/wallpapers")

        -- Scratchpads
        , ("M-<Backspace>", namedScratchpadAction myScratchPads "terminal")
        -- , ("M-s-s", withFocused $ toggleDynamicNSP "dyn1")
        -- , ("M-s"  , dynamicNSPAction "dyn1")

        -- Emacs
        -- , ("M-m b", spawn "emacsclient -cne (consult-buffer)")
        , ("M-o", spawn "emacsclient -ca \"\"")
        , ("M-i", spawn "emacsclient -cn -e \"(emacs-everywhere)\"")
        -- , ("M-o", spawn "/home/tetra/.emacs.d/bin/org-capture") Temporalmente fuera de servicio, interfiere con el daemon

        -- Windows
        , ("M-g", windowPrompt myXPConfig Goto allWindows)
        , ("M-S-g", windowPrompt myXPConfig Bring allWindows)

        -- Sound
        , ("M-S-m S-m", namedScratchpadAction myScratchPads "ncmpcpp")
        , ("M-S-m m", spawn "mpc toggle")
        , ("M-S-m S-,", spawn "mpc prev")
        , ("M-S-m S-.", spawn "mpc next")
        , ("<XF86AudioMute>",   spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")  -- Bug prevents it from toggling correctly in 12.04.
        , ("<XF86AudioMicMute>",   spawn "pactl set-source-mute @DEFAULT_SOURCE@ toggle")  -- Bug prevents it from toggling correctly in 12.04.
        , ("<XF86AudioLowerVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ -5%")
        , ("<XF86AudioRaiseVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ +5%")

        -- Backlight
        , ("<XF86MonBrightnessUp>", spawn "xbacklight -inc 5")
        , ("<XF86MonBrightnessDown>", spawn "xbacklight -dec 5")

        -- Actions
        -- , ("M-c", selectWindow def >>= (`whenJust` killWindow))
        , ("M-a", selectWindow def >>= (`whenJust` windows . W.focusWindow))
        -- , ("M-c " ++ (show i), windows $ copy ws) | (i,ws) <- zip [1..9] map show [1..9]
        , ("M-c", windows copyToAll)
        ]


myLayout = tiled ||| Mirror tiled ||| Full ||| threeCol ||| twopane
  where
    twopane  = TwoPane delta ratio
    threeCol = ThreeColMid nmaster delta ratio
    tiled    = Tall nmaster delta ratio
    nmaster  = 1      -- Default number of windows in the master pane
    ratio    = 1/2    -- Default proportion of screen occupied by master pane
    delta    = 3/100  -- Percent of screen to increment by when resizing panes

myXmobarPP :: PP
myXmobarPP = def
  {   ppSep             = separator " / "
    , ppTitleSanitize   = xmobarStrip
    , ppCurrent         = wrap " " "" . xmobarBorder "Top" "#8be9fd" 2
    , ppHidden          = hidden . wrap " " ""
    , ppHiddenNoWindows = loHidden . wrap " " ""
    , ppUrgent          = urgent . wrap (urgent "!") (urgent "!")
    , ppOrder           = myOrder
    , ppExtras          = [logTitles formatFocused formatUnfocused]
    }
  where
    myOrder [ws, l, _, wins] = [ws, l, wins]
    formatFocused   = wrap (separator    "[") (separator    "]")   . focused . ppWindow
    formatUnfocused = wrap (separator "[") (separator "]") . unfocused . ppWindow

    -- | Windows should have *some* title, which should not not exceed a
    -- sane length.
    ppWindow :: String -> String
    ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 30

    title, separator, hidden, loHidden, urgent, focused, unfocused :: String -> String
    title     = xmobarColor color0 ""
    separator = xmobarColor color2 ""
    hidden    = xmobarColor color6 ""
    loHidden  = xmobarColor color1 ""
    urgent    = xmobarColor color5 ""
    focused   = xmobarColor color6 ""
    unfocused = xmobarColor color7 ""

rectCentered :: Rational -> W.RationalRect
rectCentered percentage = W.RationalRect offset offset percentage percentage
  where
    offset = (1 - percentage) / 2

myScratchPads :: [NamedScratchpad]
myScratchPads = [ NS "terminal" "kitty --class scratch" findTerm centered
                , NS "ncmpcpp"  "kitty --class scratchNcm -e ncmpcpp" findNcm centered
                ]
  where
    findTerm   = className =? "scratch"
    findNcm   = className =? "scratchNcm"
    centered = customFloating $ (rectCentered 0.5)

myXPConfig = def { searchPredicate = fuzzyMatch
                 , sorter          = fuzzySort
                 , autoComplete    = Just 500000
                 , bgColor         = background
                 , fgColor         = foreground
                 , fgHLight        = background
                 , bgHLight        = color6
                 , borderColor     = background
                 , alwaysHighlight = True
                 , font            = "Tamzen"
                 }

myManageHook :: ManageHook
myManageHook = composeAll
    [
      className =? "scratch"    --> customFloating (rectCentered 0.5)
    , className =? "scratchNcm" --> customFloating (rectCentered 0.8)
    , isDialog                  --> customFloating (rectCentered 0.5)
    , isFullscreen              --> doFullFloat
    ]
