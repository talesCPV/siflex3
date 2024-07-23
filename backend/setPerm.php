<?php   
	if (IsSet($_POST["hash"])){
        $path = getcwd().'/../config/menu.json';
        $hash = $_POST["hash"];
        $json = $_POST["json"];
        $access = -1;

        include "connect.php";        

        $query = "SELECT access FROM tb_usuario WHERE hash=\"$hash\";";

        $result = mysqli_query($conexao, $query);
        $qtd_lin = $result->num_rows;
        if($qtd_lin > 0){
            $row = $result->fetch_assoc();
            $access = $row["access"];
        }
	    $conexao->close();  

        if($access == '0'){ // only root!
            $menu = json_decode($json, true);
            var_dump($menu['menu']);
            return file_put_contents($path, json_encode($menu));
        }

    }
 
?>