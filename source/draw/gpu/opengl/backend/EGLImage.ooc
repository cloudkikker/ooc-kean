/*
* Copyright (C) 2014 - Simon Mika <simon@mika.se>
*
* This sofware is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/

use ooc-base
use ooc-math
import egl/egl
import GLTexture, GLContext

EGLImage: class extends GLTexture {
	_eglBackend: Pointer
	_eglDisplay: Pointer
	_nativeBuffer: Pointer
	_backendTexture: GLTexture
	/* PRIVATE CONSTRUCTOR, USE STATIC CREATE FUNCTION!!! */
	init: func (type: TextureType, size: IntSize2D, =_nativeBuffer, context: GLContext) {
		super(type, size)
		this _eglDisplay = context _eglDisplay
		this _backendTexture = context createTexture(type, size, size width, null, false)
		/*this _backendTexture bind()*/
		this bindSibling()
	}
	free: override func {
		This _eglDestroyImageKHR(this _eglDisplay, this _eglBackend)
		super()
	}
	bindSibling: func {
		eglImageAttributes := [EGL_IMAGE_PRESERVED_KHR, EGL_FALSE, EGL_NONE] as Int*
		this _eglBackend = This _eglCreateImageKHR(this _eglDisplay, EGL_NO_CONTEXT, EGL_NATIVE_BUFFER_ANDROID, this _nativeBuffer, eglImageAttributes)
		This _glEGLImageTargetTexture2DOES(this _target, this _eglBackend)
	}

	_eglCreateImageKHR: static Func(Pointer, Pointer, UInt, Pointer, Int*) -> Pointer
	_eglDestroyImageKHR: static Func(Pointer, Pointer)
	_glEGLImageTargetTexture2DOES: static Func(UInt, Pointer)
	_initialized: static Bool = false
	initialize: static func {
		if (!This _initialized) {
			This _eglCreateImageKHR = (eglGetProcAddress("eglCreateImageKHR" toCString()), null) as Func(Pointer, Pointer, UInt, Pointer, Int*) -> Pointer
			This _eglDestroyImageKHR = (eglGetProcAddress("eglDestroyImageKHR" toCString()), null) as Func(Pointer, Pointer)
			This _glEGLImageTargetTexture2DOES = (eglGetProcAddress("glEGLImageTargetTexture2DOES" toCString()), null) as Func(UInt, Pointer)
			This _initialized = true
		}
	}
	create: static func (type: TextureType, size: IntSize2D, nativeBuffer: Pointer, context: GLContext) -> This {
		This initialize()
		result: This = null
		if (type == TextureType Rgba || type == TextureType Rgb || type == TextureType Bgr || type == TextureType Rgb || type == TextureType Yv12) {
			result = This new(type, size, nativeBuffer, context)
		}
		result
	}
	generateMipmap: func { _backendTexture generateMipmap() }
	bind: func (unit: UInt) { _backendTexture bind(unit) }
	unbind: func { _backendTexture unbind() }
	upload: func (pixels: Pointer, stride: Int) { _backendTexture upload(pixels, stride) }
	setMagFilter: func (interpolation: InterpolationType) { _backendTexture setMagFilter(interpolation) }
	setMinFilter: func (interpolation: InterpolationType) { _backendTexture setMinFilter(interpolation) }
}
