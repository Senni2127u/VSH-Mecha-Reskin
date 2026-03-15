IncludeScript(MERC_SCRIPT_BASE);

local playerClass = self.GetPlayerClass();
if (playerClass <= 0 || playerClass > 9) //how did that happen?
    return;

if (playerClass == TF_CLASS_SPY)
    self.GetScriptScope().IncludeScript("/mercs/merc_traits/single_class/spy_sapper_weapon.nut");
