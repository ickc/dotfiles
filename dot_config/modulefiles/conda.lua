-- conda.lua — put conda/mamba (condabin) on PATH only (≈ ml_conda, condabin-only).
-- Environment activation is intentionally NOT wired here, so load/unload stay
-- clean. If you need `conda activate`, use the `conda-shell` helper (sh/rc.sh)
-- to source the hook on demand. Reads MAMBA_ROOT_PREFIX from sh/env.sh.
whatis("conda/mamba condabin on PATH; CONDA_ENVS_PATH for env discovery")

local root = os.getenv("MAMBA_ROOT_PREFIX")
if root ~= nil and isDir(pathJoin(root, "condabin")) then
    prepend_path("PATH", pathJoin(root, "condabin"))
    setenv("MAMBA_EXE", pathJoin(root, "condabin/mamba"))
end

-- env search paths (prepend so __OPT_ROOT ends up ahead of the XDG location)
local xdg = os.getenv("XDG_DATA_HOME")
if xdg ~= nil and isDir(pathJoin(xdg, "conda/envs")) then
    prepend_path("CONDA_ENVS_PATH", pathJoin(xdg, "conda/envs"))
end
local opt = os.getenv("__OPT_ROOT")
if opt ~= nil and isDir(opt) then
    prepend_path("CONDA_ENVS_PATH", opt)
end
