--- Required libraries.

--- Required libraries.

-- Localised functions.
local abs = math.abs

-- Localised values.

--- Class creation.
local Lerper = {}

--- Initiates a new Lerper object.
-- @return The new Lerper.
function Lerper.new( options )

	-- Create ourselves
	local self = {}

    self._previous_velocity = 0

    local options = options or {}

    self.amount = options.amount or 0.07
    self.acceleration = options.acceleration or math.huge
    self.minVelocity = options.minVelocity or 0
    self.maxVelocity = options.maxVelocity or math.huge

    function self.lerpVelocity( position, target, amount )
        return ( target - position ) * ( amount or self.amount )
    end


    function self.lerp( position, target, amount )

        -- get the amount to move
        local v = self.lerpVelocity( position, target, amount )

        -- if its zero just return
        if v == 0 then return target end

        -- store this value
        local vo = v

        -- don't allow increases in velocity beyond the specifed acceleration (ease in)
        -- this also makes for smooth changes when switching direction
        --
        -- only bother doing this if we're speeding up or changing direction
        -- because the lerp takes care of the smoothing when slowing down
        --
        -- note that multiplying two numbers together to check whether they are both
        -- positive or negative is prone to overflow errors but as this class will
        -- realistically never be used for such massive numbers we should be OK!
         if v * self._previous_velocity < 0 or abs( v ) > abs( self._previous_velocity ) then
             if ( v>0 and self._previous_velocity>=0 and  v - self._previous_velocity > self.acceleration ) then
                 v = self._previous_velocity + self.acceleration
            elseif ( v < 0 and self._previous_velocity <= 0 and  self._previous_velocity - v > self.acceleration) then
                 v = self._previous_velocity - self.acceleration
             end
         end

         -- If this is less than the minimum velocity then
         -- clamp at minimum velocity
         if abs( v ) < self.minVelocity then
             v = (vo > 0) and self.minVelocity or 0 - self.minVelocity
         -- If this is more than the maximum velocity then
         -- clamp at maximum velocity
        elseif (abs(v) > self.maxVelocity) then

             v = (vo > 0) and self.maxVelocity or 0 - self.maxVelocity;
         -- Remember the previous velocity
            self._previous_velocity = v
        end

         -- Adjust the position based on the new velocity
         position = position + v
         -- Now account for potential overshoot and clamp to target if necessary
         if ( (vo<0 and position<=target) or (vo > 0 and position >= target)) then
             position = target
             --if(OnReachedTarget!=null) OnReachedTarget();
         end

         return position

    end


    -- Return the Lerper object
	return self

end

return Lerper
