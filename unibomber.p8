pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
-- game loop
function _init()
	if not cdcalled then
		cartdata("unib")
	end
	--dset(0,0)
	cdcalled=true
	highscore=max(dget(0),0)
	newhs=false
	palt(0,false)
	palt(15,true)
	cycle={s=3,x=10,y=15,r=5,l=0,fh=false,fv=false}
 bomb={x=0,y=0,s=1}
 parts={}
 tanks={}
	tanktrashtalk={"get him boys!","time to die!","fire!","die, son!","daddy's home","eat lead!","game over man!","gonna getcha!","yeeeehaw!"}
 missiles={}
 spawn_tank()
 score=0
	titlecard=""
	titlecardletters={"u","n","i","b","o","m","b","e","r"}
	titlecardindex=1
	titlecardletterx=18
	titlecardlettery=cycle.y+34
	newgamecol=0
	newgameblink=1
	gameovertext={"dude, ouch!","uni-bummer!","gotta hurt!","yikes dawg!","u blow'd up"}
	gameovertextidx=1
	gameoversprites={}
	gameoverexp=false
	gameovercount=0
 _update60=update_start
 _draw=draw_start
end

function update_start()
	if not musicplayed then
		music(0)
		musicplayed=true
	end
	if titlecardlettery == 64 and titlecardindex <= #titlecardletters then
		titlecard=titlecard..titlecardletters[titlecardindex]
		titlecardindex+=1
		titlecardlettery=cycle.y+34
		titlecardletterx=cycle.x+8
	elseif titlecardindex <= #titlecardletters then
		titlecardlettery+=0.5
	end
	cycle.x+=0.27
	if cycle.x >= 96 then
		cycle.x=96
	else
		cycle.s+=4
		if(cycle.s>7)cycle.s=3
	end

	if titlecardindex > #titlecardletters then
		local intrv=sin(newgameblink*.02)
		if intrv>0 then
			newgamecol=0
		else
			newgamecol=7
		end
		newgameblink+=1
		if btnp(4) or btnp(5) then
			_init()
			music(-1,500)
			_update60=update_game
		 _draw=draw_game
		end
	end
end

function update_game_over()
	if not gameoverexp then
		cycle_go_boom()
		gameoverexp=true
		gameovertextidx=flr(rnd(#gameovertext))+1
	end
	if score > highscore then
		newhs=true
		dset(0,score)
	end
	for cyclebit in all(gameoversprites) do
			if cyclebit.y < 120 then
				cyclebit.x+=cyclebit.sx
				if cyclebit.x < 1 then
					cyclebit.x+=128
				elseif cyclebit.x > 120 then
					cyclebit.x-=128
				end
				cyclebit.y+=cyclebit.sy
				if cyclebit.y > 120 then
					cyclebit.y=120
				end
				cyclebit.chft+=1
				if cyclebit.chft >= cyclebit.hfliptime then
					cyclebit.chft=0
					cyclebit.hf=not cyclebit.hf
				end
				cyclebit.cvft+=1
				if cyclebit.cvft >= cyclebit.vfliptime then
					cyclebit.cvft=0
					cyclebit.vf=not cyclebit.vf
				end
			end
	end
	if gameovercount > 180 then
		local intrv=sin(newgameblink*.02)
		if intrv>0 then
			newgamecol=0
		else
			newgamecol=7
		end
		newgameblink+=1
		if btnp(4) or btnp(5) then
			_init()
			_update60=update_game
		 _draw=draw_game
		end
	elseif gameovercount >= 0 then
		gameovercount += 1
	end
end

function update_game()
	if btn(0) then
		cycle.x-=1
		cycle.fh=true
		if(cycle.x<10)cycle.x=10
		cycle.s+=4
		if(cycle.s>7)cycle.s=3
	elseif btn(1) then
		cycle.x+=1
		cycle.fh=false
		if(cycle.x>96)cycle.x=96
		cycle.s+=4
		if(cycle.s>7)cycle.s=3
	end
	if btnp(4) and bomb.x==0 then
		bomb.x=cycle.x+4
		bomb.y=cycle.y+30
		sfx(0)
	end
	do_tanks()
	do_missiles()
	do_bomb()
end

function draw_start()
	cls(7)
	spr(cycle.s,cycle.x-4,cycle.y-4,4,4,cycle.fh,cycle.fv)
	line(1,35,cycle.x,45,cycle.l)
	line(cycle.x+1,45,128,35,cycle.l)
	if titlecardindex <= #titlecardletters then
		print("\^p "..titlecardletters[titlecardindex],titlecardletterx,titlecardlettery,0)
	else
		print("\^w by @2bitchuck",5,84,0)
		print("\^w ❎/🅾️ start",5,94,newgamecol)
		if highscore > 0 then
			print("\^w high score:"..highscore,5,114,0)
		end
	end
	print("\^p "..titlecard,5,64,0)
end

function draw_game_over()
	cls(7)
	print("\^wblow'd up:"..score,18,2,0)
	line(1,35,128,35,cycle.l)
	for i=1,#gameoversprites do
		spr(gameoversprites[i].spr,gameoversprites[i].x,gameoversprites[i].y,1,1,gameoversprites[i].hf,gameoversprites[i].vf)
	end
	if gameovercount > 180 then
		local gotxt=newhs and "★"..score.."★ bombed!" or gameovertext[gameovertextidx]
		local gotxtpos=newhs and 1 or 10
		local gotxty=newhs and 84 or 94
		print("\^w "..gotxt,gotxtpos+2,gotxty,0)
		if newhs then
			print("\^w new high score!",gotxtpos,gotxty+10,0)
			gotxty+=10
		end
		print("\^w ❎/🅾️ again",10,gotxty+10,newgamecol)
	end
	draw_particles()
end

function draw_game()
	cls(7)
	print("\^wblow'd up:"..score,18,2,0)
	if cycle.x > 0 then
		spr(cycle.s,cycle.x-4,cycle.y-4,4,4,cycle.fh,cycle.fv)
	end
	if bomb.x>0 then
		spr(bomb.s,bomb.x,bomb.y,2,2)
	end
	for m in all(missiles) do
		spr(m.s,m.x,m.y,2,2)
		for mp in all(m.mparts) do
			pset(mp.x,mp.y,mp.c)
		end
	end
	for tank in all(tanks) do
		spr(tank.s,tank.x,tank.y,2,2,tank.fh)
		if tank.ttc > 0 then
			if tank.sx < 0 then
				line(tank.x+7,tank.y-2,tank.x+3,tank.y-4,0)
			else
				line(tank.x+10,tank.y-2,tank.x+14,tank.y-4,0)
			end
			print(tanktrashtalk[tank.tt],tank.x+1,tank.y-10,0)
		end
	end
	if cycle.x < 0 then
		line(1,35,128,35,cycle.l)
	else
		line(1,35,cycle.x,45,cycle.l)
		line(cycle.x+1,45,128,35,cycle.l)
	end
	draw_particles()
end
-->8
--particle system
function explode(x,y)
 for i=1,40 do
	 local p={}
	 p.x=x
	 p.y=y
	 p.sx=(rnd()-0.5)*8
	 p.sy=(rnd()-0.5)*8
		p.l=rnd(3)
		p.z=1+rnd(8)
		p.ls=10+rnd(10)
		p.c=0
	 add(parts,p)
 end
 sfx(1)
end

function missile_fire(m)
	local mps={}
 for i=1,10 do
	 local mp={}
	 mp.x=(rnd()-0.5)*2+m.x+7
	 mp.y=rnd(5)+m.y+14
		mp.c=0
	 add(mps,mp)
 end
 m.mparts=mps
end

function draw_particles()
 for p in all(parts) do
  circfill(p.x,p.y,p.z,p.c)
  p.x+=p.sx
  p.y+=p.sy
  p.sx=p.sx/1.15
  p.sy=p.sy/1.15
  p.l+=1

  if p.l>p.ls then
   p.z-=0.5
   if p.z<0 then
    del(parts,p)
   end
  end
 end
end
-->8
-- helpers
function bomb_col(t)
	if mid(t.x-1,t.x+16,bomb.x+6)==bomb.x+6 and bomb.y>=96 then
		return true
	end

	return false
end

function missile_col(m)
	if mid(m.x+7,cycle.x,cycle.x+32)==m.x+7 and m.y<=cycle.y+32 then
		return true
	end

	return false
end

function cycle_go_boom()
	explode(cycle.x+16,cycle.y+24)
	local sprnums={4,5,20,21,36,37,52,53}
	for i=1,#sprnums do
		local cyclebit={}
		cyclebit.x=cycle.x
		cyclebit.sx=(rnd()-0.5)*3
		cyclebit.y=min((rnd()-0.5)*3 + cycle.y,cycle.y+0.5)
		cyclebit.sy=rnd(2)+0.5
		cyclebit.spr=sprnums[i]
		cyclebit.hfliptime=flr(rnd(15))+30
		cyclebit.vfliptime=flr(rnd(15))+30
		cyclebit.cvft=0
		cyclebit.chft=0
		cyclebit.hf=false
		cyclebit.vf=false
		add(gameoversprites,cyclebit)
	end
end

function spawn_tank()
	local tx=flr(rnd(6))+1
	local tsx=rnd(1)+0.2
	local tfh=false
	if tx%2==0 then
		tx=-20
	else
		tx=148
		tsx=-1*tsx
		tfh=true
	end
	local ttt=flr(rnd(#tanktrashtalk))+1
	local ttrash=(flr(rnd(9))+1)%3==0
	local t={x=tx,y=112,sx=tsx,s=11,timer=15,stoptimer=0,firet=flr(rnd(90))+90,fh=tfh,trash=ttrash,tt=ttt,ttc=0,tttimer=60}
	add(tanks,t)
end

function do_bomb()
	if bomb.x>0 then
		bomb.y+=1
		if bomb.y>=112 then
			for tank in all(tanks) do
				if bomb_col(tank) then
					del(tanks,tank)
					score+=1
					spawn_tank()
					if score%5==0 and #tanks<6 then
						spawn_tank()
					end
				end
			end
			explode(bomb.x+8,bomb.y-4)
			bomb.x=0
			bomb.y=0
		end
	end
end

function do_tanks()
	for tank in all(tanks) do
		tank.firet-=1
		if tank.firet<=0 and tank.trash and mid(tank.x,4,100)==tank.x then
			-- randomly determine trash talk
				tank.ttc+=1
				if tank.ttc >= tank.tttimer then
					tank.trash=false
					tank.tt=flr(rnd(#tanktrashtalk))+1
					tank.ttc=0
					tank.firet=1
				end
		elseif tank.firet==0 then
			tank.firet=flr(rnd(90))+90
			if mid(tank.x,4,100)==tank.x then
				tank.stoptimer=30
				tank_fire(tank)
			end
			tank.trash=(flr(rnd(9))+1)%3==0
		elseif tank.stoptimer>0 then
			tank.stoptimer-=1
		else
			tank.x+=tank.sx
			tank.timer-=1
			if tank.timer==0 then
				tank.s+=2
				tank.timer=15
			end
		end
		if(tank.s>13)tank.s=11
		if tank.x > 148 then
			tank.x=-17
		elseif tank.x < -20 then
			tank.x=129
		end
	end
end

function do_missiles()
	for m in all(missiles) do
		m.y-=m.sy
		m.sy*=1.03
		missile_fire(m)
		if missile_col(m) then
			explode(cycle.x+16,cycle.y+24)
			_update60=update_game_over
			_draw=draw_game_over
			del(missiles,m)
			return
		end
		if m.y<-16 then
			del(missiles,m)
		end
	end
end

function tank_fire(t)
	local m={}
	m.y=t.y-14
	m.x=t.x
	m.sy=0.3
	m.s=33
	m.mparts={}
	add(missiles,m)
	missile_fire(m)
end
__gfx__
00000000ffffffffffffffffffffffffffffff000fffffffffffffffffffffffffffff000fffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000fffffffffffffffffffffffffffff0fff0fffffffffffffffffffffffffff0fff0ffffffffffffffffffff00ffffffffffffff00ffffffff00000000
00700700fffffffffffffffffffffffffffff0fff0fffffffffffffffffffffffffff0fff0ffffffffffffffffffff00ffffffffffffff00ffffffff00000000
00077000ffffffffffffffffffffffffffffff000ffff0ffffffffffffffffffffffff000ffff0ffffffffffffffff00ffffffffffffff00ffffffff00000000
00077000ffff00ffff00fffffffffffffffffff0ffff00fffffffffffffffffffffffff0ffff00ffffffffffffffff00ffffffffffffff00ffffffff00000000
00700700fffff000000ffffffffffffffffffff0fff00ffffffffffffffffffffffffff0fff00ffffffffffffffff0000ffffffffffff0000fffffff00000000
00000000fffffff00ffffffffffffffff00000000000fffffffffffffffffffff00000000000fffffffffffffffff0000ffffffffffff0000fffffff00000000
00000000ffffff0000ffffffffffffff00fffff0ffffffffffffffffffffffff00fffff0fffffffffffffffffff0000000fffffffff0000000ffffff00000000
00000000ffffff0700ffffffffffffff0ffffff0ffffffffffffffffffffffff0ffffff0fffffffffffffffff00000000000fffff00000000000ffff00000000
00000000ffffff0070fffffffffffffffff000000000fffffffffffffffffffffff000000000fffffffffffff0000000000000fff0000000000000ff00000000
00000000ffffff0700ffffffffffffffff00000000000fffffffffffffffffffff00000000000ffffffffffff0000000000000fff0000000000000ff00000000
00000000ffffff0070ffffffffffffffff00000000000fffffffffffffffffffff00000000000ffffffffffff0000000000000fff0000000000000ff00000000
00000000ffffff0700fffffffffffffffff000000000fffffffffffffffffffffff000000000fffffffffffff00000000000fffff000000000000f0f00000000
00000000ffffff0000fffffffffffffffffffff0000ffffffffffffffffffffffffffff0000ffffffffffffff00f00f00f00f00ff00f00f00f00f00000000000
00000000ffffff0000fffffffffffffffffffff00000fffffffffffffffffffffffffff00000ffffffffffff0ff0ff0ff0ff0ff0000000000000000f00000000
00000000fffffff00ffffffffffffffffffffff0f0f0fffffffffffffffffffffffffff0f0f0ffffffffffff0f00f00f00f00f0ff00f00f00f00f00000000000
00000000fffffff00ffffffffffffffffffffff0f0f0fffffffffffffffffffffffffff0f0f0ffffffffffff0000000000000000000000000000000000000000
00000000ffffff0000fffffffffffffffffff00000f0fffffffffffffffffffffffff00000f0ffffffffffff0000000000000000000000000000000000000000
00000000ffffff0000fffffffffffffffff00ff0f000fffffffffffffffffffffff00ff0f000ffffffffffff0000000000000000000000000000000000000000
00000000ffffff0770ffffffffffffffff0ffff0f0f00fffffffffffffffffffff000ff0f0f00fffffffffff0000000000000000000000000000000000000000
00000000ffffff0070fffffffffffffff0f0fff0f0f0f0fffffffffffffffffff0ff0ff0f0f0f0ffffffffff0000000000000000000000000000000000000000
00000000ffffff0700fffffffffffffff0ff0ff0ff0ff0fffffffffffffffffff0ff00f0fffff0ffffffffff0000000000000000000000000000000000000000
00000000fffff000700fffffffffffff0ffff0f0f0ffff0fffffffffffffffff0ffff0f0f000000fffffffff0000000000000000000000000000000000000000
00000000fffff007700fffffffffffff0ffff0000fffff0fffffffffffffffff0ffff00000ffff0fffffffff0000000000000000000000000000000000000000
00000000ffff0f0000f0ffffffffffff0ffff0000000000fffffffffffffffff0ffff0000000000fffffffff0000000000000000000000000000000000000000
00000000ffff0f0000f0ffffffffffff0000000000ffff0fffffffffffffffff0000000000ffff0fffffffff0000000000000000000000000000000000000000
00000000fff0ff0000ff0fffffffffff0ffff00000ffff0fffffffffffffffff0fff000000ffff0fffffffff0000000000000000000000000000000000000000
00000000fff0ff0000ff0ffffffffffff0ff0ff0f0fff0fffffffffffffffffff0000ff000fff0ffffffffff0000000000000000000000000000000000000000
00000000ff0ffff00ffff0fffffffffff0f0fff0ff0ff0fffffffffffffffffff00ffff000fff0ffffffffff0000000000000000000000000000000000000000
00000000ff0ffffffffff0ffffffffffff0ffff0fff00fffffffffffffffffffff0ffff0f0f00fffffffffff0000000000000000000000000000000000000000
00000000fffffffffffffffffffffffffff00ff0ff00fffffffffffffffffffffff00ff0f000ffffffffffff0000000000000000000000000000000000000000
00000000fffffffffffffffffffffffffffff00000fffffffffffffffffffffffffff00000ffffffffffffff0000000000000000000000000000000000000000
__sfx__
000a00003c7313773134731307312d7312b7312773123731207311c73118731127310e7310a7310673117701137010d7010a70105701037000000000000000000000000000000000000000000000000000000000
010600000f654166531d654236512465121651186540e651066510165101651026510265102651026510265402641026410263101621016110060000600006000060000600006000060000600006000060000600
0110000010770007000e770007000c77000700187701877000000007000c77000700187701877000000007000c770007001877018770187701877018770187701877018770007000070000700007000000000000
011000001c220002001a2200020018220002002422224222000000020218220000002422224222000000020018220002002422224222242222422224222242222422224222002000020000200000000000000000
0110000018770007001a770007001b770007001c770007001a7700070018770007001c7721c772007000070018770007001a7701a770007000070018772187721877218772187721877218772187720070000700
011000002422000200262200020027220002002822000200262200020024220002002822228222000000000024220002002622026220000000000024222242222422224222242222422224222242220000000000
011008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 02034344
00 04054344
02 06424344
