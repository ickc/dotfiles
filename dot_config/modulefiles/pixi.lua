-- pixi.lua — pixi global install location (≈ ml_pixi); reads PIXI_HOME from sh/env.sh.
whatis("pixi global on PATH/MANPATH/INFOPATH")

local function add_prefix(root)
    if isDir(pathJoin(root, "bin")) then prepend_path("PATH", pathJoin(root, "bin")) end
    if isDir(pathJoin(root, "share/man")) then prepend_path("MANPATH", pathJoin(root, "share/man")) end
    if isDir(pathJoin(root, "share/info")) then prepend_path("INFOPATH", pathJoin(root, "share/info")) end
end

local home = os.getenv("PIXI_HOME")
if home ~= nil then add_prefix(home) end
