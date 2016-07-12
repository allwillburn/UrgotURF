local ver = "0.01"
if FileExist(COMMON_PATH.."MixLib.lua") then
 require('MixLib')
 LoadMixLib()
else
 PrintChat("MixLib not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua", function() Print("Update Complete, please 2x F6!") return end)
end

if GetObjectName(GetMyHero()) ~= "Urgot" then return end

require("OpenPredict")
require("DamageLib")

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        print("New version found! " .. data)
        print("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/allwillburn/UrgotURF/master/Urgot.lua", SCRIPT_PATH .. "Urgot.lua", function() print("Update Complete, please 2x F6!") return end)
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/allwillburn/UrgotURF/master/Urgot.version", AutoUpdate)


GetLevelPoints = function(unit) return GetLevel(unit) - (GetCastLevel(unit,0)+GetCastLevel(unit,1)+GetCastLevel(unit,2)+GetCastLevel(unit,3)) end
local skinMeta = {["Urgot"] = {"Classic", "Butcher Urgot", "Battlecast Urgot", "Giant Enemy Crabgot"}}
local SetDCP, SkinChanger = 0
local UrgotQ = {delay = .5, range = 1000, width = 80, speed = 1600}

local UrgotMenu = Menu("Urgot", "Urgot")

UrgotMenu:SubMenu("Combo", "Combo")

UrgotMenu.Combo:Boolean("Q", "Use Q in combo", true)
UrgotMenu.Combo:Slider("Qpred", "Q Hit Chance", 3,0,10,1)
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

UrgotMenu:SubMenu("Harass", "Harass")
UrgotMenu.Harass:Boolean("Q", "Use Q", true)
UrgotMenu.Harass:Boolean("E", "Use E", true)

UrgotMenu:SubMenu("KillSteal", "KillSteal")
UrgotMenu.KillSteal:Boolean("Q", "KS w Q", true)
UrgotMenu.KillSteal:Boolean("E", "KS w E", true)

UrgotMenu:SubMenu("AutoIgnite", "AutoIgnite")
UrgotMenu.AutoIgnite:Boolean("Ignite", "Ignite if killable", true)

UrgotMenu:SubMenu("Drawings", "Drawings")
UrgotMenu.Drawings:Boolean("DQ", "Draw Q Range", true)
UrgotMenu.Drawings:Boolean("DE", "Draw E Range", true)
UrgotMenu.Drawings:Boolean("DR", "Draw R Range", true)

UrgotMenu:SubMenu("SkinChanger", "SkinChanger")
UrgotMenu.SkinChanger:Boolean("Skin", "UseSkinChanger", true)
UrgotMenu.SkinChanger:Slider("SelectedSkin", "Select A Skin:", 1, 0, 4, 1, function(SetDCP) HeroSkinChanger(myHero, SetDCP)  end, true)

OnTick(function (myHero)
	local target = GetCurrentTarget()

	--AUTO LEVEL UP
	if UrgotMenu.URFMode.Level:Value() then

			spellorder = {_Q, _E, _W, _Q, _E, _R, _Q, _W, _W, _Q, _R, _Q, _W, _E, _E, _R, _E, _E}
			if GetLevelPoints(myHero) > 0 then
				LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
			end
	end
        
        --Harass
                if Mix:Mode() == "Harass" then
            if UrgotMenu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, 1000) then
		local QPred = GetPrediction(target,UrgotQ)
                       if QPred.hitChance > (UrgotMenu.Combo.Qpred:Value() * 0.1) and not QPred:mCollision(1) then
                                 CastSkillShot(_Q,QPred.castPos)
                       end		
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

        for _, enemy in pairs(GetEnemyHeroes()) do
                
                if IsReady(_Q) and ValidTarget(enemy, 900) and UrgotMenu.KillSteal.Q:Value() and GetHP(enemy) < getdmg("Q",enemy) then
		         CastSkillShot(_Q, enemy)
		
                end 

                if IsReady(_E) and ValidTarget(enemy, 1000) and UrgotMenu.KillSteal.E:Value() and GetHP(enemy) < getdmg("E",enemy) then
		         CastSkillShot(_E, target.pos)
  
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

OnDraw(function (myHero)
        
         if UrgotMenu.Drawings.DQ:Value() then
		DrawCircle(GetOrigin(myHero), 1000, 0, 200, GoS.Red)
	end

	if UrgotMenu.Drawings.DE:Value() then
		DrawCircle(GetOrigin(myHero), 900, 0, 200, GoS.Blue)
	end

	if UrgotMenu.Drawings.DR:Value() then
		DrawCircle(GetOrigin(myHero), 500, 0, 200, GoS.Green)
	end

end)

local function SkinChanger()
	if UrgotMenu.SkinChanger.UseSkinChanger:Value() then
		if SetDCP >= 0  and SetDCP ~= GlobalSkin then
			HeroSkinChanger(myHero, SetDCP)
			GlobalSkin = SetDCP
		end
        end
end


print('<font color = "#01DF01"><b>Urgot</b> <font color = "#01DF01">by <font color = "#01DF01"><b>Allwillburn</b> <font color = "#01DF01">Loaded!')

