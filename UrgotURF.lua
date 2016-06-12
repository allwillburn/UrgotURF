if FileExist(COMMON_PATH.."MixLib.lua") then
 require('MixLib')
 LoadMixLib()
else
 PrintChat("MixLib not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua", function() Print("Update Complete, please 2x F6!") return end)
end

if GetObjectName(GetMyHero()) ~= "Urgot" then return end

require("OpenPredict")

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        PrintChat('<font color = "#00FFFF">New version found! ' .. data)
        PrintChat('<font color = "#00FFFF">Downloading update, please wait...')
        DownloadFileAsync('https://raw.githubusercontent.com/allwillburn/UrgotURF/master/UrgotURF.lua', SCRIPT_PATH .. 'UrgotURF.lua', function() PrintChat('<font color = "#00FFFF">Update Complete, please 2x F6!') return end)
    else
        PrintChat('<font color = "#00FFFF">No updates found!')
    end
end

local UrgotMenu = Menu("Urgot", "Urgot")

UrgotMenu:SubMenu("Combo", "Combo")

UrgotMenu.Combo:Boolean("Q", "Use Q in combo", true)
UrgotMenu.Combo:Boolean("W", "Use W in combo", true)
UrgotMenu.Combo:Boolean("E", "Use E in combo", true)
UrgotMenu.Combo:Boolean("R", "Use R in combo", true)

UrgotMenu:SubMenu("URFMode", "URFMode")
UrgotMenu.URFMode:Boolean("Level", "Auto level spells", true)
UrgotMenu.URFMode:Boolean("Ghost", "Auto Ghost", true)
UrgotMenu.URFMode:Boolean("Q", "Auto Q", true)
UrgotMenu.URFMode:Boolean("W", "Auto W", true)
UrgotMenu.URFMode:Boolean("E", "Auto E", true)

UrgotMenu:SubMenu("LaneClear", "LaneClear")
UrgotMenu.LaneClear:Boolean("Q", "Use Q", true)
UrgotMenu.LaneClear:Boolean("E", "Use E", true)
UrgotMenu.LaneClear:Slider("Mana", "if Mana % >", 30, 0, 80, 1)

UrgotMenu:SubMenu("Harass", "Harass")
UrgotMenu.Harass:Boolean("Q", "Use Q", true)
UrgotMenu.Harass:Boolean("E", "Use E", true)

UrgotMenu:SubMenu("KillSteal", "KillSteal")
UrgotMenu.KillSteal:Boolean("Q", "KS w Q", true)
UrgotMenu.KillSteal:Boolean("E", "KS w E", true)

UrgotMenu:SubMenu("AutoIgnite", "AutoIgnite")
UrgotMenu.AutoIgnite:Boolean("Ignite", "Ignite if killable", true)



OnTick(function (myHero)
	local target = GetCurrentTarget()
	--AUTO LEVEL UP
	if UrgotMenu.URFMode.Level:Value() then
			spellorder = {_Q, _W, _E, _Q, _W, _R, _Q, _W, _W, _Q, _R, _Q, _W, _E, _E, _R, _E, _E}
			if GetLevelPoints(myHero) > 0 then
				LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
			end
	end
        
        --Harass
                if Mix:Mode() == "Harass" then
            if UrgotMenu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, 1000) then
				CastSkillShot(_Q, target)
                        end
            if UrgotMenu.Harass.E:Value() and Ready(_E) and ValidTarget(target, 900) then
				CastSkillShot(_E, target.pos)
                        end
               end
	--COMBO
		if Mix:Mode() == "Combo" then
            if UrgotMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, 1000) then
				CastSkillShot(_Q, target)
                        end	    
	    if UrgotMenu.Combo.W:Value() and Ready(_W) then
				CastSpell(_W)
	                end
	    if UrgotMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, 900) then
				CastSkillShot(_E, target.pos)
			end
	    
            if UrgotMenu.Combo.R:Value() and Ready(_R) and ValidTarget(target, 500) then
				CastTargetSpell(target, _R)
			end
		end

         --AUTO IGNITE
	for _, enemy in pairs(GetEnemyHeroes()) do
		
		if GetCastName(myHero, SUMMONER_1) == 'SummonerDot' then
			 Ignite = SUMMONER_1
			if ValidTarget(enemy, 600) then
				if 20 * GetLevel(myHero) + 50 > GetCurrentHP(enemy) + GetHPRegen(enemy) * 3 then
					CastTargetSpell(enemy, Ignite)
				end
			end

		elseif GetCastName(myHero, SUMMONER_2) == 'SummonerDot' then
			 Ignite = SUMMONER_2
			if ValidTarget(enemy, 600) then
				if 20 * GetLevel(myHero) + 50 > GetCurrentHP(enemy) + GetHPRegen(enemy) * 3 then
					CastTargetSpell(enemy, Ignite)
				end
			end
		end

	end

      --KillSteal
      if Mix:Mode() == "KillSteal" then
         if UrgotMenu.KillSteal.Q:Value() and Ready(_Q) and ValidTarget(enemy,1000) and GetHP(enemy) < getdmg("Q",enemy) then  
                            CastSkillShot(_Q, enemy)
          end              

	 if UrgotMenu.KillSteal.E:Value() and Ready(_E) and ValidTarget(enemy,900) and GetHP2(enemy) < getdmg("E",enemy) then
                            CastTargetSpell(_E, enemy)
	  end
  
      end

      if Mix:Mode() == "LaneClear" then
      	  for _,closeminion in pairs(minionManager.objects) do
	        if UrgotMenu.LaneClear.Q:Value() and Ready(_Q) and ValidTarget(closeminion, 1000) then
	        	CastSkillShot(_Q, closeminion)
	        end
                if UrgotMenu.LaneClear.E:Value() and Ready(_E) and ValidTarget(closeminion, 900) then
	        	CastSkillShot(_E, closeminion)
	        end
      	  end
      end
        --URFMode
        if UrgotMenu.URFMode.Q:Value() then        
          if Ready(_Q) and ValidTarget(target, 1000) then
						CastSkillShot(_Q, target)
          end
        end 
        if UrgotMenu.URFMode.W:Value() then        
          if Ready(_W) then
	  	      CastSpell(_W)
          end
        end
        if UrgotMenu.URFMode.E:Value() then        
	        if Ready(_E) and ValidTarget(target, 900) then
						CastSkillShot(_E, target)
	        end
        end
                
	--AUTO IGNITE
	if UrgotMenu.URFMode.Ghost:Value() then
		if GetCastName(myHero, SUMMONER_1) == "SummonerHaste" and Ready(SUMMONER_1) then
			CastSpell(SUMMONER_1)
		elseif GetCastName(myHero, SUMMONER_2) == "SummonerHaste" and Ready(SUMMONER_2) then
			CastSpell(Summoner_2)
		end
	end
end)

print('<font color = "#01DF01"><b>UrgotURF</b> <font color = "#01DF01">by <font color = "#01DF01"><b>Allwillburn</b> <font color = "#01DF01">Loaded!')

