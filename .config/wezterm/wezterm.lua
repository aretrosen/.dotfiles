local wezterm = require("wezterm")
local act = wezterm.action

local LEFT_TRIANGLE = ""
local RIGHT_TRIANGLE = ""

local ADMIN_ICON = ""

local CMD_ICON = ""
local PS_ICON = ""
local NU_ICON = "󰅂"
local WSL_ICON = ""

local NVIM_ICON = ""
local PAGER_ICON = ""
local FUZZY_ICON = ""
local BASH_ICON = ""
local PROCESS_ICON = ""

local PYTHON_ICON = ""
local NODE_ICON = ""
local OCAML_ICON = ""

local GPUS = wezterm.gui.enumerate_gpus()

local function colorscheme_on_appearance()
  local appearance = wezterm.gui.get_appearance()
  if not appearance or appearance:find("Dark") then
    return "GruvboxDarkHard"
  end
  return "Gruvbox light, hard (base16)"
end

local function should_enable_wayland()
  local session = os.getenv("DESKTOP_SESSION")
  if session == "hyprland" then
    return true
  end
  return false
end

local colorscheme = colorscheme_on_appearance()
local enable_wayland = should_enable_wayland()

local colorscheme_as_table = wezterm.color.get_builtin_schemes()[colorscheme]
local tab_bar_bg = colorscheme_as_table.selection_bg or colorscheme_as_table.background
-- tab title customization
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local edge_bg = tab_bar_bg

  local bg = colorscheme_as_table.brights[8]
  local fg = colorscheme_as_table.brights[1]

  if tab.is_active then
    bg = colorscheme_as_table.ansi[5]
    fg = colorscheme_as_table.background
  elseif hover then
    bg = colorscheme_as_table.ansi[3]
    fg = colorscheme_as_table.background
  end

  local active_pane = tab.active_pane
  local exec_name =
    active_pane.foreground_process_name:gsub("(.*[/\\])(.*)", "%2"):gsub("%.exe$", "")

  local title = BASH_ICON .. " " .. exec_name
  if exec_name == "pwsh" then
    title = PS_ICON .. " ps"
  elseif exec_name == "cmd" then
    title = CMD_ICON .. " cmd"
  elseif exec_name == "nu" then
    title = NU_ICON .. " nu"
  elseif exec_name == "wsl" or exec_name == "wslhost" then
    title = WSL_ICON .. " wsl"
  elseif exec_name == "nvim" then
    title = NVIM_ICON .. " nvim"
  elseif exec_name == "bat" or exec_name == "less" then
    title = PAGER_ICON .. " " .. exec_name
  elseif exec_name == "btop" or exec_name == "top" or exec_name == "nvtop" then
    title = PROCESS_ICON .. " " .. exec_name
  elseif exec_name == "fzf" then
    title = FUZZY_ICON .. " " .. exec_name
  elseif exec_name == "python" or exec_name == "ipython" then
    title = PYTHON_ICON .. " " .. exec_name
  elseif exec_name == "node" then
    title = NODE_ICON .. " " .. exec_name
  elseif exec_name == "ocamlrun" then
    title = OCAML_ICON .. " utop"
  end

  if active_pane.title:match("^Administrator: ") then
    title = title .. " " .. ADMIN_ICON
  end

  local has_unseen_output = false
  for _, pane in ipairs(tab.panes) do
    if pane.has_unseen_output then
      has_unseen_output = true
      break
    end
  end

  title = " " .. title .. (has_unseen_output and " 󰜎" or " ")

  if title:len() > max_width then
    local diff = title:len() - max_width
    title = wezterm.truncate_right(title, title:len() - diff)
  end

  local cells = {
    { Attribute = { Intensity = "Bold" } },
    { Background = { Color = edge_bg } },
    { Foreground = { Color = bg } },
    { Text = LEFT_TRIANGLE },
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Text = title },
    { Background = { Color = edge_bg } },
    { Foreground = { Color = bg } },
    { Text = RIGHT_TRIANGLE },
    { Attribute = { Intensity = "Normal" } },
  }
  return cells
end)

-- new tab button customization
wezterm.on("new-tab-button-click", function(window, pane, button, default_action)
  wezterm.log_info("new-tab", window, pane, button, default_action)
  if default_action and button == "Left" then
    window:perform_action(default_action, pane)
  end

  if default_action and button == "Right" then
    window:perform_action(
      wezterm.action.ShowLauncherArgs({
        title = "  Select/Search:",
        flags = "FUZZY|LAUNCH_MENU_ITEMS|DOMAINS|WORKSPACES",
      }),
      pane
    )
  end
  return false
end)

local config = {
  -- set term
  term = "wezterm",

  -- colors and colorscheme
  color_scheme = colorscheme,
  colors = {
    tab_bar = {
      background = tab_bar_bg,
      new_tab = {
        bg_color = tab_bar_bg,
        fg_color = colorscheme_as_table.foreground,
        intensity = "Bold",
      },
      new_tab_hover = {
        bg_color = tab_bar_bg,
        fg_color = colorscheme_as_table.ansi[2],
        intensity = "Bold",
      },
      active_tab = {
        bg_color = tab_bar_bg,
        fg_color = colorscheme_as_table.foreground,
      },
    },
  },

  -- font customization
  font = wezterm.font({ family = "MonaspiceNe NFM" }),
  harfbuzz_features = {
    "calt",
    "liga",
    "dlig",
    "ss01",
    "ss02",
    "ss03",
    "ss04",
    "ss05",
    "ss06",
    "ss07",
    "ss08",
  },
  font_rules = {
    {
      italic = true,
      intensity = "Bold",
      font = wezterm.font({
        family = "MonaspiceRn NFM",
        weight = "Bold",
        style = "Italic",
      }),
    },
    {
      italic = true,
      intensity = "Half",
      font = wezterm.font({
        family = "MonaspiceRn NFM",
        weight = "DemiBold",
        style = "Italic",
      }),
    },
    {
      italic = true,
      intensity = "Normal",
      font = wezterm.font({
        family = "MonaspiceRn NFM",
        style = "Italic",
      }),
    },
  },

  -- key customization
  disable_default_key_bindings = true,
  keys = {
    -- splitting panes
    {
      key = [[\]],
      mods = "CTRL|ALT",
      action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
    },
    {
      key = [[-]],
      mods = "CTRL|ALT",
      action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
    },

    -- move to pane
    {
      key = "h",
      mods = "CTRL|SHIFT",
      action = act.ActivatePaneDirection("Left"),
    },
    {
      key = "j",
      mods = "CTRL|SHIFT",
      action = act.ActivatePaneDirection("Down"),
    },
    {
      key = "k",
      mods = "CTRL|SHIFT",
      action = act.ActivatePaneDirection("Up"),
    },
    {
      key = "l",
      mods = "CTRL|SHIFT",
      action = act.ActivatePaneDirection("Right"),
    },

    -- resize panes
    {
      key = "LeftArrow",
      mods = "CTRL|SHIFT",
      action = act.AdjustPaneSize({ "Left", 3 }),
    },
    {
      key = "DownArrow",
      mods = "CTRL|SHIFT",
      action = act.AdjustPaneSize({ "Down", 3 }),
    },
    {
      key = "UpArrow",
      mods = "CTRL|SHIFT",
      action = act.AdjustPaneSize({ "Up", 3 }),
    },
    {
      key = "RightArrow",
      mods = "CTRL|SHIFT",
      action = act.AdjustPaneSize({ "Right", 3 }),
    },

    -- browser-like bindings for tabbing
    { key = "t", mods = "CTRL|ALT", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
    { key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },

    -- font size
    { key = "+", mods = "SHIFT|CTRL", action = act.IncreaseFontSize },
    { key = "_", mods = "SHIFT|CTRL", action = act.DecreaseFontSize },
    { key = "0", mods = "SHIFT|CTRL", action = act.ResetFontSize },

    -- spawn new window with current directory
    { key = "n", mods = "CTRL|ALT", action = act.SpawnWindow },

    -- standard copy/paste bindings
    { key = "x", mods = "CTRL|SHIFT", action = "ActivateCopyMode" },
    { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
    {
      key = "c",
      mods = "CTRL|SHIFT",
      action = act.CopyTo("ClipboardAndPrimarySelection"),
    },

    -- other functionlities
    {
      key = "f",
      mods = "SHIFT|CTRL",
      action = act.Search("CurrentSelectionOrEmptyString"),
    },
    {
      key = "e",
      mods = "CMD",
      action = act.CharSelect({ copy_on_select = true, copy_to = "ClipboardAndPrimarySelection" }),
    },
    { key = "l", mods = "SHIFT|CTRL", action = act.ShowDebugOverlay },
  },

  -- tab customization
  use_fancy_tab_bar = false,
  hide_tab_bar_if_only_one_tab = true,
  show_tab_index_in_tab_bar = false,

  -- window customization
  window_background_opacity = 0.8,
  window_frame = {
    font = wezterm.font({ family = "MonaspiceKr NFM", weight = "Bold" }),
    font_size = 11.0,
  },
  window_decorations = "RESIZE",
  window_close_confirmation = "NeverPrompt",

  -- pane customization
  inactive_pane_hsb = {
    saturation = 1.0,
    brightness = 0.7,
  },

  -- enabled for hyprland
  enable_wayland = enable_wayland,
  adjust_window_size_when_changing_font_size = not enable_wayland,

  -- don't need a login shell
  default_prog = { "zsh" },

  -- don't do unnecessary things
  check_for_updates = false,

  -- disable warnings and sounds
  audible_bell = "Disabled",
  warn_about_missing_glyphs = false,

  -- don't need a scrollbar
  enable_scroll_bar = false,

  -- ime rules
  use_ime = true,
  ime_preedit_rendering = "Builtin",

  -- open debug overlay, select the preferred gpu; set to OpenGL otherwise
  front_end = "WebGpu",
  webgpu_preferred_adapter = GPUS[1],

  -- launch menu
  launch_menu = {
    {
      label = "btop",
      args = { "btop" },
    },
    {
      label = "GPU top",
      args = { "nvtop" },
    },
    {
      label = "zsh",
      args = { "zsh" },
    },
    {
      label = "nushell",
      args = { "nu" },
    },
    {
      label = "bash",
      args = { "bash", "-l" },
    },
    {
      label = "python",
      args = { "micromamba", "run", "ipython" },
    },
    {
      label = "utop",
      args = { "utop" },
    },
    {
      label = "node",
      args = { "node" },
    },
  },

  -- rules for hyperlink
  hyperlink_rules = {
    -- matches: a URL in parens: (URL)
    {
      format = "$1",
      highlight = 1,
      regex = [[\((\w+://\S+)\)]],
    },
    -- matches: a URL in brackets: [URL]
    {
      format = "$1",
      highlight = 1,
      regex = "\\[(\\w+://\\S+)\\]",
    },
    -- matches: a URL in curly braces: {URL}
    {
      format = "$1",
      highlight = 1,
      regex = [[\{(\w+://\S+)\}]],
    },
    -- matches: a URL in angle brackets: <URL>
    {
      format = "$1",
      highlight = 1,
      regex = [[<(\w+://\S+)>]],
    },
    -- matches: URLs not wrapped in brackets
    {
      format = "$1",
      highlight = 1,
      regex = "[^(]\\b(\\w+://\\S+[)/a-zA-Z0-9-]+)",
    },
    -- implicit mailto link
    {
      format = "mailto:$0",
      highlight = 0,
      regex = [[\b\w+@[\w-]+(\.[\w-]+)+\b]],
    },
    -- Github link
    {
      format = "https://github.com/$1/$3",
      highlight = 0,
      regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
    },
  },
}

return config
