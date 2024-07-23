<?php   
	if (IsSet($_POST["user"]) && IsSet($_POST["field"]) && IsSet($_POST["file"]) && IsSet($_POST["value"])){

        $path = getcwd().'/../config/user/'.$_POST["user"].'/'.$_POST["file"];
        $field = $_POST["field"];
        $value = $_POST["value"];      
        if (file_exists($path)) {
            $fp = fopen($path, "r");
            $txt = "";
            while (!feof ($fp)) {
                $txt = $txt . fgets($fp,4096);
            }
            fclose($fp); 
            $json = json_decode($txt); 
            $json->$field = $value;                                        
            return file_put_contents($path, json_encode($json));
        }        
    }

?>