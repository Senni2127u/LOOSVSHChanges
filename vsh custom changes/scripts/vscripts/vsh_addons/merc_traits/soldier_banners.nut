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
});
