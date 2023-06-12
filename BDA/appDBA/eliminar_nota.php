<?php
$host = "localhost";
$port = "1521";
$sid = "XE";
$username = "SYSTEM";
$password = "Mi4353fe";


$conn = oci_connect($username, $password, "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$host)(PORT=$port))(CONNECT_DATA=(SID=$sid)))");

if (!$conn) {
    $e = oci_error();
    trigger_error(htmlentities($e['message'], ENT_QUOTES), E_USER_ERROR);
}


$nota_id = $_POST['nota_id_eliminar'];


$sql="DELETE FROM NOTA WHERE IDNOTA='$nota_id'";

$stmt = oci_parse($conn, $sql);

oci_execute($stmt);


if(!oci_error())
{
    echo "<center>Registro Exitoso<br>  <a href='index.html'>Ver Peliculas</a></center>";	
}
else
{
    echo "<center>Error al Registrar</center>";	
}

?>
