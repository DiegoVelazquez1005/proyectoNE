<?php
// Conexión a la base de datos MySQL
$servername = "localhost";
$username = "root";
$password = "Mi4353fe";
$dbname = "clientes";

// Crear conexión
$conn = new mysqli($servername, $username, $password, $dbname);

// Verificar la conexión
if ($conn->connect_error) {
    die("Error al conectar con la base de datos: " . $conn->connect_error);
}

// Obtener los datos del formulario
$nombre = $_POST["nombre"];
$correo = $_POST["correo"];
$comentario = $_POST["comentario"];

// Preparar la consulta
$sql = "INSERT INTO client (nombre, correo, comentario) VALUES (?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sss", $nombre, $correo, $comentario);

// Ejecutar la consulta preparada
if ($stmt->execute()) {
    header("Location: index.html");

} else {
    echo "Error al ingresar los datos: " . $stmt->error;
}

// Cerrar la conexión
$stmt->close();
$conn->close();
?>
