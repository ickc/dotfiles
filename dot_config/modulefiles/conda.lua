-- conda.lua — put the conda ecosystem on PATH and set MAMBA_EXE. micromamba is a
-- single static binary under $__OPT_ROOT/bin (already on PATH); Miniforge/mamba
-- (opt-in) adds its condabin. Environment activation is intentionally NOT wired
-- here, so load/unload stay clean. If you need `micromamba activate`, use the
-- `conda-shell` helper (sh/rc.sh) to source the hook on demand. Reads
-- MAMBA_ROOT_PREFIX / __OPT_ROOT from sh/env.sh.
whatis("micromamba/mamba on PATH; MAMBA_EXE + CONDA_ENVS_PATH for env discovery")

local opt = os.getenv("__OPT_ROOT")
local root = os.getenv("MAMBA_ROOT_PREFIX")

-- Miniforge/mamba (opt-in): expose its condabin on PATH when present.
if root ~= nil and isDir(pathJoin(root, "condabin")) then
    prepend_path("PATH", pathJoin(root, "condabin"))
end

-- MAMBA_EXE: prefer the micromamba static binary; fall back to a Miniforge mamba.
if opt ~= nil and isFile(pathJoin(opt, "bin/micromamba")) then
    setenv("MAMBA_EXE", pathJoin(opt, "bin/micromamba"))
elseif root ~= nil and isFile(pathJoin(root, "condabin/mamba")) then
    setenv("MAMBA_EXE", pathJoin(root, "condabin/mamba"))
end

-- env search paths (prepend so __OPT_ROOT ends up ahead of the XDG location)
local xdg = os.getenv("XDG_DATA_HOME")
if xdg ~= nil and isDir(pathJoin(xdg, "conda/envs")) then
    prepend_path("CONDA_ENVS_PATH", pathJoin(xdg, "conda/envs"))
end
if opt ~= nil and isDir(opt) then
    prepend_path("CONDA_ENVS_PATH", opt)
end
