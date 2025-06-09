use bevy::{prelude::*, render::camera::ScalingMode};
use bevy_matchbox::prelude::*;

fn main() {
    App::new()
        .add_plugins(DefaultPlugins.set(WindowPlugin {
            primary_window: Some(Window {
                fit_canvas_to_parent: true,
                prevent_default_event_handling: false,
                ..default()
            }),
            ..default()
        }))
        .add_systems(Startup, (setup, spawn_player, start_matchbox_socket))
        .add_systems(Update, move_player)
        .run();
}

fn setup(mut commands: Commands) {
    commands.spawn((
        Camera2d,
        Projection::Orthographic(OrthographicProjection {
            scaling_mode: ScalingMode::FixedVertical {
                viewport_height: 10.,
            },
            ..OrthographicProjection::default_2d()
        }),
    ));
}

fn spawn_player(mut commands: Commands) {
    commands.spawn((
        Player,
        Sprite {
            color: Color::srgb(0., 0.47, 1.),
            custom_size: Some(Vec2::new(1., 1.)),
            ..default()
        },
    ));
}

fn start_matchbox_socket(mut commands: Commands) {
    let room_url = "ws://127.0.0.1:3536/extreme_bevy?next=2";
    info!("connecting to matchbox server: {room_url}");
    commands.insert_resource(MatchboxSocket::new_unreliable(room_url));
}

#[derive(Component)]
struct Player;

// Move the player around
fn move_player(
    mut players: Query<&mut Transform, With<Player>>,
    keys: Res<ButtonInput<KeyCode>>,
    time: Res<Time>,
) {
    let mut direction = Vec2::ZERO;
    if keys.any_pressed([KeyCode::ArrowUp, KeyCode::KeyW]) {
        direction.y += 1.;
    }
    if keys.any_pressed([KeyCode::ArrowDown, KeyCode::KeyS]) {
        direction.y -= 1.;
    }

    //Horizontal
    if keys.any_pressed([KeyCode::ArrowRight, KeyCode::KeyD]) {
        direction.x += 1.;
    }
    if keys.any_pressed([KeyCode::ArrowLeft, KeyCode::KeyA]) {
        direction.x -= 1.;
    }

    if direction == Vec2::ZERO {
        return;
    }

    // Calculate how far we should move relative to the time passed
    let move_speed = 7.;
    let move_delta = direction * move_speed * time.delta_secs();

    for mut transform in &mut players {
        transform.translation += move_delta.extend(0.);
    }
}
