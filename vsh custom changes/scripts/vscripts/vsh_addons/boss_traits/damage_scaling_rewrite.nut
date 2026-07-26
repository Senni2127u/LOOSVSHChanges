//Script by Senni/Bradasparky.
// Just removes the damage scaling trait from Saxton, it causes confusion more than anything to players.
// No required modifications to base gamemode files.

function ReceivedDamageScalingTrait::OnDamageTaken(attacker, params) {}
function ReceivedDamageScalingTrait::OnTickAlive(timeDelta) {}
