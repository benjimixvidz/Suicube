extends Control

func _ready():
	# Obtenir les boutons
	var replay_button = $Panel/ReplayButton
	var quit_button = $Panel/QuitButton

	# Connecter les signaux
	replay_button.connect("pressed", self, "_on_ReplayButton_pressed")
	quit_button.connect("pressed", self, "_on_QuitButton_pressed")

	# Afficher le score
	$Panel/ScoreLabel.text = "Score : " + str(Global.score)

func _on_ReplayButton_pressed():
	# Réinitialiser le score
	Global.score = 0
	# Charger la scène principale
	get_tree().change_scene("res://Main.tscn")  # Assurez-vous que le chemin est correct

func _on_QuitButton_pressed():
	# Quitter le jeu
	get_tree().quit()
