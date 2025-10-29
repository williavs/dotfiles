local wezterm = require('wezterm')
local M = {}

local cache_dir = wezterm.home_dir .. '/.config/wezterm/backgrounds/cache'
local current_bg_file = cache_dir .. '/current.jpg'

-- Ensure cache directory exists
local function ensure_cache_dir()
  os.execute('mkdir -p "' .. cache_dir .. '"')
end

-- Load images from JSON
local function load_images()
  local images_file = wezterm.home_dir .. '/.config/wezterm/backgrounds/images.json'
  local f = io.open(images_file, 'r')
  if not f then
    wezterm.log_error('Failed to open images.json')
    return {}
  end
  local content = f:read('*all')
  f:close()

  -- Parse JSON manually (Lua doesn't have native JSON)
  -- Extract URLs between quotes
  local images = {}
  for url in content:gmatch('"(https://[^"]+)"') do
    table.insert(images, url)
  end

  return images
end

-- Download image to cache (replaces previous)
local function download_image(url)
  ensure_cache_dir()

  -- Remove old cached image
  os.execute('rm -f "' .. current_bg_file .. '"')

  -- Download new image using curl
  local cmd = string.format('curl -s -o "%s" "%s"', current_bg_file, url)
  local result = os.execute(cmd)

  if result == 0 then
    return current_bg_file
  else
    wezterm.log_error('Failed to download image: ' .. url)
    return nil
  end
end

-- Get current date (YYYY-MM-DD format)
local function get_current_date()
  return os.date('%Y-%m-%d')
end

-- Get day of year (1-365/366)
local function get_day_of_year()
  return tonumber(os.date('%j'))
end

-- State file to track current selection and date
local state_file = wezterm.home_dir .. '/.config/wezterm/backgrounds/state.txt'

-- Read state (format: "date|index")
local function read_state()
  local f = io.open(state_file, 'r')
  if not f then
    return nil, nil
  end
  local content = f:read('*all')
  f:close()

  local date, index = content:match('([^|]+)|(%d+)')
  return date, tonumber(index)
end

-- Write state
local function write_state(date, index)
  local f = io.open(state_file, 'w')
  if f then
    f:write(date .. '|' .. index)
    f:close()
  end
end

-- Get daily image index (based on day of year)
local function get_daily_index(images)
  local day = get_day_of_year()
  return ((day - 1) % #images) + 1
end

-- Get current background image (returns local file path)
function M.get_current_image()
  local images = load_images()
  if #images == 0 then
    wezterm.log_error('No images found')
    return nil
  end

  local current_date = get_current_date()
  local saved_date, saved_index = read_state()

  local index_to_use
  -- If date has changed or no state exists, reset to daily image
  if saved_date ~= current_date then
    index_to_use = get_daily_index(images)
    write_state(current_date, index_to_use)
  elseif saved_index and saved_index >= 1 and saved_index <= #images then
    index_to_use = saved_index
  else
    index_to_use = get_daily_index(images)
    write_state(current_date, index_to_use)
  end

  -- Download the image and return local file path
  local url = images[index_to_use]
  local local_path = download_image(url)

  return local_path, index_to_use, #images
end

-- Set background to specific index
function M.set_background_index(index)
  local images = load_images()
  if #images == 0 then return nil end

  -- Wrap around
  if index < 1 then
    index = #images
  elseif index > #images then
    index = 1
  end

  local current_date = get_current_date()
  write_state(current_date, index)

  -- Download the image and return local file path
  local url = images[index]
  local local_path = download_image(url)

  return local_path, index, #images
end

-- Next background
function M.next_background()
  local _, current_index = read_state()
  if not current_index then
    current_index = 1
  end
  return M.set_background_index(current_index + 1)
end

-- Previous background
function M.prev_background()
  local _, current_index = read_state()
  if not current_index then
    current_index = 1
  end
  return M.set_background_index(current_index - 1)
end

-- Random background
function M.random_background()
  local images = load_images()
  if #images == 0 then return nil end

  math.randomseed(os.time())
  local random_index = math.random(1, #images)
  return M.set_background_index(random_index)
end

-- Reset to daily background
function M.reset_to_daily()
  local images = load_images()
  if #images == 0 then return nil end

  local current_date = get_current_date()
  local daily_index = get_daily_index(images)
  write_state(current_date, daily_index)

  -- Download the image and return local file path
  local url = images[daily_index]
  local local_path = download_image(url)

  return local_path, daily_index, #images
end

return M
