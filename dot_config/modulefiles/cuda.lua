-- cuda.lua — CUDA toolkit (≈ ml_cuda_toolkit) at the conventional /usr/local/cuda.
whatis("CUDA toolkit on PATH + LD_LIBRARY_PATH")

local function add_prefix(root)
    if isDir(pathJoin(root, "bin")) then prepend_path("PATH", pathJoin(root, "bin")) end
    if isDir(pathJoin(root, "share/man")) then prepend_path("MANPATH", pathJoin(root, "share/man")) end
    if isDir(pathJoin(root, "share/info")) then prepend_path("INFOPATH", pathJoin(root, "share/info")) end
end

add_prefix("/usr/local/cuda")
if isDir("/usr/local/cuda/lib64") then prepend_path("LD_LIBRARY_PATH", "/usr/local/cuda/lib64") end
