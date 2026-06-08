-- core.lua — base prefixes (≈ the old ml_clean): opt/system, opt, local.
-- Reads __OPT_ROOT / __LOCAL_ROOT from sh/env.sh. Prepend order
-- (system → opt → local) leaves local/bin frontmost, matching the previous
-- precedence. Always part of the default set and of `__CLEAN=1`.
whatis("Base PATH/MANPATH/INFOPATH for the personal software prefixes")

local function add_prefix(root)
    if root == nil then return end
    if isDir(pathJoin(root, "bin")) then prepend_path("PATH", pathJoin(root, "bin")) end
    if isDir(pathJoin(root, "share/man")) then prepend_path("MANPATH", pathJoin(root, "share/man")) end
    if isDir(pathJoin(root, "share/info")) then prepend_path("INFOPATH", pathJoin(root, "share/info")) end
end

local opt = os.getenv("__OPT_ROOT")
local lroot = os.getenv("__LOCAL_ROOT")
if opt ~= nil then add_prefix(pathJoin(opt, "system")) end
add_prefix(opt)
add_prefix(lroot)
