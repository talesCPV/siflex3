<?php   


        $out = [];
        if (IsSet($_POST["path"]) && IsSet($_POST["line"])){
                $path = getcwd().$_POST["path"];
                $line = $_POST["line"];
//echo $path;
//echo $line;
                if (file_exists($path)) {
                        $fp = fopen($path, "r");
                        $resp = "";
                        while (!feof ($fp)) {
                                $resp = $resp . fgets($fp,4096);
                        }
                        fclose($fp);
                        $out = json_decode($resp);

                }

                unset($out[$line]);
/*                
                //var_dump($out);
                $json = "[";
                for($i=0; $i<count($out); $i++){
                        $json .= json_encode($out[$i]);
                        $json .= $i<count($out)-1 ? ',' : '';
//                        echo $json;
                }
                $json = $json.']';


                $out = json_decode($json);
var_dump($out);

//        echo json_encode($out);

//echo json_encode((array)$out);
*/

                $fp = fopen($path, "w");
                fwrite($fp,json_encode($out));
                fclose($fp);

        }
        
        //    var_dump($out);
        print json_encode($out);





?>