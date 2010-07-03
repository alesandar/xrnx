--[[----------------------------------------------------------------------------
-- Duplex.UIComponent
----------------------------------------------------------------------------]]--

--[[

Inheritance: UIComponent 

The base class for UI objects

--]]


--==============================================================================

class 'UIComponent' 

function UIComponent:__init(display)
  TRACE("UIComponent:__init")
  
  self.canvas = Canvas()
  
  -- the parent display
  self.display = display 
  
  -- for indexed elements
  self.group_name = nil

  -- set through set_size()
  self.width = 1 
  self.height = 1 

  -- default palette
  self.palette = {}

  -- pos in canvas
  self.x_pos = 1
  self.y_pos = 1

  -- request refresh
  self.dirty = true 

  -- sync our width, height with the canvas
  UIComponent.set_size(self, self.width, self.width)
end


--------------------------------------------------------------------------------

--  request update on next refresh

function UIComponent:invalidate()
  TRACE("UIComponent:invalidate")

  self.dirty = true
end


--------------------------------------------------------------------------------

-- draw() - update the visual definition

function UIComponent:draw()
  --TRACE("UIComponent:draw")

  self.dirty = false
end


--------------------------------------------------------------------------------

-- get_msg()  returns the last broadcast event 
-- (used by event handlers)

function UIComponent:get_msg()
  return self.display.device.message_stream.current_message
end


--------------------------------------------------------------------------------

-- set_size()  important to use this instead 
-- of setting width/height directly (because of canvas)

function UIComponent:set_size(width, height)
  TRACE("UIComponent:set_size", width, height)

  self.canvas:set_size(width, height)
  self.width = width      
  self.height = height
end


--------------------------------------------------------------------------------

-- perform simple "inside square" hit test
-- @return (boolean) true if inside area

function UIComponent:test(x_pos, y_pos)
--TRACE("UIComponent:test(",x_pos, y_pos,")")

  -- pressed to the left or above?
  if (x_pos < self.x_pos) or 
     (y_pos < self.y_pos) 
  then
    return false
  end
  
  -- pressed to the right or below?
  if (x_pos >= self.x_pos + self.width) or 
     (y_pos >= self.y_pos + self.height) 
  then
    return false
  end
  
  return true
end


--------------------------------------------------------------------------------

-- set palette, invalidate if changed
-- @colors: a table of color values, e.g {background={color{0x00,0x00,0x00}}}

function UIComponent:set_palette(palette)

  local changed = false

  for i,__ in pairs(palette)do
    for k,v in pairs(palette[i])do
      if(self.palette[i][k])then
        if(type(v)=="table")then
          if(not table_compare(self.palette[i][k],v))then
            self.palette[i][k] = table.rcopy(v)
            changed = true
          end
        elseif(type(v)=="string")then
          if(self.palette[i][k] ~= v)then
            self.palette[i][k] = v
            changed = true
          end
        end
      end
    end
  end

  if (changed) then
    self:invalidate()
  end
end


--------------------------------------------------------------------------------

-- simple color adjustment: 
-- store original color values as "_color", so we are able 
-- to call this method several times without loosing the 
-- original color information

function UIComponent:colorize(rgb)
  TRACE("UIComponent:colorize:",rgb)

  local changed = false
  
  for k,v in pairs(self.palette) do
    if not (v._color) then
      self.palette[k]._color = table.copy(v.color)
    end

    for c=1,3 do
      local color_value = v._color[c] * rgb[c] / 255
      if (color_value ~= v.color[c]) then
        v.color[c] = color_value   
        changed = true  
      end
    end
  end

  if (changed) then
    self:invalidate()
  end
end


--------------------------------------------------------------------------------

function UIComponent:add_listeners()
  -- override to specify your own event handlers 
end


--------------------------------------------------------------------------------

function UIComponent:remove_listeners()
  -- override to remove specified event handlers 
end


--------------------------------------------------------------------------------

function UIComponent:__eq(other)
  -- only check for object identity
  return rawequal(self, other)
end  


--------------------------------------------------------------------------------

function UIComponent:__tostring()
  return type(self)
end  
