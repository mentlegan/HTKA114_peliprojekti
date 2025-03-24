extends Area2D
## Juuso 24.3.2025
## TODO: piikeistä helpommin huomattavia?
## Tuli mieleen tehdessä perhospesän kohtaa, jossa esiintyy piikkejä
## Voisi olla esimerkiksi sellainen, että väri vaihtelee vähäsen jatkuvasti
## Tai highlightaava, aaltoileva valkoinen glow, tai outline yms.
## Pieni värähtelevä liikekin voisi auttaa

## Pelaajan alkaa ottamaan myrkkyä osuessaan sieneen
func _on_body_entered(body):
	if body is Pelaaja:
		print_debug("Kuolit PIIKKIIN")
		body.meneta_elamia(body.pelaajan_elamat_max, "normaali")
