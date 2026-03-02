
EnvColor = EnvColor or {}


function EnvColor.getDayTimeInt()
	if EnvColor.isNight() then return 2 end
	if EnvColor.isDay() then return 1 end
	if RainManager.isRaining() then return 3 end
	return 0
end

function EnvColor.getDayTimeStr()
    local msg = ""
	if RainManager.isRaining() then
        msg = "isRaining"
	end
	if EnvColor.isNight() then msg = "isNight "..tostring(msg) end
	if EnvColor.isDay() then msg = "isDay "..tostring(msg)  end

	return tostring(msg)
end


function EnvColor.isDay()
	return forageSystem.getTimeOfDay() == 'isDay' and not RainManager.isRaining()
end

function EnvColor.isNight()
	return forageSystem.getTimeOfDay() == 'isNight' or RainManager.isRaining()
end
function EnvColor.setWorldColor(enable)
   local light = 0
   local intensity = 1
   local clim = getClimateManager()
   if not clim then return end

   local pl = getPlayer()
   if not pl then return end

   local csq = pl:getCurrentSquare()
   if not csq then return end

   local iR, iG, iB, iA = ParadiseZ.getCliColor(csq)
   local eR, eG, eB, eA = iR + 0.1, iG + 0.1, iB + 0.1, iA

   if enable then
      clim:getClimateFloat(intensity):setEnableAdmin(true)
      clim:getClimateColor(light):setEnableAdmin(true)

      if iA > 0 then
         clim:getClimateColor(light):setAdminValueInterior(iR, iG, iB, iA)
      end
      if eA > 0 then
         clim:getClimateColor(light):setAdminValueExterior(eR, eG, eB, eA)
      end
   else
      clim:getClimateFloat(intensity):setEnableAdmin(false)
      clim:getClimateColor(light):setEnableAdmin(false)
   end

   clim:transmitClientChangeAdminVars()
end
