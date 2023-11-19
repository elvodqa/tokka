package graphics

import "core:fmt"
import glm "core:math/linalg/glsl"
import gl "vendor:OpenGL"
import stb "vendor:stb/image"

Camera :: struct {
    position: glm.vec3,
    front: glm.vec3,

    up: glm.vec3,
    aspect: f32,

    yaw: f32,
    pitch: f32,
}

new_camera :: proc (position: glm.vec3, front: glm.vec3, up: glm.vec3, aspect: f32) -> Camera {
    result := Camera {
        position,
        front,
        up,
        aspect,
        -90.0,
        0.0,
    }
    return result
}

modify_camera_direction :: proc(camera: ^Camera, xOffset: f32, yOffset: f32) {
    camera.yaw += xOffset
    camera.pitch += yOffset

    if camera.pitch > 89.0 {
        camera.pitch = 89.0
    }
    if camera.pitch < -89.0 {
        camera.pitch = -89.0
    }

    cameraDirection: glm.vec3
    cameraDirection.x = glm.cos(glm.radians(camera.yaw)) * glm.cos(glm.radians(camera.pitch))
    cameraDirection.y = glm.sin(glm.radians(camera.pitch))
    cameraDirection.z = glm.sin(glm.radians(camera.yaw)) * glm.cos(glm.radians(camera.pitch))

    camera.front = glm.normalize(cameraDirection)
}

get_camera_view :: proc(camera: Camera) -> glm.mat4x4 {
    result := glm.mat4LookAt(camera.position, camera.position + camera.front, camera.up)
    return result
}

get_camera_projection :: proc(camera: Camera) -> glm.mat4x4 {
    result := glm.mat4Perspective(glm.radians_f32(45.0), camera.aspect, 0.1, 100.0)
    return result
}