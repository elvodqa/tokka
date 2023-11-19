package main

import sdl "vendor:sdl2"
import gl "vendor:OpenGL"
import glm "core:math/linalg/glsl"

import "core:fmt"
import "core:time"

import "graphics"
import imgui "../odin-imgui"
import "../odin-imgui/imgui_impl_sdl2"
import "../odin-imgui/imgui_impl_opengl3"


lightPos: [3]f32 = {1.2, 1.0, 2.0}
lightDiffuse: [3]f32 = {300, 300, 92}

main :: proc() {
    WINDOW_WIDTH  :: 1280
	WINDOW_HEIGHT :: 720

    window := sdl.CreateWindow("Tokka", sdl.WINDOWPOS_UNDEFINED, sdl.WINDOWPOS_UNDEFINED, WINDOW_WIDTH, WINDOW_HEIGHT, {.OPENGL})
	if window == nil {
		fmt.eprintln("Failed to create window")
		return
	}
	defer sdl.DestroyWindow(window)

    
    when ODIN_OS == .Darwin {
        sdl.GL_SetAttribute(sdl.GLattr.CONTEXT_MAJOR_VERSION, 4)
        sdl.GL_SetAttribute(sdl.GLattr.CONTEXT_MINOR_VERSION, 1)
        sdl.GL_SetAttribute(sdl.GLattr.CONTEXT_PROFILE_MASK, cast(i32)sdl.GLprofile.CORE)
        sdl.GL_SetAttribute(sdl.GLattr.CONTEXT_FLAGS, cast(i32)sdl.GLcontextFlag.FORWARD_COMPATIBLE_FLAG)
    } else {
        sdl.GL_SetAttribute(sdl.GLattr.CONTEXT_MAJOR_VERSION, 4)
        sdl.GL_SetAttribute(sdl.GLattr.CONTEXT_MINOR_VERSION, 1)
    }
    

    // vsync
    sdl.GL_SetSwapInterval(1)
    

    gl_context := sdl.GL_CreateContext(window)
	sdl.GL_MakeCurrent(window, gl_context)

	gl.load_up_to(3, 3, sdl.gl_set_proc_address)

    imgui.CHECKVERSION()
    imgui.CreateContext(nil)
    defer imgui.DestroyContext(nil)
    io := imgui.GetIO()
	io.ConfigFlags += {.NavEnableKeyboard, .NavEnableGamepad}
	when imgui.IMGUI_BRANCH == "docking" {
		io.ConfigFlags += {.DockingEnable}
		io.ConfigFlags += {.ViewportsEnable}

		style := imgui.GetStyle()
		style.WindowRounding = 0
		style.Colors[imgui.Col.WindowBg].w =1
	}
    imgui.StyleColorsDark(nil)

    imgui_impl_sdl2.InitForOpenGL(window, gl_context)
	defer imgui_impl_sdl2.Shutdown()
	imgui_impl_opengl3.Init(nil)
	defer imgui_impl_opengl3.Shutdown()


    program, program_ok := gl.load_shaders_file("shaders/model.vert", "shaders/model.frag")
    if !program_ok {
        fmt.eprintln("Failed to load shaders")
        return
    }
    defer gl.DeleteProgram(program)
    

    cube := graphics.load_mesh_as_cube("textures/a.png")
    sprite := graphics.new_sprite(graphics.load_texture("textures/a.png"), glm.vec3{2.0, 2.0, 2.0}, glm.vec2{100, 100}, glm.vec3{0, 0, 0}, glm.vec4{1.0, 1.0, 1.0, 1.0})
    
    
    gl.UseProgram(program)
    uniforms := gl.get_uniforms_from_program(program)
	defer delete(uniforms)

    gl.Uniform3f(uniforms["material.ambient"].location, 1.0, 0.5, 0.31)
    gl.Uniform3f(uniforms["material.diffuse"].location, 1.0, 0.5, 0.31)
    gl.Uniform3f(uniforms["material.specular"].location, 0.5, 0.5, 0.5)
    gl.Uniform1f(uniforms["material.shininess"].location, 32.0)

    gl.Uniform3f(uniforms["world_color"].location, 1.0, 1.0, 1.0)
    gl.Uniform1f(uniforms["modelTexture"].location, 0)

    gl.Uniform3f(uniforms["light1.position"].location, lightPos[0], lightPos[1], lightPos[2])
    gl.Uniform3f(uniforms["light1.diffuse"].location, lightDiffuse[0], lightDiffuse[1], lightDiffuse[2])

    last_mouse_position: glm.vec2
    camera := graphics.new_camera(
        glm.vec3{0.0, 0.0, 3.0},
        glm.vec3{0.0, 0.0, 0.0},
        glm.vec3{0.0, 1.0, 0.0},
        WINDOW_WIDTH/WINDOW_HEIGHT)


    frameStart, frameTime: u32
    maxFPS :: 60


    sdl.ShowCursor(0)

    mouseCaptured := true
    
    loop: for {
        frameStart = sdl.GetTicks()
    
		event: sdl.Event
		for sdl.PollEvent(&event) != false {
            imgui_impl_sdl2.ProcessEvent(&event)
			#partial switch event.type {
			case .KEYDOWN:
				#partial switch event.key.keysym.sym {
				case .ESCAPE:
					break
                case .F1:
                    mouseCaptured = !mouseCaptured
                    break
				}
			case .QUIT:
				break loop
            case .MOUSEMOTION:
                if !mouseCaptured {
                    break
                }
                look_sensitivity :f32= 0.1
                if (last_mouse_position == glm.vec2{0.0, 0.0}) {
                    last_mouse_position = glm.vec2{f32(event.motion.x), f32(event.motion.y)}
                } else {
                    offsetX := (f32(event.motion.x) - last_mouse_position.x) * look_sensitivity
                    offsetY := (last_mouse_position.y - f32(event.motion.y)) * look_sensitivity
                    last_mouse_position = glm.vec2{f32(event.motion.x), f32(event.motion.y)}
                    graphics.modify_camera_direction(&camera, offsetX, offsetY)
                }
                update_camera(camera, uniforms)
                break
            }
		}
        
        if mouseCaptured {
           
            if sdl.GetKeyboardState(nil)[sdl.SCANCODE_W] != 0 {
                camera.position += camera.front * 0.01
                update_camera(camera, uniforms)
            }
            if sdl.GetKeyboardState(nil)[sdl.SCANCODE_S] != 0 {
                camera.position -= camera.front * 0.01
                update_camera(camera, uniforms)
            }
            if sdl.GetKeyboardState(nil)[sdl.SCANCODE_A] != 0 {
                camera.position -= glm.normalize(glm.cross(camera.front, camera.up)) * 0.01
                update_camera(camera, uniforms)
            }
            if sdl.GetKeyboardState(nil)[sdl.SCANCODE_D] != 0 {
                camera.position += glm.normalize(glm.cross(camera.front, camera.up)) * 0.01
                update_camera(camera, uniforms)
            }

        }
       

        imgui_impl_opengl3.NewFrame()
		imgui_impl_sdl2.NewFrame()
		imgui.NewFrame()

		imgui.ShowDemoWindow(nil)

        debug_window()
		imgui.Render()

        gl.Enable(gl.DEPTH_TEST)
        gl.DepthFunc(gl.LESS)
        gl.Enable(gl.BLEND)
        gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
        

		gl.Viewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
		gl.ClearColor(0.5, 0.7, 1.0, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
        
        gl.UseProgram(program)
          
        
        uModel := graphics.get_mesh_model(cube)
        gl.UniformMatrix4fv(uniforms["uModel"].location, 1, false, &uModel[0, 0])

        gl.Uniform3f(uniforms["light1.position"].location, lightPos[0], lightPos[1], lightPos[2])
        gl.Uniform3f(uniforms["light1.diffuse"].location, lightDiffuse[0], lightDiffuse[1], lightDiffuse[2])

        
        graphics.draw_mesh(cube)

        uModel = graphics.get_sprite_model(sprite)

        gl.UniformMatrix4fv(uniforms["uModel"].location, 1, false, &uModel[0, 0])

        graphics.draw_sprite(sprite)
        

		
        imgui_impl_opengl3.RenderDrawData(imgui.GetDrawData())
        when imgui.IMGUI_BRANCH == "docking" {
			backup_current_window := sdl.GL_GetCurrentWindow()
			backup_current_context := sdl.GL_GetCurrentContext()
			imgui.UpdatePlatformWindows()
			imgui.RenderPlatformWindowsDefault()
			sdl.GL_MakeCurrent(backup_current_window, backup_current_context);
		}
		
		sdl.GL_SwapWindow(window)	


        if mouseCaptured {
            sdl.CaptureMouse(true)

            x, y: i32
            sdl.GetMouseState(&x, &y)
            if x < 0 || x > WINDOW_WIDTH || y < 0 || y > WINDOW_HEIGHT {
                sdl.WarpMouseInWindow(window, WINDOW_WIDTH/2, WINDOW_HEIGHT/2)
                last_mouse_position = glm.vec2{0.0, 0.0}
            }    
        }
       

        frameTime = sdl.GetTicks() - frameStart
        if frameTime < 1000/maxFPS {
            sdl.Delay(1000/maxFPS - frameTime)
        }
	}
}


debug_window :: proc() {
    io := imgui.GetIO()
    flags := imgui.WindowFlags{.NoTitleBar, .NoResize, .NoMove, .NoCollapse, .NoSavedSettings, .NoFocusOnAppearing, .NoBringToFrontOnFocus}

    PAD :: 10
    viewport := imgui.GetMainViewport()
    work_pos := viewport.WorkPos
    work_size := viewport.WorkSize
    window_pos, window_pos_pivot: imgui.Vec2
    window_pos.x = work_pos.x + PAD
    window_pos.y = work_pos.y + PAD
    window_pos_pivot.x = 0
    window_pos_pivot.y = 0

    imgui.SetNextWindowPos(window_pos, .Always)
    imgui.SetNextWindowBgAlpha(0.35)

    imgui.Begin("Debug", nil, flags)
    imgui.Text("Scene: Demo Scene")
    imgui.Separator()


    imgui.DragFloat3("Light Position", &lightPos)
    imgui.DragFloat3("Light Diffuse", &lightDiffuse)
    
    imgui.End()
}


update_camera :: proc(camera: graphics.Camera, uniforms: gl.Uniforms) {
    uView := graphics.get_camera_view(camera)
    gl.UniformMatrix4fv(uniforms["uView"].location, 1, false, &uView[0, 0])

    camProj := graphics.get_camera_projection(camera)
    gl.UniformMatrix4fv(uniforms["uProjection"].location, 1, false, &camProj[0, 0])  

    viewPos := camera.position
    gl.Uniform3f(uniforms["viewPos"].location, viewPos.x, viewPos.y, viewPos.z) 
}