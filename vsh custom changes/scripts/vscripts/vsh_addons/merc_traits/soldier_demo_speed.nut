characterTraitsClasses.push(class extends CharacterTrait
{
    function CanApply()
    {
        local playerClass = player.GetPlayerClass();
        return player.GetPlayerClass() == TF_CLASS_SOLDIER || playerClass == TF_CLASS_DEMOMAN;
    }

function OnApply()
{
    local weapon = player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY);
    if (weapon)
    {
        local classname = weapon.GetClassname();
        if (classname != "tf_wearable")
        {
        if ((!WeaponIs(weapon, "libertylauncher")))
        {
           if ((!WeaponIs(weapon, "direct_hit"))) 
           {
                if ((!WeaponIs(weapon, "rocket_jumper"))) //If we don't disinclude this, it may mess with timings on Rocket Jumps
                {
                    weapon.AddAttribute("Projectile speed increased", 1.25, -1);
                }
           }
        }
        
        }
        if (WeaponIs(weapon, "loosecannon"))
        {
            weapon.AddAttribute("Projectile Speed increased", 1.45, -1) //Due to how TF2 handles physics, Loose Cannon tends to be slower than stock, compensating.
        }
    }
}
});