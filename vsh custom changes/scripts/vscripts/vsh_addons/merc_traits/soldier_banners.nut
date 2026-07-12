//Copyright: Delfite/Senni
// Responsible for fixing Batallion Backup's resistance on Saxton Hale's abilities, gives all Banners a charge over time.
// No modification to weapons.nut required.

characterTraitsClasses.push(class extends CharacterTrait
{
    function OnDamageTaken(attacker, params) //Batallion's Backup
    {
        if (IsValidBoss(attacker))
        {
            if ((params.damage_type & (DMG_CLUB))) //Ignore Saxton's normal hits, the game already handles the resistance.
            {
            return;
            }

            foreach (player in GetAliveMercs())
            if (player.InCond(TF_COND_DEFENSEBUFF))
            {
                params.damage *= 0.65
                //printl("damage resisted on merc") //Debug to make sure resistance is applied
            }
        }
    }

function ChargeSoldierBanners() //Over the time charge with all Banners.
{
    foreach (player in GetAliveMercs())
    {
        if (player.GetPlayerClass() != TF_CLASS_SOLDIER)
            continue;

        local banner = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);

        if (!banner)
            continue;

        local classname = banner.GetClassname();

        // Only affect banners
        if (classname != "tf_weapon_buff_item") //Instead of adding an entry to weapons.nut, we will just check the classname.
            continue;

        if (player.GetRageMeter() < 100) //Stop charging it once at full, because that's a waste.
        {
        player.SetRageMeter(clampCeiling(100, player.GetRageMeter() + 0.13)); //60 Seconds.
        //printl(player.GetRageMeter())
        }
    }
}

function StartBannerRecharge()
{
    RunWithDelay2(this, 1.0, function()
    {
        ChargeSoldierBanners();
        StartBannerRecharge();
    });
}

function OnApply()
{
StartBannerRecharge();
}

});
