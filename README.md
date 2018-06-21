# linuxScripts
Linux Scripts for common admin tasks .... make bash work for you 
add all these scripts to you bin directory $HOME/bin .

## joins ##   
_joins.bash_


    ```
    > cat file1
      blue
      white
      dark
      yellow
      magenta
    
    
    > cat file2
      brown
      white
      dark
      yellow
      cyan
    
    
    > joins left file1 file2
      [INFO] - Left Join
      blue
      magenta
    
    
    > joins right  file1 file2
        [INFO] - Right Join
        brown
        cyan

     
     > joins outer  file1 file2
        [INFO] - Outer Join
        blue
        magenta
        brown
        cyan
    
    
    > joins join  file1 file2
        [INFO] - Simply prints the matchess.
        white
        dark
        yellow

    ```
