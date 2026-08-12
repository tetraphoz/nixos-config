import XMonad hiding ((|||))
import qualified XMonad.StackSet as W
import Colors

import System.Exit (exitSuccess)

-- Core utilities
import XMonad.Util.Cursor
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Loggers

-- Layouts
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

-- Prompts
import XMonad.Prompt
import XMonad.Prompt.Window
import XMonad.Prompt.FuzzyMatch

-- Hooks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP

-- Actions
import XMonad.Actions.CycleWS
import XMonad.Actions.EasyMotion (selectWindow)
import XMonad.Actions.NoBorders
import XMonad.Actions.CopyWindow
import XMonad.Actions.Minimize
import XMonad.Actions.ToggleFullFloat


main :: IO ()
main =
    xmonad $
        ewmh
        . docks
        . withEasySB
            (statusBarProp "xmobar" (pure myXmobarPP))
            defToggleStrutsKey
        $ myConfig


myConfig = def
    { terminal           = "kitty"
    , modMask            = mod4Mask

    , normalBorderColor  = color6
    , focusedBorderColor = color1
    , borderWidth        = 3

    , startupHook =
        setWMName "LG3D"
        >> setDefaultCursor xC_left_ptr

    , manageHook =
        myManageHook
        <+> manageHook def

    , layoutHook =
        spacingRaw
            True
            (Border 5 5 5 5)
            True
            (Border 5 5 5 5)
            True
            myLayout
    }
    `additionalKeysP` myKeys


------------------------------------------------------------------------
-- KEYBOARD
------------------------------------------------------------------------

myKeys =
    --------------------------------------------------------------------
    -- XMONAD DEFAULTS
    --------------------------------------------------------------------

    [ -- Kill focused window
      ("M-S-c", kill)

      -- Restart XMonad
    , ("M-q", restart "xmonad" True)

      -- Quit XMonad
    , ("M-S-q", io (exitSuccess))

      -- Focus next / previous window
    , ("M-j", windows W.focusDown)
    , ("M-k", windows W.focusUp)

      -- Focus master
    , ("M-m", windows W.focusMaster)

      -- Swap focused window with master
    , ("M-S-m", windows W.swapMaster)

      -- Swap with next / previous
    , ("M-S-j", windows W.swapDown)
    , ("M-S-k", windows W.swapUp)

      -- Shrink / expand master area
    , ("M-h", sendMessage Shrink)
    , ("M-l", sendMessage Expand)

      -- Increase / decrease number of master windows
    , ("M-,", sendMessage (IncMasterN 1))
    , ("M-.", sendMessage (IncMasterN (-1)))

      -- Toggle floating
    , ("M-t", withFocused toggleFullFloat)

      -- Refresh
    , ("M-S-r", refresh)

      -- Toggle fullscreen
    , ("M-f", sendMessage $ JumpToLayout "Full")

      -- Cycle layouts
    , ("M-<Space>", sendMessage NextLayout)

      -- Toggle struts / xmobar
    , ("M-b", sendMessage ToggleStruts)

      -- Move between workspaces
    , ("M-<Left>", prevWS)
    , ("M-<Right>", nextWS)

      -- Move window between workspaces
    , ("M-S-<Left>", shiftToPrev >> prevWS)
    , ("M-S-<Right>", shiftToNext >> nextWS)

      -- Go back to previous workspace
    , ("M-`", toggleWS)

      ----------------------------------------------------------------
      -- LAYOUT
      ----------------------------------------------------------------

      -- Toggle border
    , ("M-s", withFocused toggleBorder)

      -- Mirror layout
    , ("M-S-C-j", sendMessage MirrorShrink)
    , ("M-S-C-k", sendMessage MirrorExpand)

      -- Resize panes
    , ("M-C-h", sendMessage Shrink)
    , ("M-C-l", sendMessage Expand)

      -- Rotate layouts
    , ("M-C-<Space>", sendMessage NextLayout)

      -- Toggle minimize
    , ("M-S-n", withFocused minimizeWindow)

      -- Restore minimized window
    , ("M-S-C-n", withLastMinimized maximizeWindowAndFocus)

      ----------------------------------------------------------------
      -- APPLICATIONS
      ----------------------------------------------------------------

    , ("M-S-f", spawn "librewolf")
    , ("M-S-t", spawn "thunar")

      -- Rofi
    , ("M-d", spawn "rofi -modi run,drun,window -show drun")
    -- , ("M-w", spawn "rofi -modi window -show window")

      -- Password manager
    , ("M-p", spawn "rofipass")

      -- Screenshot
    , ("<Print>", spawn "scrot -s")
    , ("C-<Print>", spawn "ss_ocr")

      -- Lock
    , ("M-S-l", spawn "slock")

      -- Wallpaper
    , ("M-S-u",
        spawn "wal -a 65 --saturate 0.5 -i /media/img/wallpapers")

      ----------------------------------------------------------------
      -- EMACS
      ----------------------------------------------------------------

    , ("M-o", spawn "emacsclient -ca ''")
    , ("M-i",
        spawn "emacsclient -cn -e '(emacs-everywhere)'")

      ----------------------------------------------------------------
      -- WINDOW PROMPTS
      ----------------------------------------------------------------

    , ("M-g",
        windowPrompt myXPConfig Goto allWindows)

    , ("M-S-g",
        windowPrompt myXPConfig Bring allWindows)

      ----------------------------------------------------------------
      -- WINDOW MANAGEMENT
      ----------------------------------------------------------------

      -- Easy window selection
    , ("M-a",
        selectWindow def >>= (`whenJust` windows . W.focusWindow))

    --   -- Copy window to all workspaces
    -- , ("M-c",
    --     windows copyToAll)

    --   -- Remove window from all other workspaces
    -- , ("M-S-C",
    --     killAllOtherCopies)

      -- Float/unfloat focused window
    , ("M-C-t",
        withFocused toggleFullFloat)

      ----------------------------------------------------------------
      -- SCRATCHPADS
      ----------------------------------------------------------------

    , ("M-<Backspace>",
        namedScratchpadAction myScratchPads "terminal")

    , ("M-S-Y",
        namedScratchpadAction myScratchPads "ncmpcpp")

      ----------------------------------------------------------------
      -- MUSIC
      ----------------------------------------------------------------

    , ("M-y y",
        spawn "mpc toggle")

    , ("M-y p",
        spawn "mpc prev")

    , ("M-y n",
        spawn "mpc next")

      ----------------------------------------------------------------
      -- VOLUME
      ----------------------------------------------------------------

    , ("<XF86AudioMute>",
        spawn "wpctl set-mute @DEFAULT_SINK@ toggle")

    , ("<XF86AudioLowerVolume>",
        spawn "wpctl set-volume @DEFAULT_SINK@ 5%-")

    , ("<XF86AudioRaiseVolume>",
        spawn "wpctl set-volume @DEFAULT_SINK@ 5%+")

      -- Microphone
    , ("<XF86AudioMicMute>",
        spawn "wpctl set-mute @DEFAULT_SOURCE@ toggle")

      ----------------------------------------------------------------
      -- BRIGHTNESS
      ----------------------------------------------------------------

    , ("<XF86MonBrightnessUp>",
        spawn "brightnessctl set 5%+")

    , ("<XF86MonBrightnessDown>",
        spawn "brightnessctl set 5%-")

      ----------------------------------------------------------------
      -- SYSTEM
      ----------------------------------------------------------------

      -- Terminal
    , ("M-<Return>",
        spawn "kitty")

      -- File manager
    , ("M-S-e",
        spawn "thunar")

      -- Kill focused window
    , ("M-S-x",
        kill)

      -- Reload XMonad configuration
    , ("M-C-q",
        spawn "xmonad --recompile && xmonad --restart")
    ]


------------------------------------------------------------------------
-- LAYOUTS
------------------------------------------------------------------------

myLayout =
      minimize tiled
  ||| minimize (Mirror tiled)
  ||| minimize threeCol
  ||| minimize twopane
  ||| minimize resizable
  ||| bsp
  ||| Full
  ||| simplestFloat
  where

    tiled =
        Tall nmaster delta ratio

    threeCol =
        ThreeColMid nmaster delta ratio

    twopane =
        TwoPane delta ratio

    resizable =
        ResizableTall nmaster delta ratio []

    bsp =
        emptyBSP

    nmaster =
        1

    ratio =
        1 / 2

    delta =
        3 / 100


------------------------------------------------------------------------
-- XMOBAR
------------------------------------------------------------------------

myXmobarPP :: PP
myXmobarPP =
    def
        { ppSep             = separator " / "
        , ppTitleSanitize   = xmobarStrip

        , ppCurrent =
            wrap " " ""
            . xmobarBorder "Top" "#8be9fd" 2

        , ppHidden =
            hidden . wrap " " ""

        , ppHiddenNoWindows =
            loHidden . wrap " " ""

        , ppUrgent =
            urgent . wrap (urgent "!") (urgent "!")

        , ppOrder =
            myOrder

        , ppExtras =
            [logTitles formatFocused formatUnfocused]
        }

    where

        myOrder [ws, l, _, wins] =
            [ws, l, wins]

        formatFocused =
            wrap (separator "[") (separator "]")
            . focused
            . ppWindow

        formatUnfocused =
            wrap (separator "[") (separator "]")
            . unfocused
            . ppWindow


ppWindow :: String -> String
ppWindow =
    xmobarRaw
    . (\w -> if null w then "untitled" else w)
    . shorten 30


title, separator, hidden, loHidden,
    urgent, focused, unfocused :: String -> String

title =
    xmobarColor color0 ""

separator =
    xmobarColor color2 ""

hidden =
    xmobarColor color6 ""

loHidden =
    xmobarColor color1 ""

urgent =
    xmobarColor color5 ""

focused =
    xmobarColor color6 ""

unfocused =
    xmobarColor color7 ""


------------------------------------------------------------------------
-- SCRATCHPADS
------------------------------------------------------------------------

rectCentered :: Rational -> W.RationalRect
rectCentered percentage =
    W.RationalRect offset offset percentage percentage
    where
        offset =
            (1 - percentage) / 2


myScratchPads :: [NamedScratchpad]
myScratchPads =
    [ NS
        "terminal"
        "kitty --class scratch"
        findTerm
        centered

    , NS
        "ncmpcpp"
        "kitty --class scratchNcm -e ncmpcpp"
        findNcm
        centeredNcmp
    ]

    where

        findTerm =
            className =? "scratch"

        findNcm =
            className =? "scratchNcm"

        centered =
            customFloating $
                rectCentered 0.5

        centeredNcmp =
            customFloating $
                rectCentered 0.8


------------------------------------------------------------------------
-- WINDOW PROMPT
------------------------------------------------------------------------

myXPConfig =
    def
        { searchPredicate = fuzzyMatch
        , sorter          = fuzzySort
        , autoComplete    = Just 500000

        , bgColor          = background
        , fgColor          = foreground
        , fgHLight         = background
        , bgHLight         = color6
        , borderColor      = background

        , alwaysHighlight  = True
        , font             = "Tamzen 8"
        }


------------------------------------------------------------------------
-- MANAGE HOOK
------------------------------------------------------------------------

myManageHook :: ManageHook
myManageHook =
    composeAll
        [ className =? "scratch"
            --> customFloating (rectCentered 0.5)

        , className =? "scratchNcm"
            --> customFloating (rectCentered 0.8)

        , isDialog
            --> customFloating (rectCentered 0.5)

        , isFullscreen
            --> doFullFloat
        ]
