import math
use ooc-math
FloatImage : class {
	// x = column
	// y = row
	_size: IntVector2D
	size ::= _size
	_pointer: Float*
	pointer ::= this _pointer
	init: func ~IntVector2D (=_size)
	init: func ~WidthAndHeight (width, height: Int) {
		this _size = IntVector2D new(width, height)
		this _pointer = gc_malloc(width * height * Float instanceSize)
	}

	operator [] (x, y: Int) -> Float {
		version(safe) {
			if (x > _size x || y > _size y || x < 0 || y < 0)
				raise("Accessing FloatImage index out of range in get")
		}
		(this _pointer + (x + this _size x * y))@ as Float
	}

	operator []= (x, y: Int, value: Float) {
		version(safe) {
			if (x > _size x || y > _size y || x < 0 || y < 0)
				raise("Accessing FloatImage index out of range in set")
		}
		(this _pointer + (x + this _size x * y))@ = value
	}
	free: override func {
		gc_free(this _pointer)
		super()
	}
}
