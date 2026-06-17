-- cuda.lua — CUDA toolkit (≈ ml_cuda_toolkit) at the conventional /usr/local/cuda.
whatis("CUDA toolkit on PATH + LD_LIBRARY_PATH")

if isDir("/usr/local/cuda") then prepend_path("PATH", "/usr/local/cuda/bin") end
if isDir("/usr/local/cuda/lib64") then prepend_path("LD_LIBRARY_PATH", "/usr/local/cuda/lib64") end
