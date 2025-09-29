require 'global'
local moon = require 'lib.fullmoon'
local util = require 'util'

local INTERVAL_REGEX = assert(re.compile([[^--interval=([0-9]+)$]]))
local ROWS_REGEX = assert(re.compile([[^--rows=([0-9]+)$]]))
local COLUMNS_REGEX = assert(re.compile([[^--columns=([0-9]+)$]]))
local DIR_REGEX = assert(re.compile([[^(/.*)$]]))

local IMAGE_DIR = ''
local ROWS = 3
local COLUMNS = 4
local INTERVAL = 2
local VIDEO_RATE=15

for _, v in ipairs(arg) do
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
    IMAGE_DIR = value
  end

  ::continue::
end

if not IMAGE_DIR or IMAGE_DIR == '' then
  LogError('Must provide directory argument')
  unix.exit(1)
end

if not path.isdir(IMAGE_DIR) then
  LogError('Provided path is not a valid directory: ' .. IMAGE_DIR)
  unix.exit(1)
end

ProgramDirectory(IMAGE_DIR)

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
  local images = util.getImages(IMAGE_DIR)
  return moon.serveContent('json', { images = images })
end)

for _, v in ipairs(util.IMAGE_EXTENSIONS) do
  moon.get('/*.' .. v, moon.serveAsset)
end

for _, v in ipairs(util.VIDEO_EXTENSIONS) do
  moon.get('/*.' .. v, moon.serveAsset)
end

moon.run()