-- Per-picker prompt history for telescope.
--
-- The built-in handler (actions.history.get_simple_history) keeps one flat list
-- shared by every picker, so a Live Grep prompt cycles through Find Files paths
-- too. This keeps one bucket per picker, keyed by prompt title, in a JSON file.

local M = {}

local function read_store(path)
  local fd = io.open(path, "r")
  if not fd then
    return {}
  end
  local raw = fd:read("*a")
  fd:close()

  local ok, decoded = pcall(vim.json.decode, raw)
  if not ok or type(decoded) ~= "table" then
    return {}
  end
  return decoded
end

local function write_store(path, store)
  local fd = io.open(path, "w")
  if not fd then
    return
  end
  fd:write(vim.json.encode(store))
  fd:close()
end

-- Bucket of the picker that is asking. Returned table is the live one, so the
-- History index arithmetic in get_prev/get_next stays consistent with it.
local function bucket(self, picker)
  local key = picker and picker.prompt_title or "Telescope"
  if type(self.store[key]) ~= "table" then
    self.store[key] = {}
  end
  return key, self.store[key]
end

function M.handler()
  return require("telescope.actions.history").new({
    init = function(obj)
      obj.store = read_store(obj.path)
      obj.key = nil
      obj.content = {}
      obj.index = 1
    end,

    -- Swap in the asking picker's bucket before it cycles
    pre_get = function(self, _, picker)
      local key, entries = bucket(self, picker)
      if self.key ~= key then
        self.key = key
        self.content = entries
        self.index = #entries + 1
      end
    end,

    append = function(self, line, picker, no_reset)
      if line ~= "" then
        local key, entries = bucket(self, picker)
        if self.key ~= key then
          self.key = key
          self.content = entries
        end

        if entries[#entries] ~= line then
          table.insert(entries, line)
          while self.limit and #entries > self.limit do
            table.remove(entries, 1)
          end
          write_store(self.path, self.store)
        end
      end

      if not no_reset then
        self:reset()
      end
    end,

    reset = function(self)
      self.index = #self.content + 1
    end,
  })
end

return M
