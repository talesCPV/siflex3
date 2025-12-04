<?php   

ini_set('display_errors','Off');
ini_set('error_reporting', E_ALL );
define('WP_DEBUG', false);
define('WP_DEBUG_DISPLAY', false);

function addItem($access,$obj){
  $menu = [];

  for($i = 0; $i< count($obj); $i++){  
//var_dump($obj[$i]);
    if (in_array($access,$obj[$i]->access )) {
      $item = new stdClass();
      $item->modulo = $obj[$i]->modulo;
      $item->icone = $obj[$i]->icone;
      $item->link = $obj[$i]->link;
      $item->janela = $obj[$i]->janela;
      $item->label = $obj[$i]->label;
      $item->width = $obj[$i]->width;
      if($obj[$i]->id != ''){
        $item->id = $obj[$i]->id;
      }
      if($obj[$i]->class != ''){
        $item->class = $obj[$i]->class;
      }
      if($obj[$i]->href != ''){
        $item->href = $obj[$i]->href;
      }  
//      property_exists($obj[$i], 'id') ? $item->id = $obj[$i]->id : 0;
//      property_exists($obj[$i], 'class') ? $item->class = $obj[$i]->class : 0;
      $item->access = crip(json_encode($obj[$i]->access));
      $item->itens = [];

      if(count($obj[$i]->itens) > 0){
          array_push($item->itens, addItem($access, $obj[$i]->itens));          
      } 
      array_push($menu, $item);
    }       
  }

  return $menu;
}

  $out = [];
  $qtd_lin = 0;
  
	if (IsSet($_POST["hash"])){
	  $path = "../config/menu.json";
	  $hash = $_POST["hash"];
    $access = -1;
    
    include_once "connect.php";
    include_once "crip.php";

    $query = "SELECT access FROM tb_user WHERE hash=\"$hash\";";

// echo $query;    

    $result = mysqli_query($conexao, $query);
		$qtd_lin = $result->num_rows;

		if($qtd_lin > 0){
      $row = $result->fetch_assoc();
//      var_dump($row);
      $access = $row["access"];

		}

	    $conexao->close();  

      if (file_exists($path)) {
          $fp = fopen($path, "r");
          $resp = "";
          while (!feof ($fp)) {
              $resp = $resp . fgets($fp,4096);
          }
          fclose($fp);
          $json = json_decode($resp);
          $out = addItem($access,$json->itens);
      }            

  }




//    var_dump($out);
	print json_encode($out);

?>