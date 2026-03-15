//todo currently it makes 1 entity per spy. could be better.
sapper_text <- CreateGameText({
    channel = 1,
    x = 0.781,
    y = 0.788
});

sapperCharge <- 100;
sapperEnt <- null;
inAttack <- 0;

AddTimer(-1, function()
{
    if (GetPropInt(self, "m_nButtons") & IN_ATTACK)
        inAttack = Time();
})

AddTimer(0.1, function()
{
    sapper_text.Display(format("Sapper∶ %d%%", sapperCharge), self);

    sapperCharge = clampCeiling(100, sapperCharge + 0.2);
    if (sapperCharge < 100)
        return;

    if (sapperEnt != null)
        for (local i = 0; i < 7; i++)
            if (!GetPropEntityArray(self, "m_hMyWeapons", i))
            {
                SetPropEntityArray(self, "m_hMyWeapons", sapperEnt, i);
                sapperEnt = null;
                break;
            }

    local sapper = self.GetActiveWeapon();
    if (!sapper || sapper.GetSlot() != 1)
    {
        foreach(boss in GetAlivePlayers(self.GetEnemyTeam()))
            boss.GetScriptScope().SendBlueprintRequest(self, null);
        return;
    }

    local myCenter = self.GetCenter();
    local forward = self.EyeAngles().Forward();
    foreach(boss in GetAlivePlayers(self.GetEnemyTeam()))
    {
        local deltaVector = boss.GetCenter() - myCenter;
        if (deltaVector.Norm() < 220 && forward.Dot(deltaVector) > 0.85)
        {
            if (Time() - inAttack <= 0.1)
            {
                if (boss.GetScriptScope().TryApplySapper(self, sapper))
                {
                    local switchTo = null;
                    for (local i = 0; i < 7; i++)
                    {
                        local weapon = GetPropEntityArray(self, "m_hMyWeapons", i);
                        if (!weapon)
                            continue;
                        local slot = weapon.GetSlot();
                        if (slot == 1)
                        {
                            sapperEnt = weapon;
                            SetPropEntityArray(self, "m_hMyWeapons", null, i);
                        }
                        if (slot == 2 || (slot == 0 && switchTo == null))
                            switchTo = weapon;
                    }
                    self.Weapon_Switch(switchTo);
                    sapperCharge = 0;
                }
            }
            else
                boss.GetScriptScope().SendBlueprintRequest(self, sapper);
        }
        else
            boss.GetScriptScope().SendBlueprintRequest(self, null);
    }
});

OnSelfEvent("clear_custom_character", function()
{
    SetPropString(sapper_text, "m_iszMessage", "");
    EntFireByHandle(sapper_text, "Display", "", -1, self, self);
    EntFireByHandle(sapper_text, "Kill", "", 0.1, self, self); //todo don't forget to delete when optimized
});