export LANDER_HOME="$(pwd -P)/tmp/lander"

Context 'Lander'

    # =========================================================================
    # 
    Context '[Installation]'
    
        Specify "LANDER_HOME is set"
            The variable LANDER_HOME should equal "${LANDER_HOME}"
        End

        Specify "lander.sh exists"
            The path "${LANDER_HOME}/bin/lander.sh" should exist
            The path "${LANDER_HOME}/bin/lander.sh" should be file
        End

        Specify "master.lz exists"
            The path "${LANDER_HOME}/res/master.lz" should exist
            The path "${LANDER_HOME}/res/master.lz" should be file
        End
        
        Specify "initial.lz exists"
            The path "${LANDER_HOME}/res/initial.lz" should exist
            The path "${LANDER_HOME}/res/initial.lz" should be file
        End

        Specify "lz.bashrc exists"
            The path "${LANDER_HOME}/res/lz.bashrc" should exist
            The path "${LANDER_HOME}/res/lz.bashrc" should be file
        End

        Specify "bash_completion.sh exists"
            The path "${LANDER_HOME}/res/bash_completion.sh" should exist
            The path "${LANDER_HOME}/res/bash_completion.sh" should be file
        End

    End
    #
    # -------------------------------------------------------------------------

    # =========================================================================
    # 
    Context '[Create New Zone]'
        run_lz_new() {
            local testProjectPath="./tmp/codespace/testProject"
            mkdir -p "${testProjectPath}"
            cd "${testProjectPath}"
            lz new
        }
        cleanup() {
            cd "${LANDER_HOME}/../.."
            rm -rf "./tmp/codespace/"
            rm -rf "${LANDER_HOME}/zones/testProject"
        }
        BeforeAll 'run_lz_new'
        AfterAll 'cleanup'

        Specify "zone file exists in project"
            The path "${LANDER_HOME}/../codespace/testProject/.lz" should exist
            The path "${LANDER_HOME}/../codespace/testProject/.lz" should be file
        End

        Specify "zone file is symlinked in LANDER_HOME/zones directory"
            The path "${LANDER_HOME}/zones/testProject" should exist
            The path "${LANDER_HOME}/zones/testProject" should be symlink
        End

    End
    #
    # -------------------------------------------------------------------------

End