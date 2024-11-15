-- At the top of typescript-routes.lua
local log_file = io.open(vim.fn.stdpath "cache" .. "/typescript-routes.log", "a")
local function log(...)
  if log_file then
    log_file:write(string.format("[%s] ", os.date "%Y-%m-%d %H:%M:%S"))
    log_file:write(string.format(...) .. "\n")
    log_file:flush()
  end
end

-- Replace all print() calls with log()
local api = vim.api
local function find_controller_method(bufnr, controller_name, method_name)
  log("Searching for %s.%s", controller_name, method_name)

  -- Use LSP workspace search instead of document symbols
  local params = {
    query = method_name,
    type = "method",
  }

  vim.lsp.buf_request(bufnr, "workspace/symbol", params, function(err, result)
    if err then
      log("Error: %s", vim.inspect(err))
      return
    end
    if not result then
      log "No results found"
      return
    end

    log("Found symbols: %s", vim.inspect(result))

    for _, symbol in ipairs(result) do
      -- log("Symbol: %s", vim.inspect(symbol))
      -- Check if the symbol belongs to the correct controller
      if  symbol.location.uri:find(controller_name) and symbol.name == method_name then
        local location = symbol.location
        local uri = location.uri or location.targetUri
        local range = location.range or location.targetRange
        log("Found method at uri: %s, range: %s", uri, vim.inspect(range))

        -- Open the file if not already open
        local file_path = vim.uri_to_fname(uri)
        vim.cmd("edit " .. vim.fn.fnameescape(file_path))

        -- Jump to the method
        local line = range.start.line
        local col = range.start.character
        log("Found method at line: %d, col: %d", line + 1, col)
        api.nvim_win_set_cursor(0, { line + 1, col })
        return
      end
    end
    log "Method not found"
  end)
end

local function custom_definition_handler()
  local bufnr = api.nvim_get_current_buf()
  local line = api.nvim_get_current_line()

  log("Current line: %s", line)

  -- Pattern specifically for your route format
  local pattern = '%[(%w+),%s*"([%w_%-]+)"%]'
  local controller_name, method_name = line:match(pattern)

  if controller_name and method_name then
    log("Matched: %s.%s", controller_name, method_name)
    find_controller_method(bufnr, controller_name, method_name)
    return true
  end

  log "No pattern matched"
  return false
end

local function on_attach(bufnr)
  log("Attaching custom handler to buffer: %d", bufnr)

  local original_handler = vim.lsp.handlers["textDocument/definition"]

  vim.lsp.handlers["textDocument/definition"] = function(err, result, ctx, config)
    log "Definition handler called"
    if custom_definition_handler() then return end
    return original_handler(err, result, ctx, config)
  end

  local opts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
end


return {
  on_attach = on_attach,
}
