LANDER_HOME="./tmp/lander"

Describe 'Lander'
    # https://github.com/shellspec/shellspec#beforeall-afterall---example-group-hook
    setup() {
        whoami
        pwd
        if [[ ! -e "~/.bashrc" ]]; then
            touch "~/.bashrc"
            echo "Created empty .bashrc."
        fi
        echo ""

        cp ~/.bashrc ~/.bashrc.bak
        
        LANDER_HOME="${LANDER_HOME}" \
        BASE_URL="${BASE_URL}" \
        SKIP_CA_UPDATE=1 \
        ./install.sh
    }
    
    cleanup() { 
        # :
        rm -rf ./tmp
        cp ~/.bashrc.bak ~/.bashrc
        rm ~/.bashrc.bak
    }


    BeforeAll 'setup'
    AfterAll 'cleanup'


    Describe 'Installation'
        file_exists() { test -e "${1}"; echo $?; }
    
        It "LANDER_HOME is set"
            When call echo "${LANDER_HOME}"
            The output should eq "./tmp/lander"
        End

        It "lander.sh exists"
            When call file_exists "${LANDER_HOME}/bin/lander.sh"
            The output should eq "0"
        End

        It "master.lz exists"
            When call file_exists "${LANDER_HOME}/res/master.lz"
            The output should eq "0"
        End
        
        It "initial.lz exists"
            When call file_exists "${LANDER_HOME}/res/initial.lz"
            The output should eq "0"
        End

        It "lz.bashrc exists"
            When call file_exists "${LANDER_HOME}/res/lz.bashrc"
            The output should eq "0"
        End

        It "bash_completion.sh exists"
            When call file_exists "${LANDER_HOME}/res/bash_completion.sh"
            The output should eq "0"
        End

    End

    Describe 'master.lz'
        

        

    End

End