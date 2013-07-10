module ( ..., package.seeall )

local vsh = [[

	attribute vec4 position;
	attribute vec2 uv;
	attribute vec4 color;

	varying LOWP vec4 colorVarying;
	varying MEDP vec2 uvVarying;

	void main () {
		gl_Position = position;
		uvVarying = uv;
		colorVarying = color;
	}

]]

local fsh = [[

	varying LOWP vec4 colorVarying;
	varying MEDP vec2 uvVarying;

	uniform sampler2D sampler;

	void main () {
		if ( colorVarying.r < 0.9 ) {
			gl_FragColor = texture2D ( sampler, uvVarying );
		}
		else {
			vec4 clr = texture2D ( sampler, uvVarying ) + vec4(0.3, 0.3, 0.3, 0.0);
			gl_FragColor = vec4(clr.rgb * clr.a, clr.a);
		}
	}

]]

local color = MOAIColor.new ()
color:setColor ( 0.3, 0.3, 0.3, 0.0 )
--color:moveColor ( 1, 0, 0, 1, 5 )

local shader = MOAIShader.new ()
shader:reserveUniforms ( 0 )
--shader:reserveUniforms ( 1 )
--shader:declareUniform ( 1, 'lightenBy', MOAIShader.UNIFORM_COLOR )

--shader:setAttrLink ( 1, color, MOAIColor.COLOR_TRAIT )

shader:setVertexAttribute ( 1, 'position' )
shader:setVertexAttribute ( 2, 'uv' )
shader:setVertexAttribute ( 3, 'color' )
shader:load ( vsh, fsh )

_G.lightenShader = shader
--_G.lightenColor = color
