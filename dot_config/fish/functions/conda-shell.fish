# conda-shell — source the conda/mamba shell hook on demand (mirrors sh/rc.sh).
# micromamba/mamba/conda are on PATH via the personal opt prefix, but the shell
# function needed for `activate` is not wired by default. Call this when you
# actually need to activate an environment. Prefers micromamba, falling back to
# mamba then conda.
function conda-shell --description 'source the conda/mamba shell hook on demand'
    if type -q micromamba
        micromamba shell hook --shell fish | source
    else if type -q mamba
        mamba shell hook --shell fish | source
    else if type -q conda
        conda shell.fish hook | source
    end
end
