<?php   

        $file = [];
        if (IsSet($_POST["path"]) && IsSet($_POST["line"])){
                $path = getcwd().$_POST["path"];
                $line = $_POST["line"];
//echo $path;
                if (file_exists($path)) {
                        $fp = fopen($path, "r");
                        $resp = "";
                        while (!feof ($fp)) {
                                $resp = $resp . fgets($fp,4096);
                        }
                        fclose($fp);
                        $file = json_decode($resp);

                }

                $json = "[";
                for($i=0; $i<count($file); $i++){
                        if($i != $line){
                                $json .= strlen($json)>2 ? ',' : '';        
                                $json .= json_encode($file[$i]) ;
                        }
                }
                $json = $json.']';

                $fp = fopen($path, "w");
                fwrite($fp,$json);
                fclose($fp);
        }
        print json_encode($json);
        
?>