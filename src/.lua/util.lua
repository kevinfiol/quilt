local _ = require 'lib.lume'

local IMAGE_EXTENSIONS = { 'png', 'jpeg', 'jpg', 'gif', 'webp', 'bmp' }
local VIDEO_EXTENSIONS = { 'mp4', 'webm', 'mkv' }

local VIDEO_RATE_REGEX = assert(re.compile([[^--video-rate=([0-9]+)$]]))
local VIDEO_RATE = 15

for _, v in ipairs(arg) do
  local match
  local value
  match, value = VIDEO_RATE_REGEX:search(v)

  if match then
    VIDEO_RATE = tonumber(value)
  end
end

local function getExt(path)
  local parts = _.split(path, '.')
  return parts[#parts] or ''
end

local function getImages(dir, images, current_path)
  if not path.isdir(dir) then
    error('Must specify an images directory')
  end

  images = images or {}
  current_path = current_path or ''
  images[dir] = {}

  for name, kind in assert(unix.opendir(dir)) do
    local ext = getExt(name)
    local is_image = _.find(IMAGE_EXTENSIONS, ext) ~= nil
    local is_video = _.find(VIDEO_EXTENSIONS, ext) ~= nil

    if name ~= '.' and name ~= '..' then
      local full_path = path.join(dir, name)
      local rel_path = path.join(current_path, name)

      if kind == unix.DT_REG and (is_image or is_video) then
        if is_image then
          table.insert(images[dir], rel_path)
        elseif is_video then
          for i = 1, math.max(VIDEO_RATE, 0) do
            table.insert(images[dir], rel_path)
          end
        end
      elseif kind == unix.DT_DIR then
        getImages(full_path, images, rel_path)
      end
    end
  end

  return images
end

return {
  getImages = getImages,
  IMAGE_EXTENSIONS = IMAGE_EXTENSIONS,
  VIDEO_EXTENSIONS = VIDEO_EXTENSIONS
}