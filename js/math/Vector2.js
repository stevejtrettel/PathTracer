// Trimmed copy of three.js's Vector2 (https://github.com/mrdoob/three.js —
// MIT License, Copyright 2010-2023 three.js authors). This project uses it
// only as an {x,y} value carrier for vec2 uniforms.

class Vector2 {

	constructor( x = 0, y = 0 ) {

		this.x = x;
		this.y = y;

	}

	set( x, y ) {

		this.x = x;
		this.y = y;

		return this;

	}

	clone() {

		return new this.constructor( this.x, this.y );

	}

	copy( v ) {

		this.x = v.x;
		this.y = v.y;

		return this;

	}

}

export { Vector2 };
