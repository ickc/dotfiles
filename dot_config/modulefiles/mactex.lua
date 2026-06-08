-- mactex.lua — MacTeX texbin (≈ ml_mactex), macOS only.
-- The isDir guard makes this a no-op off macOS.
whatis("MacTeX texbin on PATH (macOS)")

if isDir("/Library/TeX/Distributions/Programs/texbin") then
    prepend_path("PATH", "/Library/TeX/Distributions/Programs/texbin")
end
