package graphics

import "core:fmt"
import glm "core:math/linalg/glsl"
import gl "vendor:OpenGL"
import stb "vendor:stb/image"
import gltf "vendor:cgltf"

Vertex :: struct {
    pos: glm.vec3,
    col: glm.vec4,
    texcoord: glm.vec2,
}

Mesh :: struct {
    pos: glm.vec3,
    rot: glm.vec3,
    scale: glm.vec3,
    vertices: []Vertex,
    indices: []u32,
    
    vbo, ebo, vao: u32,
    texture: Texture,
}

get_mesh_model :: proc(mesh: Mesh) -> glm.mat4x4 {
    return glm.identity(glm.mat4x4) * glm.mat4Rotate(glm.vec3{1.0, 0.0, 0.0}, mesh.rot.x) * glm.mat4Rotate(glm.vec3{0.0, 1.0, 0.0}, mesh.rot.y) * glm.mat4Rotate(glm.vec3{0.0, 0.0, 1.0}, mesh.rot.z) * glm.mat4Scale(mesh.scale) * glm.mat4Translate(mesh.pos)
}

load_mesh_as_cube :: proc(texturePath: cstring) -> (mesh: Mesh) {
    mesh.pos = glm.vec3{0.0, 0.0, 0.0}
    mesh.rot = glm.vec3{0.0, 0.0, 0.0}
    mesh.scale = glm.vec3{1.0, 1.0, 1.0}

    // cube
    mesh.vertices = []Vertex{
        // front
        Vertex{glm.vec3{-0.5, -0.5,  0.5}, glm.vec4{1.0, 0.0, 0.0, 1.0}, glm.vec2{0.0, 0.0}},
        Vertex{glm.vec3{ 0.5, -0.5,  0.5}, glm.vec4{0.0, 1.0, 0.0, 1.0}, glm.vec2{1.0, 0.0}},
        Vertex{glm.vec3{ 0.5,  0.5,  0.5}, glm.vec4{0.0, 0.0, 1.0, 1.0}, glm.vec2{1.0, 1.0}},
        Vertex{glm.vec3{-0.5,  0.5,  0.5}, glm.vec4{1.0, 1.0, 1.0, 1.0}, glm.vec2{0.0, 1.0}},
        // back
        Vertex{glm.vec3{-0.5, -0.5, -0.5}, glm.vec4{1.0, 0.0, 0.0, 1.0}, glm.vec2{0.0, 0.0}},
        Vertex{glm.vec3{ 0.5, -0.5, -0.5}, glm.vec4{0.0, 1.0, 0.0, 1.0}, glm.vec2{1.0, 0.0}},
        Vertex{glm.vec3{ 0.5,  0.5, -0.5}, glm.vec4{0.0, 0.0, 1.0, 1.0}, glm.vec2{1.0, 1.0}},
        Vertex{glm.vec3{-0.5,  0.5, -0.5}, glm.vec4{1.0, 1.0, 1.0, 1.0}, glm.vec2{0.0, 1.0}},

        // left
        Vertex{glm.vec3{-0.5, -0.5, -0.5}, glm.vec4{1.0, 0.0, 0.0, 1.0}, glm.vec2{0.0, 0.0}},
        Vertex{glm.vec3{-0.5, -0.5,  0.5}, glm.vec4{0.0, 1.0, 0.0, 1.0}, glm.vec2{1.0, 0.0}},
        Vertex{glm.vec3{-0.5,  0.5,  0.5}, glm.vec4{0.0, 0.0, 1.0, 1.0}, glm.vec2{1.0, 1.0}},
        Vertex{glm.vec3{-0.5,  0.5, -0.5}, glm.vec4{1.0, 1.0, 1.0, 1.0}, glm.vec2{0.0, 1.0}},

        // right
        Vertex{glm.vec3{ 0.5, -0.5, -0.5}, glm.vec4{1.0, 0.0, 0.0, 1.0}, glm.vec2{0.0, 0.0}},
        Vertex{glm.vec3{ 0.5, -0.5,  0.5}, glm.vec4{0.0, 1.0, 0.0, 1.0}, glm.vec2{1.0, 0.0}},
        Vertex{glm.vec3{ 0.5,  0.5,  0.5}, glm.vec4{0.0, 0.0, 1.0, 1.0}, glm.vec2{1.0, 1.0}},
        Vertex{glm.vec3{ 0.5,  0.5, -0.5}, glm.vec4{1.0, 1.0, 1.0, 1.0}, glm.vec2{0.0, 1.0}},

        // top
        Vertex{glm.vec3{-0.5,  0.5, -0.5}, glm.vec4{1.0, 0.0, 0.0, 1.0}, glm.vec2{0.0, 0.0}},
        Vertex{glm.vec3{ 0.5,  0.5, -0.5}, glm.vec4{0.0, 1.0, 0.0, 1.0}, glm.vec2{1.0, 0.0}},
        Vertex{glm.vec3{ 0.5,  0.5,  0.5}, glm.vec4{0.0, 0.0, 1.0, 1.0}, glm.vec2{1.0, 1.0}},
        Vertex{glm.vec3{-0.5,  0.5,  0.5}, glm.vec4{1.0, 1.0, 1.0, 1.0}, glm.vec2{0.0, 1.0}},

        // bottom
        Vertex{glm.vec3{-0.5, -0.5, -0.5}, glm.vec4{1.0, 0.0, 0.0, 1.0}, glm.vec2{0.0, 0.0}},
        Vertex{glm.vec3{ 0.5, -0.5, -0.5}, glm.vec4{0.0, 1.0, 0.0, 1.0}, glm.vec2{1.0, 0.0}},
        Vertex{glm.vec3{ 0.5, -0.5,  0.5}, glm.vec4{0.0, 0.0, 1.0, 1.0}, glm.vec2{1.0, 1.0}},
        Vertex{glm.vec3{-0.5, -0.5,  0.5}, glm.vec4{1.0, 1.0, 1.0, 1.0}, glm.vec2{0.0, 1.0}},
    }

    mesh.indices = []u32{
        0, 1, 2, 2, 3, 0,
        4, 5, 6, 6, 7, 4,
        8, 9, 10, 10, 11, 8,
        12, 13, 14, 14, 15, 12,
        16, 17, 18, 18, 19, 16,
        20, 21, 22, 22, 23, 20,
    }

    mesh.texture = load_texture(texturePath)
    
    gl.GenVertexArrays(1, &mesh.vao)
    gl.BindVertexArray(mesh.vao)

    gl.GenBuffers(1, &mesh.vbo)
    gl.BindBuffer(gl.ARRAY_BUFFER, mesh.vbo)
    gl.BufferData(gl.ARRAY_BUFFER, len(mesh.vertices) * size_of(Vertex), &mesh.vertices[0], gl.STATIC_DRAW)

    gl.GenBuffers(1, &mesh.ebo)
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, mesh.ebo)
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(mesh.indices) * size_of(u32), &mesh.indices[0], gl.STATIC_DRAW)

    //layout (location = 0) in vec3 vPos;
    //layout (location = 1) in vec3 vNormal;
    //layout (location = 2) in vec2 vTexCoords;

    gl.EnableVertexAttribArray(0)
    gl.VertexAttribPointer(0, 3, gl.FLOAT, false, size_of(Vertex), 0)

    gl.EnableVertexAttribArray(1)
    gl.VertexAttribPointer(1, 4, gl.FLOAT, false, size_of(Vertex), size_of(glm.vec3))

    gl.EnableVertexAttribArray(2)
    gl.VertexAttribPointer(2, 2, gl.FLOAT, false, size_of(Vertex), size_of(glm.vec3) + size_of(glm.vec4))

    gl.BindVertexArray(0)

    return mesh
}


draw_mesh :: proc(mesh: Mesh) {
    gl.BindVertexArray(mesh.vao)
    gl.BindTexture(gl.TEXTURE_2D, mesh.texture.gl_handle)
    gl.DrawElements(gl.TRIANGLES, cast(i32)len(mesh.indices), gl.UNSIGNED_INT, nil)
    gl.BindVertexArray(0)
    gl.BindTexture(gl.TEXTURE_2D, 0)
}

load_mesh_from_gltf :: proc(modelPath: cstring, texturePath: cstring) -> (mesh: Mesh) {
    options := gltf.options {
        gltf.file_type.gltf,
        0,
        
    }
}