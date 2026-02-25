<?php   

  $out = [];

	if (IsSet($_POST["path"])){
	  $path = getcwd().$_POST["path"];   
//echo $path;    
      if (file_exists($path)) {
          $fp = fopen($path, "r");
          $resp = "";
          while (!feof ($fp)) {
              $resp = $resp . fgets($fp,4096);
          }
          fclose($fp);
//echo $resp;          
          $out = json_decode($resp);
      }else{

        $folder = $path;
//        echo strlen($folder);
        while($folder[-1] != '/' && strlen($folder)>0 ){
                $folder = substr($folder, 0, -1);
        }
//echo $folder;        
        mkdir($folder, 0755, true);

        $fp = fopen($path, "a");
        fwrite($fp,json_encode($out));
        fclose($fp);
      }

  }
        
//    var_dump($out);
	print json_encode($out);

?>