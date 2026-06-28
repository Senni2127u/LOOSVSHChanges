AddListener("airblasted", 0, function (attacker, victim, params)
{
    if (attacker in characterTraits)
        foreach (characterTrait in characterTraits[attacker])
            try { characterTrait.OnAirblastOther.call(characterTrait, victim, attacker, params); }
            catch(e) { throw e; }

    if (victim in characterTraits)
        foreach (characterTrait in characterTraits[victim])
            try { characterTrait.OnAirblasted.call(characterTrait, victim, attacker, params); }
            catch(e) { throw e; }
});

class AirblastStunImmunity extends BossTrait {
  function OnAirblasted(victim, attacker, params) {
    victim.RemoveCond(TF_COND_AIR_CURRENT)
    victim.RemoveCond(TF_COND_LOST_FOOTING)
  }
}

AddBossTrait("saxton_hale", AirblastStunImmunity);