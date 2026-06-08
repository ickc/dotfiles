-- ghcup.lua — GHCup / cabal Haskell toolchain (≈ ml_ghcup). See `cat ~/.ghcup/env`.
-- Appended so the system toolchain wins on conflict.
whatis("GHCup / cabal (Haskell) on PATH")

local function add_prefix_append(root)
    if isDir(pathJoin(root, "bin")) then append_path("PATH", pathJoin(root, "bin")) end
    if isDir(pathJoin(root, "share/man")) then append_path("MANPATH", pathJoin(root, "share/man")) end
    if isDir(pathJoin(root, "share/info")) then append_path("INFOPATH", pathJoin(root, "share/info")) end
end

local home = os.getenv("HOME")
if home ~= nil then
    add_prefix_append(pathJoin(home, ".cabal"))
    add_prefix_append(pathJoin(home, ".ghcup"))
end
