set path = (/opt/local/bin ~/.local/bin $path)
set _SHELL=`command -v zsh`
if ($status == 0) then
    setenv SHELL "$_SHELL"
    exec "$SHELL" -l
endif
