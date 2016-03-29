-- Author      : Kaminari
-- Create Date : 13:03 2015-04-20

-- Spells
local _ExecutionSentence = 114157;
local _FinalVerdict = 157048;
local _DivineStorm = 53385;
local _HammerofWrath = 24275;
local _CrusaderStrike = 35395;
local _Judgment = 20271;
local _Exorcism = 879;
local _AvengingWrath = 31884;
local _Seraphim = 152262;
local _TemplarVerdict = 85256;

-- Auras
local _EmpoweredDivineStorm = 174718;
local _DivineCrusader = 144595;

-- Talents
local _isFinalVerdict = false;
local _isSeraphim = false;

----------------------------------------------
-- Pre enable, checking talents
----------------------------------------------
TDDps_Paladin_CheckTalents = function()
	_isFinalVerdict = TD_TalentEnabled('Final Verdict');
	_isSeraphim = TD_TalentEnabled('Seraphim');
	-- other checking functions
end

----------------------------------------------
-- Enabling Addon
----------------------------------------------
function TDDps_Paladin_EnableAddon(mode)
	mode = mode or 1;
	_TD["DPS_Description"] = "TD Paladin DPS supports: Retribution";
	_TD["DPS_OnEnable"] = TDDps_Paladin_CheckTalents;
	if mode == 1 then
		_TD["DPS_NextSpell"] = TDDps_Paladin_Holy;
	end;
	if mode == 2 then
		_TD["DPS_NextSpell"] = TDDps_Paladin_Protection;
	end;
	if mode == 3 then
		_TD["DPS_NextSpell"] = TDDps_Paladin_Retribution;
	end;
	TDDps_EnableAddon();
end

----------------------------------------------
-- Main rotation: Holy
----------------------------------------------
TDDps_Paladin_Holy = function()
	local timeShift, currentSpell = TD_EndCast();

	return _Spell;
end

----------------------------------------------
-- Main rotation: Protection
----------------------------------------------
TDDps_Paladin_Protection = function()
	local timeShift, currentSpell = TD_EndCast();

	return _Spell;
end

----------------------------------------------
-- Main rotation: Retribution
----------------------------------------------
TDDps_Paladin_Retribution = function()
	local timeShift, currentSpell = TD_EndCast();
	local gcd = TD_GlobalCooldown();

	local holyPower = UnitPower('player', SPELL_POWER_HOLY_POWER);
	local finalVerdict = TD_Aura(_FinalVerdict, timeShift);
	local avAura = TD_Aura(_AvengingWrath, timeShift);
	local eds = TD_Aura(_EmpoweredDivineStorm, timeShift);
	local ds = TD_Aura(_DivineCrusader, timeShift);
	local es = TD_SpellAvailable(_ExecutionSentence, timeShift);
	local how = TD_SpellAvailable(_HammerofWrath, timeShift);
	local av = TD_SpellAvailable(_AvengingWrath, timeShift);
	local cs, csCD = TD_SpellAvailable(_CrusaderStrike, timeShift);
	local j, jCD = TD_SpellAvailable(_Judgment, timeShift);
	local e, eCD = TD_SpellAvailable(_Exorcism, timeShift);
	local targetPh = TD_TargetPercentHealth();
	local sera, seraCd = TD_SpellAvailable(_Seraphim, timeShift);
	TDButton_GlowCooldown(_AvengingWrath, av);

	if _isSeraphim then
		if seraCd < gcd and holyPower >= 5 then
			return _Seraphim;
		end
	end

	if finalVerdict and holyPower >= 4 and (eds or ds) then
		return _DivineStorm;
	end

	if holyPower >= 5 then
		if _isSeraphim then
			if seraCd > 4 * gcd then
			return _TemplarVerdict;
			end
		else
			return _TemplarVerdict;
		end
	end

	if es then
		return _ExecutionSentence;
	end

	if (targetPh <= 0.35 or avAura) and how then
		return _HammerofWrath;
	end

	if cs then
		return _CrusaderStrike;
	end

	if j then
		return _Judgment;
	end

	if e then
		return _Exorcism;
	end

	if holyPower >= 3 then
		if _isSeraphim then
			if seraCd > 8 * gcd then
				return _TemplarVerdict;
			end
		else
			return _TemplarVerdict;
		end
	end

	if eds or ds then
		return _DivineStorm;
	end

	if csCD < jCD and csCD < eCD then
		return _CrusaderStrike;
	end

	if jCD < csCD and jCD < eCD then
		return _Judgment;
	end

	if eCD < csCD and eCD < jCD then
		return _Exorcism;
	end

	return _CrusaderStrike;
end