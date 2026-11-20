-- OpenWhispr Window Rules for Hyprland (Lua Provider)
-- Location: ~/.config/hypr/UserConfigs/WindowRules.lua

-- Floating voice recorder pill:
-- Remove window borders, shadows, blur, and animations.
-- Do not steal initial focus so active applications stay focused.
hl.window_rule({
  ["float"] = true,
  ["pin"] = true,
  ["border_size"] = 0,
  ["rounding"] = 0,
  ["no_shadow"] = true,
  ["no_blur"] = true,
  ["no_anim"] = true,
  ["no_initial_focus"] = true,
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
  ["match"] = { ["class"] = "^(open-whispr)$", ["title"] = "^(Meeting Notification)$" }
})

hl.window_rule({
  ["float"] = true,
  ["center"] = true,
  ["match"] = { ["class"] = "^(open-whispr)$", ["title"] = "^(Control Panel)$" }
})
