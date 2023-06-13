<html xmlns="http://www.w3.org/1999/xhtml">
<head></head>
<body>

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
?>
<table width="70%" border="1">
    <tr>
        <th>ID Nota</th>
        <th>Ruta</th>
        <th>Título</th>
        <th>Fecha de Creación</th>
        <th>ID Usuario</th>
        <th>ID Categoría</th>
        <th>Contenido Ruta</th>
		<th>Contenido Blob</th>
    </tr>
    <?php
    $sql_nota = "SELECT IDNOTA, CONTENIDO, TITULO, FECHACREACION, IDUSUARIO, IDCATEGORIA, CONTENIDO_BLOB, TIPOARCHIVO FROM NOTA ORDER BY IDNOTA ASC";
    $resultado_nota = oci_parse($conn, $sql_nota);
    oci_execute($resultado_nota);
    while ($fila_nota = oci_fetch_assoc($resultado_nota)) {
        ?>

        <tr>
            <td><?php echo $fila_nota['IDNOTA']; ?></td>
            <td><?php echo $fila_nota['CONTENIDO']; ?></td>
            <td><?php echo $fila_nota['TITULO']; ?></td>
            <td><?php echo $fila_nota['FECHACREACION']; ?></td>
            <td><?php echo $fila_nota['IDUSUARIO']; ?></td>
            <td><?php echo $fila_nota['IDCATEGORIA']; ?></td>
            <td>
                <?php
                $rutaArchivo = $fila_nota['CONTENIDO'];
                $contenidoBlob = $fila_nota['CONTENIDO_BLOB']->load();
                $tipoArchivo = $fila_nota['TIPOARCHIVO'];

                if (file_exists($rutaArchivo)) {
                    // Determinar el tipo de archivo basado en la extensión
                    $tipoArchivoRuta = mime_content_type($rutaArchivo);

                    if (strpos($tipoArchivoRuta, 'image') === 0) {
                        // Mostrar imagen desde la ruta
                        echo '<img src="' . $rutaArchivo . '" alt="Imagen">';
                    } elseif (strpos($tipoArchivoRuta, 'text') === 0) {
                        // Mostrar archivo de texto desde la ruta
                        $contenidoTexto = file_get_contents($rutaArchivo);
                        echo '<pre>' . $contenidoTexto . '</pre>';
                    } elseif (strpos($tipoArchivoRuta, 'audio') === 0) {
                        // Mostrar audio desde la ruta
                        echo '<audio controls><source src="' . $rutaArchivo . '"></audio>';
                    } elseif (strpos($tipoArchivoRuta, 'video') === 0) {
                        // Mostrar video desde la ruta
                        echo '<video controls><source src="' . $rutaArchivo . '"></video>';
                    } else {
                        // Tipo de archivo desconocido
                        echo 'Tipo de archivo no compatible';
                    }
                } elseif (!empty($contenidoBlob)) {
                    echo 'El archivo no existe';
                }
                ?>
            </td>
			<td>
                <?php
                $contenidoBlob = $fila_nota['CONTENIDO_BLOB']->load();
                $tipoArchivo = $fila_nota['TIPOARCHIVO'];

                if (strpos($tipoArchivo, 'image') === 0) {
                    // Mostrar imagen
                    echo '<img src="data:' . $tipoArchivo . ';base64,' . base64_encode($contenidoBlob) . '" alt="Imagen">';
                } elseif (strpos($tipoArchivo, 'text') === 0) {
                    // Mostrar archivo de texto
                    echo '<pre>' . $contenidoBlob . '</pre>';
                } elseif (strpos($tipoArchivo, 'audio') === 0) {
                    // Mostrar audio
                    echo '<audio controls><source src="data:' . $tipoArchivo . ';base64,' . base64_encode($contenidoBlob) . '"></audio>';
                } elseif (strpos($tipoArchivo, 'video') === 0) {
                    // Mostrar video
                    echo '<video controls><source src="data:' . $tipoArchivo . ';base64,' . base64_encode($contenidoBlob) . '"></video>';
                } else {
                    // Tipo de archivo desconocido
                    echo 'Tipo de archivo no compatible';
                }
                ?>
            </td>



        </tr>

    <?php
    }
	if (!oci_error()) {
		echo "<center><a href='index.html'>Regresar</a></center>";
	} else {
		echo "<center>Error</center>";
	}
    ?>
	
</table>

</body>
</html>
