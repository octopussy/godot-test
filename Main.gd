extends Node

export (PackedScene) var Mob
var score

var isGameInProgress := false
var admob = null
var isReal = false

var adBannerId = "ca-app-pub-8288317636992159/5848576956"
var adInterstitialId = "ca-app-pub-8288317636992159/1841597925"
var adRewardedId = "ca-app-pub-3940256099942544/5224354917"

func _ready():
    check_ads();
    randomize()
    #new_game()

func check_ads():
    if(Engine.has_singleton("AdMob")):
        admob = Engine.get_singleton("AdMob")
        admob.init(isReal, get_instance_id())
        print("Admob LOADED!!!")
        loadBanner()
        loadInterstitial()
        loadRewardedVideo()
        admob.hideBanner()
    else:
        print("Admob FAILED!!!")

func _on_admob_network_error():
    print("Network Error")

func new_game():
    print("Game Start")
    score = 0
    $Player.start($StartPosition.position)
    $StartTimer.start()
    $HUD.update_score(score)
    $HUD.show_message("Get Ready")
    $Music.play()
    isGameInProgress = true

func loadBanner():
    if (admob):
        admob.loadBanner(adBannerId, false)

func loadInterstitial():
    if (admob):
        admob.loadInterstitial(adInterstitialId)

func loadRewardedVideo():
    if (admob):
        admob.loadRewardedVideo(adRewardedId)

func game_over():
    if !isGameInProgress: return
    isGameInProgress = false
    print("Game Over")
    $ScoreTimer.stop()
    $MobTimer.stop()
    $HUD.show_game_over()
    $Music.stop()
    $DeathSound.play()

func _on_StartTimer_timeout():
    $ScoreTimer.start()
    $MobTimer.start()

func _on_ScoreTimer_timeout():
    score += 1
    $HUD.update_score(score)

func _on_MobTimer_timeout():
    # Choose a random location on Path2D.
    $MobPath/MobSpawnLocation.set_offset(randi())
    # Create a Mob instance and add it to the scene.
    var mob = Mob.instance()
    add_child(mob)
    # Set the mob's direction perpendicular to the path direction.
    var direction = $MobPath/MobSpawnLocation.rotation + PI / 2
    # Set the mob's position to a random location.
    mob.position = $MobPath/MobSpawnLocation.position
    # Add some randomness to the direction.
    direction += rand_range(-PI / 4, PI / 4)
    mob.rotation = direction
    # Set the velocity (speed & direction).
    mob.linear_velocity = Vector2(rand_range(mob.min_speed, mob.max_speed), 0)
    mob.linear_velocity = mob.linear_velocity.rotated(direction)

func start_game() -> void:
    new_game()

func _on_rewarded(currency, amount):
    print("Reward: " + currency + ", " + str(amount))

func _on_interstitial_not_loaded():
    print("Error: Interstitial not loaded")

func _on_interstitial_loaded():
    print("Interstitial loaded")
    #get_node("CanvasLayer/BtnInterstitial").set_disabled(false)

func _on_rewarded_video_ad_loaded():
    print("Rewarded loaded success")

func _on_rewarded_video_ad_closed():
    print("Rewarded closed")
    #get_node("CanvasLayer/BtnRewardedVideo").set_disabled(true)
    loadRewardedVideo()

func _on_ShowInterstitialButton_pressed() -> void:
    if admob != null:
        admob.showInterstitial()

func _on_ShowBannerButton_pressed() -> void:
    if admob != null:
        admob.showBanner()

func _on_ShowVideoButton_pressed() -> void:
    if admob != null:
        admob.showRewardedVideo()
