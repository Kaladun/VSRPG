function initShaders()
	shaderGreyOut = love.graphics.newShader[[
		vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
			vec4 pixel = Texel(texture, texture_coords );
			pixel.r = (pixel.r + 0.5) * 0.5;
			pixel.g = (pixel.g + 0.5) * 0.5;
			pixel.b = (pixel.b + 0.5) * 0.5;
			return pixel;
		}
	]]
	
	shaderFlash = love.graphics.newShader[[
		extern number magnitude;
		vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
			vec4 pixel = Texel(texture, texture_coords );
			return vec4((1.0 - magnitude*magnitude) * pixel.rgb + magnitude * magnitude * vec3(1.0, 1.0, 1.0), pixel.a);
		}
	]]
end