<?php
/*
    include_once "crip.php";
    $usuario = decrip('VYVYqVy3)3/=psVeZ+VW]X,-tVjl3fLa,`48`VuYhVnzVv/0');//flexib52_tales   
    $senha= decrip('#M#)B#J+C?8@AD#4*K#%,(0*E#9;15G0:/(#c#F)7#?z#GK2'); // Xspider0
    $servidor = decrip('k0kn-k5F)()f,/kyo*klqmC-0k#(LzAuAtHA_k1n!k*J%2/('); // 108.179.253.230
    $banco = decrip('5Ynq0n83)3/=/2n!r,not/,/3n)+3"L;ww!8]n4q%n/z@5/0'); // flexib52_db_estoque
    $conexao = new mysqli($servidor, $usuario, $senha, $banco);
*/
    $conexao = new mysqli("108.179.253.230", "flexib52_tales", "Xspider0", "flexib52_db_estoque");
    if (!$conexao){
        die ("Erro de conexão com localhost, o seguinte erro ocorreu -> ".mysql_error());
    }    

?>