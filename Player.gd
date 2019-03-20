extends Area2D

signal hit

var speed : = 400
var velocity = Vector2()
var acceleration := 0.0
var screensize
# Add this variable to hold the clicked position.
var target = Vector2()

func _ready():
    hide()
    screensize = get_viewport_rect().size

func start(pos):
    position = pos
    # Initial target is the start position.
    target = pos
    show()
    $Collision.disabled = false

# Change the target whenever a touch event happens.
func _input(event):
    if event is InputEventScreenTouch and event.pressed:
        target = event.position

func _process(delta):
    var distance_to_target = position.distance_to(target)
    var vector_to_target = target - position
    if distance_to_target > 10:
        velocity = vector_to_target.normalized() * speed
    else:
        velocity = Vector2()

    if velocity.length() > 0:
        velocity = velocity.normalized() * speed
        $AnimatedSprite.play()
        $Trail.emitting = true
    else:
        $AnimatedSprite.stop()
        $Trail.emitting = false

    position += velocity * delta
    # We don't need to clamp the player's position
    # because you can't click outside the screen.
    # position.x = clamp(position.x, 0, screensize.x)
    # position.y = clamp(position.y, 0, screensize.y)

    if velocity.x != 0:
        $AnimatedSprite.animation = "right"
        $AnimatedSprite.flip_v = false
        $AnimatedSprite.flip_h = velocity.x < 0
    elif velocity.y != 0:
        $AnimatedSprite.animation = "up"
        $AnimatedSprite.flip_v = velocity.y > 0

func _on_Player_body_entered( body ):
    $Collision.disabled = true
    hide()
    emit_signal("hit")