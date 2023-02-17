LANDER_HOME="./tmp/lander"


Describe 'Lander'
    Describe 'Installation'
    
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
        
        Specify "inSpecifyial.lz exists"
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

End