-- cargo.lua — Cargo/Rust prefix (≈ ml_cg); reads CARGO_PREFIX from sh/env.sh.
-- Appended (not prepended) so the system toolchain wins on conflict.
whatis("Cargo (Rust) on PATH/MANPATH/INFOPATH")

local function add_prefix_append(root)
    if isDir(pathJoin(root, "bin")) then append_path("PATH", pathJoin(root, "bin")) end
    if isDir(pathJoin(root, "share/man")) then append_path("MANPATH", pathJoin(root, "share/man")) end
    if isDir(pathJoin(root, "share/info")) then append_path("INFOPATH", pathJoin(root, "share/info")) end
end

local prefix = os.getenv("CARGO_PREFIX")
if prefix ~= nil then add_prefix_append(prefix) end
