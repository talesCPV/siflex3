<?php   
	if (IsSet($_POST["user"]) && IsSet($_POST["field"]) && IsSet($_POST["file"])){
        
        $path = getcwd().'/../config/user/'.$_POST["user"].'/';
        $field = $_POST["field"];

        if (!file_exists($path)) {
            mkdir($path, 0777, true);
        }

        $path = $path.$_POST["file"];

        if (file_exists($path)) {

            $fp = fopen($path, "r");
            $txt = "";
            while (!feof ($fp)) {
                $txt = $txt . fgets($fp,4096);
            }
            fclose($fp); 
            $json = json_decode($txt); 

            if(property_exists($json, $field)){
                print json_encode($json->$field);
            }

        }else{
            $myfile = fopen($path, "w");
            fwrite($myfile, "{}");
            fclose($myfile);
        }
    }
?>