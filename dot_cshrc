setenv PATH ~/.local/bin:$PATH
if ( $?prompt ) then
    if ( "$0" == "-tcsh" || "$0" == "-csh" ) then
        set _SHELL=`which zsh`
        if ( $? == 0 ) then
            setenv SHELL "$_SHELL"
            exec "$SHELL" -l
        endif
    endif
endif
