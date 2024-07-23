<?php

    if (IsSet($_POST["dir"])){
        $path = getcwd().'/../'.$_POST["dir"];
        $files = scandir($path);
        $resp = json_encode($files);
        print($resp); 
    }
?>