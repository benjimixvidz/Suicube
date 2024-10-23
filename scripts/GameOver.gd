extends Control

func _ready():
	# Obtenir les boutons
	var replay_button = $"Ecran de GameOver/ReplayButton"
	var quit_button = $"Ecran de GameOver/QuitButton"

	# Connecter les signaux
	replay_button.connect("pressed", Callable(self, "_on_ReplayButton_pressed"))
	quit_button.connect("pressed", Callable(self, "_on_QuitButton_pressed"))

	# Afficher le score
	$ "Ecran de GameOver/ScoreLabel".text = "Score : " + str(Global.score)

func _on_ReplayButton_pressed():
	# Réinitialiser le score
	Global.score = 0
	# Charger la scène principale avec un effet de transition
	get_tree().change_scene("res://scenes/Main.tscn")

func _on_QuitButton_pressed():
	# Quitter le jeu
	get_tree().quit()
