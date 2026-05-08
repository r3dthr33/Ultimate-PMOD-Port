local t = Def.ActorFrame{}

t[#t+1] = Def.Quad{
	InitCommand=cmd(FullScreen;diffuse,color("0,0,0,1"));
}

t[#t+1] = Def.BitmapText{
	Font = "regen strong";
	Text = "FAILED";
	InitCommand=cmd(Center;zoom,1.7;diffuse,color("1,0.08,0.08,1");strokecolor,color("0,0,0,0.9");diffusealpha,0);
	OnCommand=cmd(sleep,0.08;diffusealpha,1;zoom,2.1;decelerate,0.18;zoom,1.7;sleep,0.85;linear,0.25;diffusealpha,0);
}

t[#t+1] = Def.Quad{
	InitCommand=cmd(FullScreen;diffuse,color("1,1,1,1"));
	OnCommand=cmd(linear,0.18;diffusealpha,0);
}

return t
