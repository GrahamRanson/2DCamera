--- Required libraries.
local Lerper = require( "2DCamera.lerper" )

-- Localised functions.

-- Localised values.

--- Class creation.
local Camera = {}

-- Static values.

--- Initiates a new Camera object.
-- @param params A table containing the definition for this Camera.
-- @return The new Camera.
function Camera.new( params )

	-- Create ourselves
	local self = {}

    for k, v in pairs( params or {} ) do
        self[ k ] = v
    end

	self._lerper = Lerper.new( params or {} )

    self.x = self.x or 0
    self.y = self.y or 0
	self.zoom = self.zoom or 1
	self.rotation = self.rotation or 0

    self._focus = display.newCircle( self.view, 0, 0, 10 )
	self._focus:setFillColor( 0, 0, 0, 0 )
	self._focus:setStrokeColor( 1, 1, 1 )
	self._focus.strokeWidth = 2
    self._focus.isVisible = false

    self.smoothing = self.smoothing or 0.07

    function self.update( dt )

        local x, y = self._focus:localToContent( 0, 0 )
        x, y = display.contentCenterX - x, display.contentCenterY - y

        self.setPosition( self.x + x, self.y + y )

		if self.getMinZoom() and self.zoom < self.getMinZoom() then
			self.zoom = self.getMinZoom()
		elseif self.getMaxZoom() and self.zoom > self.getMaxZoom() then
			self.zoom = self.getMaxZoom()
		end

		self.view.xScale, self.view.yScale = self.zoom, self.zoom
		self.view.rotation = self.rotation

        self._focus:toFront()

    end


    function self.focusOn( x, y, zoom, rotation )

		self._focus.x = self.isSmoothingDisabled() and x or self._lerper.lerp( self._focus.x, x ) --, self.smoothing )
        self._focus.y = self.isSmoothingDisabled() and y or self._lerper.lerp( self._focus.y, y ) --, self.smoothing )

		if zoom then
			if self.getMaxZoom() and zoom > self.getMaxZoom() then
				zoom = self.getMaxZoom()
			elseif self.getMinZoom() and zoom < self.getMinZoom() then
				zoom = self.getMinZoom()
			end
		end

		self.zoom = self.isSmoothingDisabled() and zoom or self._lerper.lerp( self.zoom, ( zoom or 1 ), self.smoothing * 1 )

		self.rotation = self.isRotationLocked() and self.rotation or ( self.isSmoothingDisabled() and rotation or self._lerper.lerp( self.rotation, ( rotation or 1 ) ) )

    end

	function self.getZoom()
		return self.zoom
	end

	function self.setMaxZoom( zoom )
		self.maxZoom = zoom
	end

	function self.getMaxZoom()
		return self.maxZoom
	end

	function self.getMinZoom()
		return self.minZoom
	end

	function self.setMinZoom( zoom )
		self.minZoom = zoom
	end

	function self.lockRotation()
		self._rotationLocked = true
	end

	function self.unlockRotation()
		self._rotationLocked = false
	end

	function self.isRotationLocked()
		return self._rotationLocked
	end

	function self.setSmoothing( speed )
		self.smoothing = speed
	end

	function self.getSmoothing()
		return self.smoothing
	end

	function self.disableSmoothing()
		self._smoothingDisabled = true
	end

	function self.enableSmoothing()
		self._smoothingDisabled = false
	end

	function self.isSmoothingDisabled()
		return self._smoothingDisabled
	end

    function self.setPosition( x, y )
        self.x, self.y = ( x or self.x or 0 ), ( y or self.y or 0 )
        self.view.x, self.view.y = self.x, self.y
    end

    function self.getPosition()
        return self.x, self.y
    end

	function self.jumpTo( x, y, zoom, rotation )

		self.zoom = ( zoom or self.zoom or 1 )
		self.rotation = ( rotation or self.rotation or 0 )
		self._focus.x = ( x or self.x or 0 )
		self._focus.y = ( y or self.y or 0 )

	end

	function self.setBounds( xMin, yMin, xMax, yMax )
		self._bounds = { xMin = xMin, yMin = yMin, xMax = xMax, yMax = yMax }
	end

	function self.getBounds()
		return self._bounds or { xMin = 0, yMin = 0, xMax = self.view.contentWidth, yMax = self.view.contentHeight }
	end

	function self.clampPosition()

		if self.x > self.getBounds().xMin then
			self.x = self.getBounds().xMin
			self.view.x = self.x
		elseif self.x < -( self.getBounds().xMax - display.contentWidth ) then
			self.x = -( self.getBounds().xMax - display.contentWidth )
		end

		if self.y > self.getBounds().yMin then
			self.y = self.getBounds().yMin
			self.view.y = self.y
		elseif self.y < -( self.getBounds().yMax - display.contentHeight ) then
			self.y = -( self.getBounds().yMax - display.contentHeight )
		end

		self.view.x, self.view.y = self.x, self.y

	end

	--self.disableSmoothing()
	--self.lockRotation()

	-- Return the Camera object
	return self

end

-- Return the Camera class
return Camera
