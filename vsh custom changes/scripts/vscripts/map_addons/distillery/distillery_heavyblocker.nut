PrecacheSound("vo/heavy_No01.mp3")
PrecacheSound("vo/heavy_No02.mp3")
PrecacheSound("vo/heavy_No03.mp3")

::heavy_no <- [
	"vo/heavy_No01.mp3",
	"vo/heavy_No02.mp3",
	"vo/heavy_No03.mp3",
]

if (GetMapName().find("vsh_distillery") == 0)
{
	local heavy = SpawnEntityFromTable("prop_dynamic_override",
	{
		origin = "1344 -1910 300"
		angles = "0 315 0"
		model = "models/props_training/target_heavy.mdl"
		solid = 6
		health = 9999999
	})

	heavy.ConnectOutput("OnTakeDamage", "OnTakeDamage");
	heavy.ValidateScriptScope();
	local scope = heavy.GetScriptScope();
	scope.last_no_time <- 0.0;
	scope.OnTakeDamage <- function()
	{
		local level = (40 + (20 * log10(5000 / 36.0))).tointeger();
		if (Time() > last_no_time)
		{
			local no = heavy_no[RandomInt(0, 2)];
			EmitSoundEx(
			{
				sound_name = no
				sound_level = 75
				entity = self,
			})
			last_no_time = Time() + 10.0;
		}
	}
}