<?php

if (IsSet($_POST["cod"]) && IsSet($_POST["params"])){ 

    $cod = $_POST["cod"];
    $params = json_decode($_POST["params"],true); 

//    var_dump($params);

    switch($cod){
        case 1: // File Exist
            if(file_exists($params['filename'])){
                print "true";
            }else{
                print "false";
            }
            break;        
    }


}

?>