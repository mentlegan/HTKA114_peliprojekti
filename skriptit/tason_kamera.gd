extends Camera2D


var tween: Tween
var pelaaja: Pelaaja
var alku_zoom = zoom
var alku_pos = global_position
var ajastin = Timer


func _ready():
	# Ajastin sille, kun kamera on lopettanut siirtoanimaation
	ajastin = Timer.new()
	ajastin.set_one_shot(true)
	ajastin.set_wait_time(4)
	ajastin.timeout.connect(deaktivoi)
	add_child(ajastin)

	# Otetaan talteen editorissa asetetut arvot zoomille ja sijainnille
	alku_zoom = zoom
	alku_pos = global_position


## Asettaa kameran takaisin pelaajalle ja aloittaa tätä varten animaation
func deaktivoi():
	pelaaja.kamera.global_position = global_position
	pelaaja.kamera.zoom = zoom
	pelaaja.kamera.make_current()

	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(pelaaja.kamera, "zoom", Vector2(1, 1), 1)
	tween.tween_property(pelaaja.kamera, "position", Vector2(0, 0), 1)
	tween.finished.connect(Globaali.aseta_ui_nakyvaksi)


## Asettaa tason kameran aktiiviseksi ja aloittaa tätä varten animaation
func aktivoi(_pelaaja: Pelaaja):
	if not pelaaja:
		pelaaja = _pelaaja
	
	make_current()

	global_position = pelaaja.global_position
	zoom = pelaaja.kamera.zoom
	
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "zoom", alku_zoom, 1)
	tween.tween_property(self, "global_position", alku_pos, 1)
	tween.finished.connect(ajastin.start)