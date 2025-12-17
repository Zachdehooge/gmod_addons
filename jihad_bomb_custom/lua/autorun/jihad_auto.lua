resource.AddFile("sound/testing.mp3");
resource.AddFile("materials/vgui/entities/weapon_jihadbomb.vtf");
resource.AddFile("materials/vgui/entities/weapon_jihadbomb.vmt")

sound.Add({
    name = "JihadBomb.Taunt",
    channel = CHAN_VOICE,
    volume = VOL_NORM,
    pitch = PITCH_NORM,
    soundlevel = SNDLVL_NORM,
    sound = { "vo/npc/male01/overhere01.wav", "vo/npc/male01/health03.wav", "vo/npc/male01/ammo04.wav" }
})
sound.Add({
    name = "JihadBomb.Detonate",
    channel = CHAN_VOICE,
    volume = VOL_NORM,
    pitch = PITCH_NORM,
    soundlevel = SNDLVL_NORM,
    sound = "JihadBomb/alala.wav"
})
sound.Add({
    name = "JihadBomb.Detonate2",
    channel = CHAN_VOICE,
    volume = VOL_NORM,
    pitch = PITCH_NORM,
    soundlevel = SNDLVL_NORM,
    sound = "testing.mp3"
})
