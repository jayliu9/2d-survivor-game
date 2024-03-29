extends CharacterBody2D

@onready var damage_interval_timer = $DamageIntervalTimer
@onready var health_bar = $HealthBar
@onready var health_component = $HealthComponent
@onready var collision_area_2d = $CollisionArea2D
@onready var abilities = $Abilities
@onready var animation_player = $AnimationPlayer
@onready var visuals = $Visuals

const MAX_SPEED = 150
const ACCELERATION_SMOOTHING = 5

var number_collding_bodies = 0


func _ready():
	collision_area_2d.body_entered.connect(on_body_entered)
	collision_area_2d.body_exited.connect(on_body_exited)
	damage_interval_timer.timeout.connect(on_damage_interval_timer_timeout)
	health_component.health_change.connect(on_health_change)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	update_health_bar()


func _process(delta):
	var movement_vector = get_movement_vector()
	var movement_vector_direction = movement_vector.normalized()
	var target_velocity = movement_vector_direction * MAX_SPEED
	velocity = velocity.lerp(target_velocity, 1.0 - exp(-delta * ACCELERATION_SMOOTHING))
	move_and_slide()
	
	if movement_vector.x != 0 || movement_vector.y != 0:
		animation_player.play("walk")
	else:
		animation_player.play("RESET")
	
	var move_sign = sign(movement_vector.x)
	if move_sign == 0:
		visuals.scale = Vector2.ONE
	else:
		visuals.scale = Vector2(move_sign, 1)		

func get_movement_vector():
	var x_movement_vector = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement_vector = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return Vector2(x_movement_vector, y_movement_vector)


func check_deal_damage():
	if number_collding_bodies == 0 || !damage_interval_timer.is_stopped():
		return
	
	health_component.damage(1)
	print(health_component.current_health)
	damage_interval_timer.start()


func update_health_bar():
	health_bar.value = health_component.get_health_percent()
	
	

func on_body_entered(other_body: Node2D):
	number_collding_bodies += 1
	check_deal_damage()


func on_body_exited(other_body: Node2D):
	number_collding_bodies -=1


func on_damage_interval_timer_timeout():
	check_deal_damage()


func on_health_change():
	update_health_bar()


func on_ability_upgrade_added(ability_upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if not ability_upgrade is Ability:
		return
	
	var ability = ability_upgrade as Ability
	abilities.add_child(ability.ability_controller_scene.instantiate())
		

	
