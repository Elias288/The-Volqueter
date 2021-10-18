pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
function make_actor(sp, x, y, w, h, flp)
	--sprite, x, y, ancho, halto, direccion
	local a = {
		sp=sp,
		x=x, y=y,
		h=h, w=w,
		dx=0, dy=0,
		flp=flp, --false:derecha true:izquierda
		acc=0.5,  --aceleracion
		boost=4,  --salto
		anim=0,
		vida=2, -- vida y golpes
		golp=false,
		junmping=false,
		running=false,
		landed=false,
		falling=false,
		sliding=false,
		s=estados.idle,
		draw=draw_actor,
		move=move_actor,
	}

	if(fget(sp,7)) then
		a.is_monster=true
		a.move=move_monster
	end

	return a
end
estados = {
	idle=0,
	fight=1,
	punch=2,
	dead=4
}
function make_player(sp, x, y)
	flp=false
	local a = make_actor(sp, x, y, 16, 16, flp)

	a.is_player=true
	a.carrosa=dibujar_carrosa
	a.spc=33 			--carrosa
	a.score=0
	a.id=0

	return a
end
function colision (a, b)
	local box_a = abs_box(a) -- a seria el maxi 
	local box_b = abs_box(b) -- b seria berni

	if box_a.x > box_b.w or
				box_a.y > box_b.h or
				box_b.x > box_a.w or
				box_b.y > box_a.h then
		return false
	end
	
	return true
end
function add_estado (e, estado)
	e.s |= estado
end

function del_estado (e, estado)
	e.s &= ~estado
end

function has_estado (e, estado)
	return estado == 0 or e.s & estado != 0
end

function ctrl_ia (e)
 -- colision con el jugador
 manuelito=1
 	if colision(e,player) then
 		manuelito=2
 		-- si colisiona, se pone a
 		-- pelear
 		e.s = estados.fight
 		
 		-- si el jug esta punch
 		if has_estado(player, estados.punch) then
 			-- si esta con el puno extendido
 			if player.sp == 5 or player.sp == 7  then
 				if not e.golp then
	 				e.vida -= 1
 					e.golp = true
 				end
 			else
 				e.golp = false
 			end
 		else
 			e.golp = false
 		end
 	end
 	
 	-- verifico vida
 	if e.vida <= 0 then
 	 if e.s != estados.dead then
 	 	e.s = estados.dead
 	 	e.sp = 203
 	 end
 	 
 		e.vida = 0
 	end
 
 
 if e.s == estados.idle  then
 	-- estado normal
 	-- - caminar aleatoriamente
 	local acel = 1
 	--manuelito="porque no estas caminando bebe"
 	if e.dx < 0.01 then
 	 -- un dado de 4 lados
 	 -- porque quiero elegir entre
 	 -- 4 direcciones
 	 local dir=rnd(2)
 	 
 	 if (dir < 2) then
 	 	-- mover horiz
 	 	acel *= dir < 1 and -1 or 1
 	 	
 	 	e.dx += acel
 	 else
 	 	-- mover horiz
 	 	acel *= dir < 3 and -1 or 1
 	 	
 	 	e.dy += acel
 	 end
 	end	
 elseif has_estado(e, estados.fight) then
 -- peleando
 -- - perseguir al jugador
 	acel = 0.2
 	
 	if (player.x > e.x) e.dx += acel
 	if (player.x < e.x) e.dx -= acel
 	
 end

end
function update_ent (e)
	ctrl_ia(e)
end
function abs_box (e)
 local box = {}
 
 box.x = e.x
 box.y = e.y
 box.w = e.x + e.w
 box.h = e.y + e.h
 
 return box
end
function _init()

	player = make_player(1, 10, 40)
	maxi = make_actor(192, 120, 40, 16, 16, true)
	manuelito=0
	gravity=0.3
	friccion=0.85

	tiempo=0
	
	palt(0, false)
	palt(7, true)

	cam_x=0
	map_start=0
	map_end=1024

	--test--
	x1r=0 y1r=0
	x2r=0 y2r=0
	collide_l="no"
	collide_r="no"
	collide_u="no"
	collide_d="no"

	-------------
	music(0)
end

function _update()
	tiempo += 1

	player_update()
	--animate()
	update_ent(maxi)
	player_animate()

	cam_x=player.x-64+(player.w/2)
	if cam_x<map_start then
		cam_x=map_start
	end
	if cam_x>map_end-128 then
		cam_x=map_end-128
	end
	camera(cam_x,0)
end

function _draw()
	cls()
	
	--camera(0,0)
	map()
	--dibujar_player(player)
	player:draw()
	player:carrosa()
	--dibujar_maxi(maxi)
	maxi:draw()

	--dibujar_carrosa(player)
	--caminar(50, 35)

	rect(x1r,y1r,
		x2r,y2r,7)
	print("⬅️= "..collide_l,player.x,player.y-10)
	print("➡️= "..collide_r,player.x,player.y-16)
	print("⬆️= "..collide_u,player.x,player.y-22)
	print("⬇️= "..collide_d,player.x,player.y-28)
	print("manuelito="..manuelito,player.x,player.y-32)
end

-->8

function draw_actor(a)
	local fr=a.sp

	sspr(
		(a.sp%16)*8,
		(a.sp\16)*8,
		a.w, --ancho
		a.h, --alto
		a.x, --x
		a.y, --y
		a.w, -- no se ancho
		a.h, -- no se alto
		a.flp --flip
	)
end


function dibujar_carrosa(obj)
	local c_x, c_flp

	if obj.flp then --izquierda
		c_x = obj.x+16
	else	--derecha
		c_x = obj.x-16
	end

	sspr(
		(obj.spc%16)*8,
		(obj.spc\16)*8,
		obj.w, --ancho
		obj.h, --alto
		c_x, --x
		obj.y, --y
		obj.w, -- no se ancho
		obj.h, -- no se alto
		obj.flp --flip
		)
end

function player_animate()
	if player.junmping then
		player.sp=3
		player.spc=33
	elseif player.falling then
		player.sp=1
		player.spc=33
	elseif player.running then
		if time()-player.anim>.1 then
			player.anim=time()
			player.sp+=2
			player.spc+=2
			if player.sp>=4 then
				player.sp=1
				player.spc=33
			end
		end
	--elseif time()-player.anim>.3 then
		--player.spb=2
	end
end

function player_update()
	--physics
	player.dy+=gravity
	player.dx*=friccion

	--controls
	if btn(➡️) then
		player.dx+=player.acc
		player.running=true
		player.flp=false
	end
	if btn(❎) and player.landed then
		player.dy-=player.boost
		player.landed=false
	end
	if btn(⬅️) then
		player.dx-=player.acc
		player.flp=true
		player.running=true
	end

	if player.running 
		and not btn(➡️)
		and not btn(⬅️)
		and not player.falling
		and not player.junmping then
			player.running=false
			player.sliding=true
		end

		if player.dy>0 then
			player.falling=true
			player.landed=false
			player.junmping=false

			if map_collide(player, "down", 0) then
				player.landed=true
				player.falling=false
				player.dy=0
				player.y-=((player.y+player.h+1)%8)-1

				--test--
				collide_d="yes"
				else collide_d="no"
				----
			end
		elseif player.dy<0 then
			player.junmping=true
			if map_collide(player, "up", 1) then
				player.dy=0
					--test--
				collide_u="yes"
				else collide_u="no"
				----
			end
		end

		if player.dx<0 then
			if map_collide(player, "left", 1) then
				player.dx=0
					--test--
				collide_l="yes"
				else collide_l="no"
				----
			end
		elseif player.dx>0 then
			if map_collide(player, "right", 1) then
				player.dx=0
					--test--
				collide_r="yes"
				else collide_r="no"
				----
			end
		end

		if player.sliding then
			if abs(player.dx) <.2
			or player.running then
				player.dx=0
				player.sliding=false
			end
		end

		player.x+= player.dx
		player.y+= player.dy
  --limit player to map
  if player.x<map_start then
  	player.x=map_start
  end
  if player.x>map_end-player.w then
  	player.x=map_end-player.w
  end
end
-->8
function map_collide(obj, dir, flag)
	local x=obj.x
	local y=obj.y
	local h=obj.h
	local w=obj.w

	local x1=0 local y1=0
	local x2=0 local y2=0

	if dir=="left" then
		x1=x+4 
		x2=x+4 
		y1=y
		y2=y+h-1
	elseif dir=="right" then
		x1=x+w-5 
		x2=x+w-5
		y1=y 
		y2=y+h-1
	elseif dir=="up" then
		x1=x+2
		x2=x+w-9
		y1=y-1
		y2=y
	elseif dir=="down" then
		x1=x+5
		x2=x+w-5
		y1=y+h
		y2=y+h
	end
	--test--
	x1r=x1 y1r=y1
	x2r=x2 y2r=y2
	------
	--pixels to tiles
	x1/=8
	x2/=8
	y1/=8
	y2/=8

	if fget(mget(x1,y1), flag)
		or fget(mget(x1,y2), flag)
		or fget(mget(x2,y1), flag)
		or fget(mget(x2,y2), flag) then
		return true
	else
		return false
	end
end

__gfx__
0000000077777777777777777777777777777777777777777777777777777777777777770000000000000000000000000000000000000000aaaaaaaaaaaaaaaa
0000000077777711177777777777771117777777777777111777777777777711177777770000000000000000000000000000000000000000aaaaaaaaaaaaaaaa
0070070077777111117777777777711111777777777771111177777777777111117777770000000000000000000000000000000000000000aaaaaaaaaaaa499a
0007700077777111111177777777711111117777777771111111777777777111111177770000000000000000000000000000000000000000aaaaaaaaaa94499a
00077000777777ff64777777777777ff64777777777777ff64777777777777ff647777770000000000000000000000000000000000000000aaaaaaaaa99449aa
00700700777777fffff77777777777fffff77777777777fffff77777777777fffff777770000000000000000000000000000000000000000aaaaaaa9999449ad
00000000777777ffff777777777777ffff777777777777ffff777777777777ffff7777770000000000000000000000000000000000000000aaaaaa9999944aad
00000000777777ccc3777777777777ccc3777777777777ccc3777777777777ccc37777770000000000000000000000000000000000000000aaaaa99999944add
0000000077777ccc3377777777777ccc3377777777777ccc3347777777777ccc337747770000000000000000000000000000000000000000aaa9999999944ddd
00000000444fccc333cff777444fccc333777777444fccc333466666444fccc333ff46660000000000000000000000000000000000000000aa99999999944ddd
0000000044ffcc3333cff77744ffcc333377777744ffcc333346666744ffcc3333ff466600000000000000000000000000000000000000009999999999944ddd
00000000777777333377777777777733337777777777773333477777777777333377477700000000000000000000000000000000000000009999999999944ddd
00000000777777755777777777777755557777777777777557777777777777755777777700000000000000000000000000000000000000009999999999944ddd
00000000777777755777777777777555555717777777777557777777777777755777777700000000000000000000000000000000000000009999999999944ddd
00000000777777711777777777771557755117777777777117777777777777711777777700000000000000000000000000000000000000009999999999944ddd
00000000777777711177777777771117771177777777777111777777777777711177777700000000000000000000000000000000000000009999999999944ddd
000000007777777777777777777777777777777700000000000000000000000000000000000000000000000000000000ddddd0dddddddddddddddddddddddd00
000000007777777777777777777777777777777700000000000000000000000000000000000000000000000000000000dddd0800dddddddd00ddddddddddd020
000000007777777777777777777777777777777700000000000000000000000000000000000000000000000000000000dd0000000ddddd00020dddddddddd002
000000007777777777777777777777777777777700000000000000000000000000000000000000000000000000000000002000002dddd00000000ddddddd0000
0000000077777777777777777777777777777777000000000000000000000000000000000000000000000000000000004444444444444444444444ddd4444444
0000000077777777777777777777777777777777000000000000000000000000000000000000000000000000000000004444444444444444444444ddd4444444
0000000077777777777777777477777777777777000000000000000000000000000000000000000000000000000000005445445445445445445445ddd5445445
0000000074777777777777777447777777777777000000000000000000000000000000000000000000000000000000005445445445445445445445ddd5445445
0000000074477777777777777444444444477777000000000000000000000000000000000000000000000000000000005445445445445445445445ddd5445445
0000000074444666444477447444466644444444000000000000000000000000000000000000000000000000000000005445445445445445445445ddd5445445
0000000074446666644444447444666664444444000000000000000000000000000000000000000000000000000000005445445445445445445445ddd5445445
00000000744666066644444774466666664444770000000000000000000000000000000000000000000000000000000054454454454454454454450dd5445445
000000007446664666444477744660406644477700000000000000000000000000000000000000000000000000000000544544544544544544544580d5445445
000000007446660666444777777666666677777700000000000000000000000000000000000000000000000000000000544544544544544544544500d5445445
00000000777766666777777777776666677777770000000000000000000000000000000000000000000000000000000054454454454454454454450005445445
00000000777776667777777777777666777777770000000000000000000000000000000000000000000000000000000054454454454454454454450205445445
5055555555555505dd555555555555dd5500000000000055ddda988a988a988a988a9dddddd44dddddd0ddddddddddddddddddddddddddddd555566ddddddddd
5550555550505555d55555555555555d5550555055505555dda988a988a988a988a988ddddd45dddddda0dddddddddddddddddddd000addd55566666dddddddd
000000000000000055000000000000555500000000000055da988a988a988a988a988a9dddd44dddddaaa0dddddddddddddbdddddd88addd56666665dddddddd
506660555055505555555055505550555555505550555055a988a988a988a988a988a988ddd54ddddaa00a0ddddddddddddbdddddd88adddd656565ddddddddd
000000000000000055000000000000555500000000000055ddd44dddddddddddddd44dddddd54dddaaa0aaa0ddbdddddbddbddbdddaaadddd656565ddddddddd
555055505550666055505550555055555550555055505555ddd45dddddddddddddd45dddddd44ddd00000000dddbdbbddbd3dbddd000adddd656565ddddddddd
000000000000000055000000000000555500000000000055ddd44dddddddddddddd54dddddd45dddddd55ddddbb3b3dddd333dddddbbadddd656565ddddddddd
505550555000000055555055505550555555505550555055ddd44dddddddddddddd54dddddd45dddddd54dddddb33dbdb33333bdddbbadddd656565ddddddddd
00000000000000000000000000000000ddddddddddd1111111111ddddddddddd000000000000000000000000000000000000000000000000ddd0000d00000000
55505550666055500000000000000000ddddddddddd1666666661ddddddddddd000000000000000000000000000000000000000000000000ddd8000d00000000
00000000000000000000000000000000ddddddddddd1111111111ddddddddddd000000000000000000000000000000000000000000000000ddd08ddd00000000
50555055505550550000000000000000ddddddddddd1111111111ddddddddddd000000000000000000000000000000000000000000000000dd000ddd00000000
00000000000000000000000000000000ddddddddddddccccccccdddddddddddd000000000000000000000000000000000000000000000000d00050dd00000000
55506660555000000000000000000000ddddddddddddccccccccdddddddddddd0000000000000000000000000000000000000000000000000000000d00000000
00000000000000000000000000000000ddddddddddddccccccccdddddddddddd0000000000000000000000000000000000000000000000000500005000000000
50555055505550550000000000000000dddddddddddd66666666dddddddddddd0000000000000000000000000000000000000000000000000550005000000000
ddddddddddddddddddddddddddddddddddddddddddddccccccccdddddddddddd00000000000000000000000000000000dddddddd000000000000000000000000
ddddddddddddddddddddddddddddddddddddddddddddccccccccdddddddddddd00000000000000000000000000000000dddddddd111011101110111011101110
dddddddddddddddddddddddddddddddddddddddddddd66666666dddddddddddd0000000000000000000000000000000066666666006666600000000000000000
dddaaaaaaaaa999999dddddddddddddd999999999999cccccccc9999999999990000000000000000000000000000000010111011166666661011101110111011
dda444444444a99999999ddddddddddd999999999999cccccccc9999999999990000000000000000000000000000000000000000060060060000000000000000
ddda44444444aa99999999ddddddddddaaaaaaaaaaa966666666aaaaaaaaaaaa0000000000000000000000000000000011101110160060061110111011101110
dddaa44444444a99999cccddddddddddacc6cc6ccaa9ccccccccaacc6cc6ccaa00000000000000000000000000000000000000000666666600a2222aa2222a00
dddda44444444a99999ccccdddddddddacc6cc6ccaa9ccccccccaacc6cc6ccaa00000000000000000000000000000000101110111061606110a2888aa2888a11
ddddda4444000a9999999999ddddddddacc6cc6ccaa9aaaaaaaaaacc6cc6ccaa00000000000000000000000000000000000000000000000000a288aaaa288a00
ddddda4400204a99999a99999dddddddaaaaaaaaaaa999999999aaaaaaaaaaaa00000000000000000000000000000000111011101110111011a28a0000a28910
ddddda4200002a999999999966ddddddaaaaaaaaaaa9aaaaaaaaaaaaaaaaaaaa00000000000000000000000000000000000000000000000000aaaa0000999900
dddda44000000a999999999966ddddddacc6cc6ccaa9accc6ccaaacc6cc6ccaa000000000000000000000000000000001011101110116011102222a009222211
dddd666666666aaaaaaaaa6666ddddddacc6cc6ccaa9accc6ccaaacc6cc6ccaa00000000000000000000000000000000000000000000660000a2889009288900
dddd86aaaa668000aaaaa000ddddddddacc6cc6ccaa9accc6ccaaacc6cc6ccaa00000000000000000000000000000000111011101116511011a2888992888910
ddddd000ddddd000ddddd000ddddddddacc6cc6ccaa9accc6ccaaacc6cc6ccaa00000000000000000000000000000000000000000665000000a9999999999900
ddddd000ddddd000ddddd000ddddddddaaaaaaaaaaa9accc6ccaaaaaaaaaaaaa0000000000000000000000000000000010111011106110111022222222222211
77777777777777777777777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
74777777777777777477777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
74477777777777777447777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
74454666444477447545466644447744000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
74446666644444447554666d64544544000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
74566606d645454774566606d6454547000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7446d64666444477744dd64666444477000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7446660666444777744d660666445777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777766666777777777776666d7777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777666777777777777766677777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
74777777777777777477777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
74477777777777777447777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
74454444444777777545444444477777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
74444666444444447554466d44544544000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
745466d664454544745466d664454544000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
74466666664444777446666666444477000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7446604066444777744d604066444777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77766666667777777776666666777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7777666d677777777777666d67777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7777766677777777777776d677777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777775555777777777777777777777776670000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777775555577777777777777777776677660000000000000000000000000000000000000000000000000000000000000000
77777000007777777777700000777777775555500077777777777000007667760000000000000000000000000000000000000000000000000000000000000000
7777700fff7777777777700fff7777777755555fff7777777777700fff7766770000000000000000000000000000000000000000000000000000000000000000
7777700f857777777777700f857777777755555f857777777777700f857776770000000000000000000000000000000000000000000000000000000000000000
77770000fff7777777770000fff7777777755550fff7777777770000fff775550000000000000000000000000000000000000000000000000000000000000000
77770000007777777777000000777777777705000077777777770000007755550000000000000000000000000000000000000000000000000000000000000000
77770ff99c777777777700999c77777777760ff99c777777777707999c7555550000000000000000000000000000000000000000000000000000000000000000
77775ffccc77777777777ffccc77777777767ffccc7777777777779cff5555550000000000000000000000000000000000000000000000000000000000000000
7775559ccc9f777777775ffccc7777777777779ccc9f77777777779cff7555570000000000000000000000000000000000000000000000000000000000000000
7755559ccc9f77777775559ccc7777777777679ccc9f77777777779ccc7777770000000000000000000000000000000000000000000000000000000000000000
775555cccc777777775555cccc777777777777cccc777777777777cccc7777770000000000000000000000000000000000000000000000000000000000000000
77555579977777777755559999777777777777799777777777777779977777770000000000000000000000000000000000000000000000000000000000000000
7777777997777777775555999997c777777777799777777777777779977777770000000000000000000000000000000000000000000000000000000000000000
77777770077777777777099779900777777777700777777777777770077777770000000000000000000000000000000000000000000000000000000000000000
777777700c777777777700c777007777777777700c777777777777700c7777770000000000000000000000000000000000000000000000000000000000000000
77777777ccc7777777777777ccc7777777777777ccc7777777777777ccc777770000000000000000000000000000000000000000000000000000000000000000
777777cccac77777777777cccac77777777777cccac77777777777cccac777770000000000000000000000000000000000000000000000000000000000000000
77777ccccc77777777777ccccc77777777777ccccc77777777777ccccc7777770000000000000000000000000000000000000000000000000000000000000000
77777cccc111777777777cccc111777777777cccc111777777777cccc11177770000000000000000000000000000000000000000000000000000000000000000
77777744637777777777774463777777777777446307777777777744637777770000000000000000000000000000000000000000000000000000000000000000
7777774ffff707777777774ffff777777777774ffff070777777774ffff777770000000000000000000000000000000000000000000000000000000000000000
777777ffff770777777777ffff777777777777ffff700777777777ffff7777770000000000000000000000000000000000000000000000000000000000000000
7777771ccc770777777777111c7777777777771ccc7f47777777771ccc7777770000000000000000000000000000000000000000000000000000000000000000
77777111cc774077777774111c77777777777111cc1ff77777777111cc7777770000000000000000000000000000000000000000000000000000000000000000
777f1111cc1ff77777777f1111ff7777777f1111cc117477777f1111ccff40000000000000000000000000000000000000000000000000000000000000000000
77ff1111cc1ff77777777f111cff777777ff1111cc17777777ff1111ccff07770000000000000000000000000000000000000000000000000000000000000000
777777111c774777777704111c777777777777111c777777777777111c7707770000000000000000000000000000000000000000000000000000000000000000
77777775577777777777705555777777777777755777777777777775577777770000000000000000000000000000000000000000000000000000000000000000
77777775577777777777755555571777777777755777777777777775577777770000000000000000000000000000000000000000000000000000000000000000
77777771177777777777155775511777777777711777777777777771177777770000000000000000000000000000000000000000000000000000000000000000
77777771117777777777111777117777777777711177777777777771117777770000000000000000000000000000000000000000000000000000000000000000
__gff__
0001010000000000000100000000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003030303000001010100000000000100000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080808080808080800000000000000000808080808080808000000000000000008080808080808080000000000000000080808080808080800000000000000000
__map__
4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f
4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f
4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f5e4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f
4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f464747484f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f
4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4a4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f494f4f494f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f
4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f494f4f4f4f4f4f4647474747484f4f4f4f494f4f494f4f4f4f4f4f4f4f4d4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f
0e0f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4b4f494f4f4f4f4f4f494f4f4f4f494f4f4f4f494f4f494f4f4f4f4f4f4f4f494f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f
1e1f4f4f4f4b4f4f4f4b4f4f4f4c4f4f4240504140434f4f4b494f4f4b4f494f4f4f4f494e4b494f4f4f4f4f4f4c4f494f4b4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f
404040414140404041436c424140414050505050504040404140404040404040404040404040404041456c424140414140434f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f46474747484f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f
505150505050505050457c445050505050505051505050505050505050505150505050505150505050457c44505050505050434f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f494f4f4f494f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f545454545454544f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f
505050505050505150457c445051505050505050505050505150505050505050505050505050505050457c4450515050505050434f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f494f4f4f494f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f545556574f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f
505150505050505050457c445050505050505050505050515050505050505050505050505150505050457c445050515051505050434f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f494f4f4f494f4f4f606162634f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f646566674f4f4f4f4f4f4f4f4f4f4f4f4f4f2c2d2e2f
505050505150505050457c445150505050505150505050505050505051505050505051505050505150457c44515050505150505050434f4f4b4f4f4f4c4f4f4f4b4f4f4f4c4f494f4b4f494f4f4f707172734b4f4f4f4b4f424140434b4f4f4f4c4f4f4f4b4f4f4f4f4f747576774c4f4f4f4b4f4f4f4f4f4b4f4f4f3c3d3e3f
505050505050505150457c445050505051505050505050505050505050505050505050505050505050457c44505050505050505150504040404040404040404040404040414040404041504040414040404140404041404050505050404040404040404040404040414040404040404040404040404041404040404150404041
505050505050505050457c4450515050505050505050505050505050505050505050507c7c7c6e6f7c7c7c44505150505050505050515050505150505050505050505050505050505050505050505050505050505050505050505150505150505050505050505050505050515050505050505050505150505050505050505050
7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c6d7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c6d7c7c7c7e7f7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c505050505050505050505150505050505150505050505150505050505051505050505050515050505050505050505050505050515050505050505050515050505050
4040404040404040404040404040404040404040404040404040405050505050505050404040404040404040404040404040404040404040404040404040505050505050505150505051505050505051505150505050505050505050404040404040505050505050505140404040404050505050505050515050505150505050
5050505050505150505050505050505050505050505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5050505050505050505050505050505050505050505050505050515050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5050505150505050515050505050515050505050505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5050505050505050505050505050505050505050515050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000014650196501b6501c6501c6501c6501b6501965018650166501365012650106500e6500d6500e65012650186501f650266502a6502b65011000130000f0000f0000f0000e0000e0000e0000e0000f000
000100002d3502b3502a3502735025350213501d3501a35016350133500e3500a3500935000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000271502515022150211001d1001915018150121500e1500c11008110051100211000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01180020071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155051550c155011550c155051550c155081550c155051550c155081550c155051550c157081550c155
01180020010630000000000010631f633000000000000000010630000000000000001f633000000000000000010630000000000010631f633000000000000000000630000000063000001f633000000000000000
01180020071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155081550f1550c1550f155081550f1550c1550f155081550f1550c1550f155081550f1550c1550f155
011800201305015050160501605016050160551305015050160501605016050160551605015050160501a05018050160501805018050180501805018050180550000000000000000000000000000000000000000
011800200c05015050160501605016050160551305015050160501605016050160551605015050160501a0501b0501b0501b0501b0501b0501b0501b0501b0550000000000000000000000000000000000000000
011800202271024710267102671026710267152271024710267102671026710267152671024710267102971027710267102471024710247102471024710247150000000000000000000000000000000000000000
01180020167102471026710267102671026715227102471026710267102671026715267102471026710297102b7102b7102b7102b7102b7102b7102b7102b7150000000000000000000000000000000000000000
01180020081550f1550c1550f155081550f1550c1550f155081550f1550c1550f155081550f1550c1550f155071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155
011800201b1301a1301b1301b1301b1301b1351b1301a1301b1301b1301b1301b1351b1301a1301b1301f1301a130181301613016130161301613016130161350000000000000000000000000000000000000000
01180020081550f1550c1550f155081550f1550c1550f155081550f1550c1550f155081550f1550c1550f1550a155111550e155111550a155111550e155111550a155111550e155111550a155111550e15511155
011800201b1301a1301b1301b1301b1301b1351b1301a1301b1301b1301b1301b1351b1301a1301b1301f1301d1301d1301d1301d1301d1301d1301d1301d1350000000000000000000000000000000000000000
011800202b720297202b7202b7202b7202b7252b720297202b7202b7202b7202b7252b720297202b7202e72029720277202672026720267202672026720267250000000000000000000000000000000000000000
011800202b720297202b7202b7202b7202b7252b720297202b7202b7202b7202b7252b720297202b7202e7202e7202e7202e7202e7202e7202e7202e7202e7250000000000000000000000000000000000000000
__music__
01 03044344
00 05424304
00 03064344
00 05074344
00 03060804
00 05070904
00 0a0b4344
00 0c0d4344
00 0a0b0e04
02 0c0d0f04

