local white_list = {"easyprofit3", "Bumer_32"}


local event = require("event").pull
local com = require('component')
local gpu = com.gpu

if not com.isAvailable("os_entdetector") then
  error("нет сенсора entity detector")
end

local sensor = {}
for address in com.list("os_entdetector") do
  table.insert(sensor,com.proxy(address))
end

local resX, resY = gpu.getResolution()

for i = 1,#white_list do
  white_list[white_list[i]] = true
end
 
local function detector()
  gpu.fill(1,1,35,15," ")
  local count = 0
  local users = {}
  for i = 1,#sensor do
    local pl = sensor[i].scanPlayers(64)
    for j = 1,#pl do
      if not users[pl[j].name] then
        users[pl[j].name] = true
        if not white_list[pl[j].name] then 
          count = count + 1          
          gpu.setForeground(0xFF0000)
          gpu.set(2, count+1, count..'. '..pl[j].name)          
          if com.isAvailable("particle") then
            for i = 1, 5 do
              com.particle.spawn("lava", pl[j].x - 1, pl[j].y, pl[j].z)
            end
          end
        end 
      end
    end
  end
  gpu.setForeground(0xFFB600)          
  gpu.set(2,1, 'В зоне обнаружения радара '..count..' чел.')          
end

gpu.setResolution(35,15)

while true do
  pcall(detector)
  local e = {event(1,"key_down")}
  if e[4] == 29 then
    gpu.setResolution(resX, resY)
    gpu.setBackground(0x000000)
    gpu.setForeground(0xffffff)
    os.execute("cls")
    break
  end
end