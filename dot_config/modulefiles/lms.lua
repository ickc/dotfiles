-- lms.lua — LM Studio CLI (≈ ml_lms), installed under ~/.lmstudio.
whatis("LM Studio CLI on PATH")

local home = os.getenv("HOME")
if isDir(pathJoin(home, ".lmstudio")) then
    prepend_path("PATH", pathJoin(home, ".lmstudio/bin"))
end
