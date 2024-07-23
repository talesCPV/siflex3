<?php   
	if (IsSet($_POST["path"]) && IsSet($_POST["file"])){
        $path = getcwd().$_POST["path"];
        $file = json_decode($_POST["file"]);

        $fp = fopen($path, "w");
        fwrite($fp,$file);
        fclose($fp); 

        print $file;
    }        
    
?>