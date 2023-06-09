<link rel="stylesheet" href="estilos.css">
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
$titulo = $_POST['titulo'];
$usuario_id = $_POST['usuario_id'];
$fecha_creacion = $_POST['fecha_creacion'];
$categoria_id = $_POST['categoria_id'];
$contenido_ruta = $_POST['contenido'];

$contenido_tipo = $_FILES['contenido']['type']; // Obtener el tipo de archivo

$contenido_tmp = $_FILES['contenido']['tmp_name'];

$nota_string = file_get_contents($contenido_tmp);

// Preparar la sentencia SQL de inserción
$sql = "INSERT INTO NOTA (CONTENIDO, CONTENIDO_BLOB, TITULO, FECHACREACION, IDUSUARIO, IDCATEGORIA, TIPOARCHIVO) 
        VALUES ('$contenido_ruta', empty_blob(), '$titulo', '$fecha_creacion', '$usuario_id', '$categoria_id', '$contenido_tipo') 
        RETURNING CONTENIDO_BLOB INTO :CONTENIDO_BLOB";

$stmt = oci_parse($conn, $sql);

if (!$stmt) {
    $e = oci_error($conn);
    trigger_error(htmlentities($e['message'], ENT_QUOTES), E_USER_ERROR);
}

$blob = oci_new_descriptor($conn, OCI_D_LOB);

oci_bind_by_name($stmt, ":CONTENIDO_BLOB", $blob, -1, OCI_B_BLOB);

oci_execute($stmt, OCI_NO_AUTO_COMMIT);
$blob->save($nota_string); //guardamos el archivo como binario

oci_commit($conn); //ejecutamos el commit
$blob->free();
oci_free_statement($stmt);

if (!oci_error()) {
    echo "<center>Registro Exitoso<br>  <a href='index.html'>Regresar</a></center>";
} else {
    echo "<center>Error</center>";
}

?>
