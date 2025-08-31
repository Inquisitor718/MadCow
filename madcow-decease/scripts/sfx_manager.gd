extends Node

@export var sounds: Dictionary = {
	"shotgun_shoot": preload("res://ALL_SFX/ALL_SFX/shotgunshoot.mp3"),
	"take_dmg": preload("res://ALL_SFX/ALL_SFX/playerhit.wav"),
	"run_sound": preload("res://ALL_SFX/ALL_SFX/running_solid.wav"),
	"revolver_shoot": preload("res://ALL_SFX/ALL_SFX/revolvershoot.mp3"),
	"shotgun_pickup": preload("res://ALL_SFX/ALL_SFX/shotgunpickup.wav"),
	"minigun_shoot": preload("res://ALL_SFX/ALL_SFX/minigunshoot.wav"),
	"minigun_pickup": preload("res://ALL_SFX/ALL_SFX/minigunpickup.wav"),
	"health_pickup": preload("res://ALL_SFX/ALL_SFX/health_pickup.wav"),
	"horns_pickup": preload("res://ALL_SFX/ALL_SFX/hornspickup.mp3"),
	"revolver_pickup": preload("res://ALL_SFX/ALL_SFX/revolverpickup.mp3"),
}

func play_sound(name: String, volume := 0., pitch := 1., randomised_pitch := false, fromPos:= 0.0, toPos:= INF):
	if sounds.has(name):
		var new_audio_player : AudioOneshot = preload("res://Scenes/audio_player_oneshot.tscn").instantiate()
		add_child(new_audio_player)
		new_audio_player.stream = sounds[name]
		new_audio_player.volume_db = volume
		new_audio_player.pitch_scale = pitch
		if randomised_pitch:
			new_audio_player.pitch_scale += randf_range(-0.1, 0.1)
		new_audio_player.play(fromPos)
		if fromPos != INF:
			await get_tree().create_timer(toPos - fromPos).timeout
			if new_audio_player:
				new_audio_player.queue_free()
	else:
		print("sound nono")
