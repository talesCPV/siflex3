<?php

    if (IsSet($_POST["dir"])){
        $path = getcwd().'/../'.$_POST["dir"];
//echo $path;        
        $files = scandir($path);
        $resp = json_encode($files);
        if(IsSet($_POST["ext"]) || IsSet($_POST["filename"])){
            $out = array();
            for( $i=0; $i<count($files); $i++){
                if(strlen($files[$i]) > 2){
                    $f = explode(".", $files[$i]);
                    if(strlen($files[$i] > 1)){
                        if(IsSet($_POST["ext"]) && IsSet($_POST["filename"])){
                            if(IsSet($_POST["filename"])==$f[0] && $_POST["ext"]==$f[1]){
                                array_push($out,$files[$i]);
                            }
                        }elseif(IsSet($_POST["filename"])){
                            if($_POST["filename"]==$f[0]){
                                array_push($out,$files[$i]);
                            }
                        }elseif(IsSet($_POST["ext"])){
                            if($_POST["ext"]==$f[1]){
                                array_push($out,$files[$i]);
                            }
                        }
                    }
    
                }
            }
            print(json_encode($out));
        }else{
            print($resp); 
        }

    }
?>