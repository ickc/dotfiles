-- brew.lua — Homebrew (≈ ml_brew); reads HOMEBREW_PREFIX from sh/env.sh.
-- family("pkgmgr") models the historic brew ↔ port isolation: loading another
-- package-manager module in the same family swaps this one out.
whatis("Homebrew on PATH/MANPATH/INFOPATH")
family("pkgmgr")

local function add_prefix(root)
    if isDir(pathJoin(root, "bin")) then prepend_path("PATH", pathJoin(root, "bin")) end
    if isDir(pathJoin(root, "share/man")) then prepend_path("MANPATH", pathJoin(root, "share/man")) end
    if isDir(pathJoin(root, "share/info")) then prepend_path("INFOPATH", pathJoin(root, "share/info")) end
end

local prefix = os.getenv("HOMEBREW_PREFIX")
if prefix ~= nil then
    if isDir(pathJoin(prefix, "sbin")) then prepend_path("PATH", pathJoin(prefix, "sbin")) end
    add_prefix(prefix)
    add_prefix(pathJoin(prefix, "opt/ruby"))
end
