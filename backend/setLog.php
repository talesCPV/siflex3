<?php   

        function getEmail(){
//echo 1;                
                include_once "connect.php";

                $hash = $_POST["hash"];
                $rows = array();
                $query = 'SELECT email FROM tb_usuario WHERE hash COLLATE utf8_general_ci = "'.$hash.'" COLLATE utf8_general_ci LIMIT 1;';
                
                $result = mysqli_query($conexao, $query);
                if(is_object($result)){
                        if($result->num_rows > 0){			
                                while($r = mysqli_fetch_assoc($result)) {
                                        $rows[] = $r;
                                }
                        }        
                }
                $conexao->close(); 
                
                $out = '';
                foreach($result as $row) {
                        return$row['email'];
                }
        }


        if (IsSet($_POST["line"])){

                $email = getEmail();
                
                $path = getcwd().'/../config/log/'.date("m_Y").'.txt';
//                $line =  date("d/m/Y H:i", strtotime('-4 hours')).' '.$email.' : '.mb_convert_encoding($_POST["line"],'UTF-8'); 
                $line =  date("d/m/Y H:i").' '.$email.' : '.mb_convert_encoding($_POST["line"],'UTF-8'); 
                
                $fp = fopen($path, "a+");
                fwrite($fp, utf8_encode($line."\n")); 
                fclose($fp);    
        }

?>