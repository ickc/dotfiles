-- agy.lua — Antigravity CLI (≈ ml_agy), installed under ~/.antigravity/antigravity.
whatis("Antigravity CLI on PATH/MANPATH/INFOPATH")

local function add_prefix(root)
    if isDir(pathJoin(root, "bin")) then prepend_path("PATH", pathJoin(root, "bin")) end
    if isDir(pathJoin(root, "share/man")) then prepend_path("MANPATH", pathJoin(root, "share/man")) end
    if isDir(pathJoin(root, "share/info")) then prepend_path("INFOPATH", pathJoin(root, "share/info")) end
end

local home = os.getenv("HOME")
if home ~= nil then add_prefix(pathJoin(home, ".antigravity/antigravity")) end
