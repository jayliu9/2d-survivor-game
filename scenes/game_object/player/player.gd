extends CharacterBody2D

@onready var damage_interval_timer = $DamageIntervalTimer
const MAX_SPEED = 150
const ACCELERATION_SMOOTHING = 5

var number_collding_bodies = 0


func _ready():
	$CollisionArea2D.body_entered.connect(on_body_entered)
	$CollisionArea2D.body_exited.connect(on_body_exited)
	damage_interval_timer.timeout.connect(on_damage_interval_timer_timeout)


func _process(delta):
	var movement_vector_direction = get_movement_vector().normalized()
	var target_velocity = movement_vector_direction * MAX_SPEED
	velocity = velocity.lerp(target_velocity, 1.0 - exp(-delta * ACCELERATION_SMOOTHING))
	move_and_slide()


func get_movement_vector():
	var x_movement_vector = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement_vector = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return Vector2(x_movement_vector, y_movement_vector)


func check_deal_damage():
	if number_collding_bodies == 0 || !damage_interval_timer.is_stopped():
		return
	
	$HealthComponent.damage(1)
	print($HealthComponent.current_health)
	damage_interval_timer.start()


func on_body_entered(other_body: Node2D):
	number_collding_bodies += 1
	check_deal_damage()


func on_body_exited(other_body: Node2D):
	number_collding_bodies -=1


func on_damage_interval_timer_timeout():
	check_deal_damage()
