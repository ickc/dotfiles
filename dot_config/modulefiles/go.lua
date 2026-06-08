-- go.lua — Go user binaries (GOBIN) on PATH. GOBIN is exported by sh/env.sh.
whatis("Go user bin (GOBIN) on PATH")

local gobin = os.getenv("GOBIN")
if gobin ~= nil and isDir(gobin) then prepend_path("PATH", gobin) end
