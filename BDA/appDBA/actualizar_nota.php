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

$contenido_tipo = $_FILES['nuevo_contenido']['type']; // Obtener el tipo de archivo

// Preparar la sentencia SQL de actualización
$sql = "UPDATE NOTA SET CONTENIDO = '$contenido_ruta', TITULO = '$titulo', CONTENIDO_BLOB = EMPTY_BLOB(), TIPOARCHIVO = '$contenido_tipo' 
        WHERE IDNOTA = $nota_id RETURNING CONTENIDO_BLOB INTO :CONTENIDO_BLOB";

$stmt = oci_parse($conn, $sql);

if (!$stmt) {
    $e = oci_error($conn);
    trigger_error(htmlentities($e['message'], ENT_QUOTES), E_USER_ERROR);
}

$contenido_tmp = $_FILES['nuevo_contenido']['tmp_name'];

$nota_string = file_get_contents($contenido_tmp);

$blob = oci_new_descriptor($conn, OCI_D_LOB);
oci_bind_by_name($stmt, ":CONTENIDO_BLOB", $blob, -1, OCI_B_BLOB);

oci_execute($stmt, OCI_NO_AUTO_COMMIT);
$blob->save($nota_string);
oci_commit($conn); //ejecutamos el commit

$blob->free();
oci_free_statement($stmt);

if (!oci_error()) {
    echo "<center>Actualización Exitosa<br>  <a href='index.html'>Regresar</a></center>";
} else {
    echo "<center>Error al Registrar</center>";
}

?>
