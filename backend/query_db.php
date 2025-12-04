<?php

    if (IsSet($_POST["cod"]) && IsSet($_POST["params"]) && IsSet($_POST["access"]) && IsSet($_POST["hash"])){

        include_once "connect.php";
        include_once "crip.php";

        $cod = $_POST["cod"];
        $params = json_decode($_POST["params"],true);
        $rows = array();
        $hash = $_POST["hash"];
        $access = '0';

        if($_POST["access"] != '-1'){
            $l_access = json_decode(decrip($_POST["access"]),true);
            foreach($l_access as $val){
                $access = $access. ','.$val;
            }
        }

        include_once "sql.php";

        $query = $query_db[$_POST["cod"]];
        $query = str_replace('@access','"('.$access.')"',$query); // put mod access allow
        $query = str_replace('@hash','"'.$hash.'"',$query); // put user hash value

        $i = 0;
        foreach($params as $key => $val ){
            $y = 'y'.str_pad(strval($i), 2, "0", STR_PAD_LEFT);
            $x = 'x'.str_pad(strval($i), 2, "0", STR_PAD_LEFT);

            $query = str_replace($y, $key,$query); // fields
            $query = str_replace($x, $val,$query); // values
            $i++;
        }

//    echo $query; 

            $result = mysqli_query($conexao, $query);
            if(is_object($result)){
                if($result->num_rows > 0){			
                    while($r = mysqli_fetch_assoc($result)) {
                        $rows[] = $r;
                    }
                }        
            }

	    $conexao->close();        

        print json_encode($rows);
    }

?>