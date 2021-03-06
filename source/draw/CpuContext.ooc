//
// Copyright (c) 2011-2014 Simon Mika <simon@mika.se>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
use ooc-base
use ooc-draw
use ooc-math

CpuContext: class extends AbstractContext {
	init: func
	createMonochrome: func (size: IntVector2D) -> RasterMonochrome { RasterMonochrome new(size) }
	createBgr: func (size: IntVector2D) -> RasterBgr { RasterBgr new(size) }
	createBgra: func (size: IntVector2D) -> RasterBgra { RasterBgra new(size) }
	createUv: func (size: IntVector2D) -> RasterUv { RasterUv new(size) }
	createImage: func (rasterImage: RasterImage) -> RasterImage { rasterImage copy() }
	createYuv420Semiplanar: func (size: IntVector2D) -> RasterYuv420Semiplanar { RasterYuv420Semiplanar new(size) }
	createYuv420Semiplanar: func ~fromImages (y, uv: Image) -> RasterYuv420Semiplanar { RasterYuv420Semiplanar new(y as RasterMonochrome, uv as RasterUv) }
	createYuv420Semiplanar: func ~fromRaster (raster: RasterYuv420Semiplanar) -> RasterYuv420Semiplanar { raster copy() }
	update: func
}
