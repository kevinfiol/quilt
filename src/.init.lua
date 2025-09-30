require 'global'
local _ = require 'lib.lume'
local moon = require 'lib.fullmoon'
local util = require 'util'

local INTERVAL_REGEX = assert(re.compile([[^--interval=([0-9]+)$]]))
local ROWS_REGEX = assert(re.compile([[^--rows=([0-9]+)$]]))
local COLUMNS_REGEX = assert(re.compile([[^--columns=([0-9]+)$]]))
local DIR_REGEX = assert(re.compile([[^([/.].*)]])) -- match strings starting with `/`, `.` or `..`

local IMAGE_DIRS = {}
local ROWS = 3
local COLUMNS = 4
local INTERVAL = 2
local VIDEO_RATE=15

for i, v in ipairs(arg) do
  local match
  local value

  match, value = INTERVAL_REGEX:search(v)

  if match and value then
    INTERVAL = tonumber(value)
    goto continue
  end

  match, value = ROWS_REGEX:search(v)

  if match and value then
    ROWS = tonumber(value)
    goto continue
  end

  match, value = COLUMNS_REGEX:search(v)

  if match and value then
    COLUMNS = tonumber(value)
    goto continue
  end

  match, value = DIR_REGEX:search(v)

  if match then
    value = _.trim(value)

    if value == '' or value == nil then
      goto continue
    end

    if value:sub(1, 1) == '.' then
      -- relative path
      value = path.join(unix.getcwd(), value)
    end

    table.insert(IMAGE_DIRS, value)
  end

  ::continue::
end

if #IMAGE_DIRS < 1 then
  LogError('Must provide directory')
  unix.exit(1)
end

for _, dir in ipairs(IMAGE_DIRS) do
  if not path.isdir(dir) then
    LogError('Provided path is not a valid directory: ' .. dir)
    unix.exit(1)
  end

  ProgramDirectory(dir)
end

moon.setTemplate({ '/view/', tmpl = 'fmt' })
moon.setRoute('/', moon.serveIndex('/view/'))

moon.get('/', function (r)
  return moon.serveContent('index', {
    COLUMNS = COLUMNS,
    ROWS = ROWS,
    INTERVAL = INTERVAL
  })
end)

moon.get('/images', function (r)
  local images = {}

  -- note to self: so this works, but now this is a problem because the frontend uses relative paths
  -- because of the way ProgramDirectory works
  -- what if both folder /a and /b have files with the same names? /a/foo.jpg and /b/foo.jpg? /a/ will take precedence
  -- but /b/foo.jpg will never be considered
  for i, dir in ipairs(IMAGE_DIRS) do
    local results = util.getImages(dir)
    images = _.concat(images, results)
  end

  return moon.serveContent('json', { images = images })
end)

for _, v in ipairs(util.IMAGE_EXTENSIONS) do
  moon.get('/*.' .. v, moon.serveAsset)
end

for _, v in ipairs(util.VIDEO_EXTENSIONS) do
  moon.get('/*.' .. v, moon.serveAsset)
end

moon.run()