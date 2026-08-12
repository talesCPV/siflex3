<?php   

	if (IsSet($_POST["old_name"]) && IsSet($_POST["new_name"])){
	  $old_name = getcwd().$_POST["old_name"];   
	  $new_name = getcwd().$_POST["new_name"];   

echo $old_name;
echo $new_name;

      if (file_exists($old_name)) {
        rename($old_name, $new_name);
      }

  }
        
?>