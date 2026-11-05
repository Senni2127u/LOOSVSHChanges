// Script by: Delfite.
// This script houses constants that are not already included in the normal `constants.nut`.
// This script was created due to an issue where overriding `constants.nut` would cause the
// mercs and Hale to be on the wrong teams for certain maps.


foreach (c in [
    Constants.EHudNotify,
    Constants.EScriptRecipientFilter,
    Constants.ESolidType,
    Constants.ESpectatorMode,
    Constants.Math,
    Constants.ERoundState,
    Constants.ERenderMode,
    Constants.ERenderFx,
    Constants.EMoveType,
    Constants.EMoveCollide,
    Constants.EHoliday,
    Constants.EHitGroup,
    Constants.ECritType,
    Constants.ECollisionGroup//,
	// Delfite: Script fails to include if these constants are uncommented.
    // Constants.TFCOLLISION_GROUP,
    // Constants.SND,
    // Constants.TF_STUN,
    // Constants.TF_DEATH,
    // Constants.TF_AMMO
])
    foreach (k, v in c)
        getroottable()[k] <- v;