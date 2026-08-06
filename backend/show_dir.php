<?php

    if (IsSet($_POST["dir"])){
        $path = getcwd().'/../'.$_POST["dir"];
//echo $path;
        if (is_dir($path)) {
            $files = array_diff(scandir($path), array('.', '..'));

            usort($files, function($a, $b) use ($path) {
                return filemtime($path . '/' . $b) <=> filemtime($path . '/' . $a);            
                // Para do MAIS ANTIGO para o MAIS NOVO (Crescente), mude para:
                // return filemtime($dir . '/' . $a) <=> filemtime($dir . '/' . $b);
            });
    
//var_dump($files);
//exit;
            if(IsSet($_POST["ext"]) || IsSet($_POST["filename"])){
                $out = array();
                for( $i=0; $i<count($files); $i++){
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
                print(json_encode($out));
            }else{
                print(json_encode($files)); 
            }
        }else{
            print("{}");
        }
    }
?>