-- Migrated for Hyprland 0.56.2+.
local v = ... or {}
-- /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  #
-- For window rules and layerrules
-- See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
-- This file is used to add or overwrite window rules
-- This file will not be modified during dotfiles updates

-- Hotspot/Rofi: keep rounded transparent corners free of blur.
hl.layer_rule({ ignore_alpha = 0.5, match = { namespace = "rofi" } })
hl.layer_rule({ blur = true, match = { namespace = "rofi" } })

-- OpenWhispr floating voice recorder pill:
-- Remove window borders, shadows, blur, and animations.
-- no_follow_mouse prevents mouse hover on the transparent rectangle from stealing focus from the active window.
hl.window_rule({
  ["float"] = true,
  ["pin"] = true,
  ["border_size"] = 0,
  ["rounding"] = 0,
  ["no_shadow"] = true,
  ["no_blur"] = true,
  ["no_anim"] = true,
  ["no_initial_focus"] = true,
  ["no_follow_mouse"] = true,
  ["match"] = { ["class"] = "^(open-whispr)$", ["title"] = "^(Voice Recorder)$" }
})

hl.window_rule({
  ["float"] = true,
  ["pin"] = true,
  ["border_size"] = 0,
  ["rounding"] = 0,
  ["no_shadow"] = true,
  ["no_blur"] = true,
  ["no_anim"] = true,
  ["no_initial_focus"] = true,
  ["no_follow_mouse"] = true,
  ["match"] = { ["class"] = "^(open-whispr)$", ["title"] = "^(Meeting Notification)$" }
})

hl.window_rule({
  ["float"] = true,
  ["center"] = true,
  ["match"] = { ["class"] = "^(open-whispr)$", ["title"] = "^(Control Panel)$" }
})
