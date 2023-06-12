<?php
$host = "localhost";
$port = "1521";
$sid = "XE";
$username = "SYSTEM";
$password = "Mi4353fe";

// Establecer conexión con la base de datos Oracle
$conn = oci_connect($username, $password, "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$host)(PORT=$port))(CONNECT_DATA=(SID=$sid)))");

if (!$conn) {
    $e = oci_error();
    trigger_error(htmlentities($e['message'], ENT_QUOTES), E_USER_ERROR);
}

// Obtener los valores enviados desde el formulario
$titulo = $_POST['nuevo_titulo'];
$contenido_ruta = $_POST['nuevo_contenido'];
$nota_id = $_POST['nota_id'];

//$nota_nombre=$_FILES['contenido']['name'];
//$nota_tipo = $_FILES['contenido']['type'];




// Preparar la sentencia SQL de inserción
$sql = "UPDATE NOTA SET CONTENIDO = '$contenido_ruta', TITULO = '$titulo' 
        WHERE IDNOTA =  $nota_id";

$stmt = oci_parse($conn, $sql);
oci_execute($stmt);

$contenido_tmp = $_FILES['nuevo_contenido']['tmp_name'];

$nota_string=file_get_contents($contenido_tmp);

$sql=" UPDATE NOTA SET CONTENIDO = '$contenido_ruta', TITULO = '$titulo', CONTENIDO_BLOB = EMPTY_BLOB() 
        WHERE IDNOTA = $nota_id RETURNING CONTENIDO_BLOB into :CONTENIDO_BLOB";

$stmt = oci_parse($conn, $sql);

$blob=oci_new_descriptor($conn, OCI_D_LOB);
oci_bind_by_name($stmt, ":CONTENIDO_BLOB", $blob, -1, OCI_B_BLOB);

oci_execute($stmt, OCI_NO_AUTO_COMMIT);
$blob->save($nota_string); 
oci_commit($conn); //ejecutamos el commit

$blob->free();
oci_free_statement($stmt);
if(!oci_error())
{
    echo "<center>Registro Exitoso<br>  <a href='index.html'>Ver Peliculas</a></center>";	
}
else
{
    echo "<center>Error al Registrar</center>";	
}

// Ejecutar la sentencia SQL
//oci_execute($stmt, OCI_DEFAULT);

//oci_close($conn);
//C:\Users\velaz\Downloads\simple_todo.txt
?>
