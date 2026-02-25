<?php   


        $out = [];
        if (IsSet($_POST["path"]) && IsSet($_POST["line"]) && IsSet($_POST["obj"])){
                $path = getcwd().$_POST["path"];
                $line = $_POST["line"];
                $obj = json_decode($_POST["obj"]);
//echo $path;                
                if (file_exists($path)) {
                        $fp = fopen($path, "r");
                        $resp = "";
                        while (!feof ($fp)) {
                                $resp = $resp . fgets($fp,4096);
                        }
                        fclose($fp);
                        $out = json_decode($resp);
echo json_encode($out);
                        $out[$line] = $obj;
echo json_encode($out);

                }else{
                    array_push($out,$obj);
                }

//                unset($out[$line]);

                $fp = fopen($path, "w");
                fwrite($fp,json_encode($out));
                fclose($fp);
        }
        
        //    var_dump($out);
        print json_encode($out);





?>