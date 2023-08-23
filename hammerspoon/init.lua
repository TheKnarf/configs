# https://github.com/szymonkaliski/hhann
local hhann  = require('hhann/hhann')
local module = {}

local ultra  = { 'ctrl', 'alt', 'cmd' }
local hotkey = hs.hotkey.modal.new(ultra, 'a')

function hotkey:entered()
  hhann.start()
  hhann.startAnnotating()
end

function hotkey:exited()
  hhann.stopAnnotating()
  hhann.hide()
end

hotkey:bind(ultra, 'c', function() hhann.clear()            end)
hotkey:bind(ultra, 'a', function() hotkey:exit()            end)
hotkey:bind(ultra, 't', function() hhann.toggleAnnotating() end)
