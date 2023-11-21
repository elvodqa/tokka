package graphics

import "core:fmt"
import glm "core:math/linalg/glsl"
import gl "vendor:OpenGL"
import stb "vendor:stb/image"
//import "vendor:cgltf"
import assimp "../../odin-assimp"
import "core:slice"
import "core:os"
import "core:strings"
import "core:strconv"




Vertex :: struct {
    pos: glm.vec3,
    col: glm.vec4,
    texcoord: glm.vec2,
}

Mesh :: struct {
    pos: glm.vec3,
    rot: glm.vec3,
    scale: glm.vec3,
    vertices: [dynamic]Vertex,
    indices: [dynamic]u32,
    
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
    mesh.vertices = [dynamic]Vertex{
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

    mesh.indices = [dynamic]u32{
        0, 1, 2, 2, 3, 0,
        4, 5, 6, 6, 7, 4,
        8, 9, 10, 10, 11, 8,
        12, 13, 14, 14, 15, 12,
        16, 17, 18, 18, 19, 16,
        20, 21, 22, 22, 23, 20,
    }

    //mesh.vertices = slice.clone(mesh.vertices)
    //mesh.indices = slice.clone(mesh.indices)

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


Obj :: struct {
    vertices: [dynamic]glm.vec3,
    normals: [dynamic]glm.vec3,
    texcoords: [dynamic]glm.vec2,
    indices: [dynamic]u32,

    // dumb shit
    mtllib: string
}



load_obj_from_file :: proc(filename: string) -> (obj: Obj) {
    data, ok := os.read_entire_file_from_filename(filename)
    if !ok {
        fmt.println("Error reading file")
        return
    }
    defer delete(data)

    it := string(data)
    for line in strings.split_lines_iterator(&it) {
        if len(line) == 0 || line[0] == '#'  {
            continue
        }
        split := strings.split(line, " ")
        if split[0] == "v" {
            // sometimes the result is ["v", "", "x", "y", "z"] because of extra space. until it's fixed, it will ignore the second element
            vert := glm.vec3{}
            vert.x, ok = strconv.parse_f32(split[2])
            if !ok {
                fmt.println("Error at line ", line)
            }
            vert.y, ok = strconv.parse_f32(split[3])
            if !ok {
                fmt.println("Error at line ", line)
            }
            vert.z, ok = strconv.parse_f32(split[4])
            if !ok {
                fmt.println("Error at line ", line)
            }
            append(&obj.vertices, vert)
        } else if split[0] == "vt" {
            texcoord := glm.vec2{}
            texcoord.x, ok = strconv.parse_f32(split[1])
            if !ok {
                fmt.println("Error at line ", line)
            }
            texcoord.y, ok = strconv.parse_f32(split[2])
            if !ok {
                fmt.println("Error at line ", line)
            }
            append(&obj.texcoords, texcoord)
        } else if split[0] == "vn" {
            normal := glm.vec3{}
            normal.x, ok = strconv.parse_f32(split[1])
            if !ok {
                fmt.println("Error at line ", line)
            }
            normal.y, ok = strconv.parse_f32(split[2])
            if !ok {
                fmt.println("Error at line ", line)
            }
            normal.z, ok = strconv.parse_f32(split[3])
            if !ok {
                fmt.println("Error at line ", line)
            }
            append(&obj.normals, normal)
        } else if split[0] == "f" {
            for i := 1; i < len(split); i+=1 {
                if len(split[i]) == 0 {
                    continue
                }
                indices := strings.split(split[i], "/")
                vertIndex, ok1 := strconv.parse_u64(indices[0])
                if !ok1 {
                    fmt.println(split[i])
                    fmt.println("Error at line ", line)
                }
                texcoordIndex, ok2 := strconv.parse_u64(indices[1])
                if !ok2 {
                    fmt.println(split[i])
                    fmt.println("Error at line ", line)
                }
                normalIndex, ok3 := strconv.parse_u64(indices[2])
                if !ok3 {
                    fmt.println(split[i])
                    fmt.println("Error at line ", line)
                }

                append(&obj.indices, u32(vertIndex) - 1)
                append(&obj.indices, u32(texcoordIndex) - 1)
                append(&obj.indices, u32(normalIndex) - 1)
            }
        } else if split[0] == "mtllib" {
            obj.mtllib = split[1]
        }    
    }

    return obj
}


load_mesh_from_obj :: proc(filename: string, texturePath: cstring) -> (mesh: Mesh) {
    obj := load_obj_from_file(filename)

    mesh.pos = glm.vec3{0.0, 0.0, 0.0}
    mesh.rot = glm.vec3{0.0, 0.0, 0.0}
    mesh.scale = glm.vec3{1.0, 1.0, 1.0}

    mesh.vertices = [dynamic]Vertex{}
    mesh.indices = [dynamic]u32{}

    for i := 0; i < len(obj.indices); i+=3 {
        vert := Vertex{}
        vert.pos = obj.vertices[obj.indices[i]]
        vert.texcoord = obj.texcoords[obj.indices[i+1]]
        vert.col = glm.vec4{1.0, 1.0, 1.0, 1.0}
        append(&mesh.vertices, vert)
        append(&mesh.indices, u32(i))
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

load_mesh_via_assimp :: proc(path: cstring) -> (mesh: Mesh) {
    visit_scene_node :: proc(scene: ^assimp.aiScene,node: ^assimp.aiNode, vertexMap: ^map[Vertex]u32, vertices: ^[dynamic]Vertex, indices: ^[dynamic]u32) {
        for m := 0; m < node.mNumMeshes; m += 1 {
            sceneMeshes := cast([^]^assimp.aiMesh)scene.mMeshes
            _mesh := sceneMeshes[m]

            for f := 0; f < int(_mesh.mNumFaces); f+=1 {
                meshFaces := cast([^]assimp.aiFace)_mesh.mFaces
                _face := meshFaces[f]

                for i := 0; i < int(_face.mNumIndices); i += 1 {
                    faceIndices := cast([^]u32)_face.mIndices
                    index := faceIndices[i]

                    meshVertices := cast([^]assimp.aiVector3D)_mesh.mVertices
                    position := meshVertices[index]
                    
                    meshTextureCoords := _mesh.mTextureCoords
                    foo := cast([^]assimp.aiVector3D)(meshTextureCoords[0])
                    texture := foo[index]

                    vertex : Vertex
                    vertex.pos = glm.vec3{position.x, position.y, position.z}
                    vertex.col = glm.vec4{1.0, 1.0, 1.0, 1.0}
                    vertex.texcoord = glm.vec2{texture.x, 1.0-texture.y}
                    

                    if meshIndex, ok := vertexMap[vertex]; ok
                    {
                        append(indices, meshIndex)
                    } else {
                        append(indices, u32(len(vertices)))
                        vertexMap[vertex] = u32(len(vertices))
                        append(vertices, vertex)
                    }
                    
                }
            }
           
        }
        
        for c:=0; c < int(node.mNumChildren); c+=1 {
            _node := cast([^]^assimp.aiNode)node.mChildren
            visit_scene_node(scene, _node[c], vertexMap, vertices, indices)
        }
    }

    flags := assimp.aiPostProcessSteps.FindInstances |
            assimp.aiPostProcessSteps.ValidateDataStructure | 
            assimp.aiPostProcessSteps.OptimizeMeshes |
            assimp.aiPostProcessSteps.CalcTangentSpace |
            assimp.aiPostProcessSteps.GenSmoothNormals |
            assimp.aiPostProcessSteps.JoinIdenticalVertices |
            assimp.aiPostProcessSteps.LimitBoneWeights |
            assimp.aiPostProcessSteps.RemoveRedundantMaterials |
            assimp.aiPostProcessSteps.SplitLargeMeshes |
            assimp.aiPostProcessSteps.Triangulate |
            assimp.aiPostProcessSteps.GenUVCoords |
            assimp.aiPostProcessSteps.SortByPType | // SortByPrimitiveType??
            assimp.aiPostProcessSteps.FindDegenerates |
            assimp.aiPostProcessSteps.FindInvalidData

    scene := assimp.import_file(path, u32(flags))

    vertexMap := make(map[Vertex]u32)
    _vertices := [dynamic]Vertex{}
    _indices := [dynamic]u32{} 

    visit_scene_node(scene, scene.mRootNode, &vertexMap, &_vertices, &_indices)

    mesh.vertices = _vertices
    mesh.indices = _indices
   

    mesh.texture = load_texture("models/saulgoodman/saulgoodman.png")

    gl.GenVertexArrays(1, &mesh.vao)
    gl.BindVertexArray(mesh.vao)

    gl.GenBuffers(1, &mesh.vbo)
    gl.BindBuffer(gl.ARRAY_BUFFER, mesh.vbo)

    fmt.println("Vert size:", size_of(Vertex))
    fmt.println("Vert count:", len(mesh.vertices))
    fmt.println("Vert size * count:", size_of(Vertex) * len(mesh.vertices))

    fmt.println("Ind size:", size_of(u32))
    fmt.println("Ind count:", len(mesh.indices))
    fmt.println("Ind size * count:", size_of(u32) * len(mesh.indices))

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

load_mesh_from_sexy :: proc(path: string) -> (mesh: Mesh) {
    model_data, ok := read_obj(path)

    if !ok {
        fmt.println("Error reading file")
        return
    }

    mesh.pos = glm.vec3{0.0, 0.0, 0.0}
    mesh.rot = glm.vec3{0.0, 0.0, 0.0}
    mesh.scale = glm.vec3{1.0, 1.0, 1.0}

    mesh.vertices = [dynamic]Vertex{}
    mesh.indices = [dynamic]u32{}

    for i in 0..=len(model_data.vertex_positions)-1 {
        vertex := Vertex{
            glm.vec3{model_data.vertex_positions[i].x, model_data.vertex_positions[i].y, model_data.vertex_positions[i].z},
            glm.vec4{1, 1, 1, 1},
            glm.vec2{model_data.vertex_uvs[i].x, model_data.vertex_uvs[i].y},
        }

        append(&mesh.vertices, vertex)
    }

    
    //append(&mesh.indices, 0)
    
    for i in model_data.indices_positions {
        append(&mesh.indices, u32(i))
    }
    

    mesh.texture = load_texture("models/saulgoodman/saulgoodman.png")

    gl.GenVertexArrays(1, &mesh.vao)
    gl.BindVertexArray(mesh.vao)

    gl.GenBuffers(1, &mesh.vbo)
    gl.BindBuffer(gl.ARRAY_BUFFER, mesh.vbo)

    fmt.println("Vert size:", size_of(Vertex))
    fmt.println("Vert count:", len(mesh.vertices))
    fmt.println("Vert size * count:", size_of(Vertex) * len(mesh.vertices))

    fmt.println("Ind size:", size_of(u32))
    fmt.println("Ind count:", len(mesh.indices))
    fmt.println("Ind size * count:", size_of(u32) * len(mesh.indices))

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


// ----------------------------------- Found it online -- Emir

Vec2 :: [2]f32;
Vec3 :: [3]f32;

Model_Data :: struct {
	vertex_positions:  []Vec3,
	vertex_normals:    []Vec3,
	vertex_uvs:        []Vec2,
	indices_positions: []i32,
	indices_normals:   []i32,
	indices_uvs:       []i32,
}

free_model_data :: proc(using model_data: Model_Data) {
	delete(vertex_positions);
	delete(vertex_normals);
	delete(vertex_uvs);
	delete(indices_positions);
	delete(indices_normals);
	delete(indices_uvs);
}

print_model_data :: proc(using model_data: Model_Data, N: int) {
	for v, i in vertex_positions[:N] do fmt.printf("v[%d]: %v\n", i, v);
	for v, i in vertex_normals[:N]   do fmt.printf("vn[%d]: %v\n", i, v);
	for v, i in vertex_uvs[:N]       do fmt.printf("vt[%d]: %v\n", i, v);

	for _, i in 0..=N do fmt.printf("fv[%d]: %d %d %d\n",  i, indices_positions[3*i+0], indices_positions[3*i+1], indices_positions[3*i+2]);
	for _, i in 0..=N do fmt.printf("fvn[%d]: %d %d %d\n", i, indices_normals[3*i+0], indices_normals[3*i+1], indices_normals[3*i+2]);
	for _, i in 0..=N do fmt.printf("fvt[%d]: %d %d %d\n", i, indices_uvs[3*i+0], indices_uvs[3*i+1], indices_uvs[3*i+2]);
}

stream: string;

is_whitespace :: proc(c: u8) -> bool {
	switch c {
	case ' ', '\t', '\n', '\v', '\f', '\r', '/': return true;
	}
	return false;
}

skip_whitespace :: proc() #no_bounds_check {
	for stream != "" && is_whitespace(stream[0]) do stream = stream[1:];
}

skip_line :: proc() #no_bounds_check {
	N := len(stream);
	for i := 0; i < N; i += 1 {
		if stream[0] == '\r' || stream[0] == '\n' {
			skip_whitespace();
			return;
		}
		stream = stream[1:];
	}
}

next_word :: proc() -> string #no_bounds_check {
	skip_whitespace();

	for i := 0; i < len(stream); i += 1 {
		if is_whitespace(stream[i]) || i == len(stream)-1 {
			current_word := stream[0:i];
			stream = stream[i+1:];
			return current_word;
		}
	}
	return "";
}

// @WARNING! This assumes the obj file is well formed. 
//
//   Each v, vn line has to have at least 3 elements. Every element after the third is discarded
//   Each vt line has to have at least 2 elements. Every element after the second is discarded
//   Each f line has to have at least 9 elements. Every element after the ninth is discarded
//
//   Note that we only support files where the faces are specified as A/A/A B/B/B C/C/C
//   Note also that '/' is regarded as whitespace, to simplify the face parsing
read_obj :: proc(filename: string) -> (Model_Data, bool) #no_bounds_check {
	to_f32 :: strconv.parse_f32;
	to_i32 :: proc(str: string) -> i32 {
        val, _ := strconv.parse_int(str)
        return cast(i32)val
    }

	data, status := os.read_entire_file(filename);
	if !status do return Model_Data{}, false;
	defer delete(data);

	vertex_positions:  [dynamic]Vec3;
	vertex_normals:    [dynamic]Vec3;
	vertex_uvs:        [dynamic]Vec2;
	indices_positions: [dynamic]i32;
	indices_normals:   [dynamic]i32;
	indices_uvs:       [dynamic]i32;

	stream = string(data);
	for stream != "" {
		current_word := next_word();

		switch current_word {
		case "v": 
            w1, _ := to_f32(next_word())
            w2, _ := to_f32(next_word())
            w3, _ := to_f32(next_word())
			append(&vertex_positions, Vec3{w1, w2, w3});
		case "vn": 
            w1, _ := to_f32(next_word())
            w2, _ := to_f32(next_word())
            w3, _ := to_f32(next_word())
			append(&vertex_normals, Vec3{w1, w2, w3});
		case "vt": 
            w1, _ := to_f32(next_word())
            w2, _ := to_f32(next_word())
			append(&vertex_uvs, Vec2{w1, w2});
		case "f": 
			indices: [9]i32;
			for i in 0..=9 { 
                indices[i] = to_i32(next_word())-1; 
            }
			append(&indices_positions, indices[0], indices[3], indices[6]);
			append(&indices_normals,   indices[1], indices[4], indices[7]);
			append(&indices_uvs,       indices[2], indices[5], indices[8]);
		}
		skip_line();
	}

	fmt.printf("vertex positions = %d, vertex normals = %d, vertex uvs = %d\n", len(vertex_positions), len(vertex_normals), len(vertex_uvs));
	fmt.printf("indices positions = %d, indices normals = %d, indices uvs = %d\n", len(indices_positions), len(indices_normals), len(indices_uvs));
	
	return Model_Data{vertex_positions[:], vertex_normals[:], vertex_uvs[:], 
		              indices_positions[:], indices_normals[:], indices_uvs[:]}, true;
}