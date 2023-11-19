package graphics

import "core:fmt"
import glm "core:math/linalg/glsl"
import gl "vendor:OpenGL"
import stb "vendor:stb/image"

Texture :: struct {
    data: [^]u8,
    x, y, channels: i32,
    gl_handle: u32,
}

Sprite :: struct {
    texture: Texture,
    position: glm.vec3,
    size: glm.vec2,
    rotation: glm.vec3,
    scale: glm.vec3,
    color: glm.vec4,

    vertices: []Vertex,
    indices: []u32,
    vao: u32,
    vbo: u32,
    ebo: u32,
}


load_texture :: proc(texturePath: cstring) -> (texture: Texture) {
    texture.data = stb.load(texturePath, &texture.x, &texture.y, &texture.channels, 0)
    if texture.data == nil {
        fmt.printf("Failed to load texture: %s\n", texturePath)
        return texture
    }
    fmt.println("Loaded texture: ", texturePath)
    fmt.printf("x: %d, y: %d, channels: %d\n", texture.x, texture.y, texture.channels)
    
    gl.GenTextures(1, &texture.gl_handle)
    gl.BindTexture(gl.TEXTURE_2D, texture.gl_handle)
    
    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, texture.x, texture.y, 0, gl.RGBA, gl.UNSIGNED_BYTE, &texture.data[0])
   
    
    gl.GenerateMipmap(gl.TEXTURE_2D)

    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

    gl.BindTexture(gl.TEXTURE_2D, 0)

    return texture
}

new_sprite :: proc(texture: Texture, position: glm.vec3, size: glm.vec2, rotation: glm.vec3, color: glm.vec4) -> (sprite: Sprite) {
    sprite.texture = texture
    sprite.position = position
    sprite.size = size
    sprite.rotation = rotation
    sprite.color = color

    sprite.vertices = []Vertex {
        Vertex { glm.vec3 { 0.0, 0.0, 0.0 }, color, glm.vec2 { 0.0, 0.0 } },
        Vertex { glm.vec3 { 0.0, size.y, 0.0 }, color, glm.vec2 { 0.0, 1.0 } },
        Vertex { glm.vec3 { size.x, size.y, 0.0 }, color, glm.vec2 { 1.0, 1.0 } },
        Vertex { glm.vec3 { size.x, 0.0, 0.0 }, color, glm.vec2 { 1.0, 0.0 } },
    }

    sprite.indices = []u32 {
        0, 1, 2,
        2, 3, 0,
    }

    gl.GenVertexArrays(1, &sprite.vao)
    gl.BindVertexArray(sprite.vao)

    gl.GenBuffers(1, &sprite.vbo)
    gl.BindBuffer(gl.ARRAY_BUFFER, sprite.vbo)
    gl.BufferData(gl.ARRAY_BUFFER, len(sprite.vertices) * size_of(Vertex), &sprite.vertices[0], gl.STATIC_DRAW)

    gl.GenBuffers(1, &sprite.ebo)
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, sprite.ebo)
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(sprite.indices) * size_of(u32), &sprite.indices[0], gl.STATIC_DRAW)

    gl.EnableVertexAttribArray(0)
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, size_of(Vertex), 0)

    gl.EnableVertexAttribArray(1)
    gl.VertexAttribPointer(1, 4, gl.FLOAT, gl.FALSE, size_of(Vertex), 3 * size_of(f32))

    gl.EnableVertexAttribArray(2)
    gl.VertexAttribPointer(2, 2, gl.FLOAT, gl.FALSE, size_of(Vertex), 7 * size_of(f32))

    gl.BindVertexArray(0)

    return sprite
}

draw_sprite :: proc(sprite: Sprite) {
    gl.ActiveTexture(gl.TEXTURE0)
    gl.BindTexture(gl.TEXTURE_2D, sprite.texture.gl_handle)
    gl.BindVertexArray(sprite.vao)
    gl.DrawElements(gl.TRIANGLES, cast(i32)len(sprite.indices), gl.UNSIGNED_INT, nil)
    gl.BindVertexArray(0)
    gl.BindTexture(gl.TEXTURE_2D, 0)
}

get_sprite_model :: proc(mesh: Sprite) -> glm.mat4x4 {
    return glm.identity(glm.mat4x4) * glm.mat4Rotate(glm.vec3{1.0, 0.0, 0.0}, mesh.rotation.x) * glm.mat4Rotate(glm.vec3{0.0, 1.0, 0.0}, mesh.rotation.y) * glm.mat4Rotate(glm.vec3{0.0, 0.0, 1.0}, mesh.rotation.z) * glm.mat4Scale(mesh.scale) * glm.mat4Translate(mesh.position)
}