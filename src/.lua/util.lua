local _ = require 'lib.lume'

local IMAGE_EXTENSIONS = { 'png', 'jpeg', 'jpg', 'gif', 'webp', 'bmp' }

local function getImages(dir, images, current_path)
  if not path.isdir(dir) then
    error('Must specify an images directory')
  end

  images = images or {}
  current_path = current_path or ''

  for name, kind in assert(unix.opendir(dir)) do
    local ext = _.split(name, '.')[2]
    local is_image = _.find(IMAGE_EXTENSIONS, ext) ~= nil

    if name ~= '.' and name ~= '..' then
      local full_path = path.join(dir, name)
      local rel_path = path.join(current_path, name)

      if kind == unix.DT_REG and is_image then
        table.insert(images, rel_path)
      elseif kind == unix.DT_DIR then
        getImages(full_path, images, rel_path)
      end
    end
  end

  return images
end

return {
  getImages = getImages,
  IMAGE_EXTENSIONS = IMAGE_EXTENSIONS
}