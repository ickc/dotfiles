-- jetbrains.lua — JetBrains Toolbox shell scripts (≈ ml_jetbrains), macOS only.
-- The isDir guard makes this a no-op off macOS.
whatis("JetBrains Toolbox CLI scripts on PATH (macOS)")

local home = os.getenv("HOME")
if home ~= nil then
    local dir = pathJoin(home, "Library/Application Support/JetBrains/Toolbox/scripts")
    if isDir(dir) then append_path("PATH", dir) end
end
