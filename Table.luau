local extender = function(t: {}, ...: {} | Instance)
	local extensions = table.pack(...)
	local function findTarget(index: string)
		for _, extension in ipairs(extensions) do
			local success, extensionType = pcall(function() 
				if typeof(extension) == "table" and extension[index] == nil then
					error()
				else 
					local a = extension[index]
				end
				return type(extension)
			end)
			if success then
				return extension, extensionType
			end
		end
	end
	local mt = {
		__index = function(_, index: string)
			local targetExtension, extensionType = findTarget(index)
			if targetExtension == nil then
				return nil
			elseif type(targetExtension[index]) == "function" then
				return function(t, ...)
					return targetExtension[index](if extensionType == "table" then t else targetExtension, ...)
				end
			else
				return targetExtension[index]
			end
		end,
		__newindex = function(_, index: string, value: any)
			local targetExtension = findTarget(index)
			if targetExtension == nil then
				rawset(t, index, value)
			else
				targetExtension[index] = value
			end
		end,
	}
	return setmetatable(t, mt)
end

local Signal = {}

function Signal.new()
	local self: BindableEvent & RBXScriptSignal = {}
	self.Event = Instance.new("BindableEvent")
	extender(self, self.Event.Event, self.Event)
	return self
end


local Dictionary = {}
type Dictionary<T> = {
	Changed: typeof(Signal.new()),
	Raw: T,
	Destroy: (self: Dictionary<T>) -> nil
}

function Dictionary.new<T>(table: T): T & Dictionary<T>
	local self = {}
	self.Changed = Signal.new()
	self.Raw = table
	self.Dictionaries = {}
	
	local function createDictionary(k, v)
		local newT = Dictionary.new(v)
		self.Dictionaries[k] = newT
		newT.Changed:Connect(function()
			self.Changed:Fire()
		end)
		self.Changed.Destroying:Once(function()
			newT.Changed:Destroy()
		end)
	end

	function self:Destroy()
		self.Changed:Destroy()
	end

	local mt = {
		__index = function(t, i)
			if type(rawget(table, i)) == "table" then
				return rawget(self, "Dictionaries")[i]
			end
			return table[i]            
		end,
		__newindex = function(t, i, v)
			if table[i] == v then
				return
			end
			
			if type(v) == "table" then
				createDictionary(i, v)
			end
			
			table[i] = v
			self.Changed:Fire()
			return table[i]
		end,
	}

	for k, v in table do
		if type(v) == "table" then
			createDictionary(k, v)
		end
	end

	setmetatable(self, mt)

	return self
end

return Dictionary