<html xmlns="http://www.w3.org/1999/xhtml">
<head></head>
<body>


<table width="70%" border="1" >  
	<tr>
        <th id="target">Id nota</th>
        <th id="target">titulo</th>
        <th id="target">fecha de creacion</th>
        <th id="target">Id usuario</th>
        <th id="target" >Id categoria</th>
        <th id="target">Contenido</th>
		<th id="target">Contenido blob</th>
	</tr>
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

	$sql="SELECT IDNOTA, TITULO, FECHACREACION, IDUSUARIO, IDCATEGORIA, CONTENIDO, 
	CONTENIDO_BLOB FROM NOTA ORDER BY IDNOTA ASC";
    $stmt = oci_parse($conn, $sql);
    oci_execute($stmt);
    while( $fila_nota = oci_fetch_assoc($stmt))  // OCI_BOTH OCI_NUM  OCI_ASSOC OCI_RETURN_NULLS   OCI_ASSOC+OCI_RETURN_NULLS  OCI_RETURN_LOBS
	{
?>

	<tr  id="target">
	
    	<td><?php echo $fila_nota['IDNOTA']; ?></td>	
        <td><?php echo $fila_nota["TITULO"]; ?></td>
        <td><?php echo $fila_nota["FECHACREACION"]; ?></td>
        <td><?php echo $fila_nota["IDUSUARIO"]; ?></td>
        <td><?php echo $fila_nota["IDCATEGORIA"]; ?></td>
		<td><?php echo $fila_nota["CONTENIDO"]; ?></td>
        <!--<td><?php echo $fila_nota["CONTENIDO_BLOB"]; ?></td>-->
		

		
		<td WIDTH="401" 
	    HEIGHT="249" id="targeta"> 
		
		<?php	
		$archivos = $fila_nota["CONTENIDO"]; 
		$trozos = explode(".", $archivos); 
		$extension = end($trozos); 
	
		if( $extension == "avi" || $extension == "mp4"  ) {
		?>
		<video width="401" height="249" controls>
			<source src="notas/<?php echo $fila_nota["CONTENIDO"];?>"  type="video/mp4" /> 
		</video>
			
		<?php
			} 
			if( $extension == "mp3")
				{ ?>
				<audio controls>
					<source src="notas/<?php echo $fila_nota["CONTENIDO"];?>" type="audio/mpeg" />
				</audio>
					 
		<?php	
		}
		?>
		<div style="text-align:justify">
			<?php	
				if( $extension == "txt")
				{
					 $ar=fopen("notas/$archivos","r") or
				die("No se pudo abrir el archivo");
			  while (!feof($ar))
			  {
				$linea=fgets($ar);
				$lineasalto=nl2br($linea);
				echo $lineasalto;
			  }
			  fclose($ar);
}
			?>
			<?php	
		if( $extension == "jpg" || $extension == "png" )
				{
		?>
		<div align="center">
			<img src="notas/<?php echo $fila_nota["CONTENIDO"];?>" alt="Imagen no disponible"> </div>
			<?php	
		}
		?>
		</div> 
		
	
		<td WIDTH="401" 
	    HEIGHT="249" id="targeta">
		
		<?php 
		
		$archivo = $fila_nota["CONTENIDO_BLOB"];		
		$tipoextension = substr($tipoarchivo, 0, 5); 	
		
		if (strtoupper($tipoextension) == "IMAGE")
	    {
			echo '<center><img width="401" height="249" src="data:'.trim($tipoarchivo).';base64,'.base64_encode($archivo->load()) .'" /></center>'; 
		}
		else if (strtoupper($tipoextension) == "VIDEO")
	    {			
			echo '<div content="Content_Type:'.trim($tipoarchivo).'"><center>';
			echo '<video width="401" height="249" controls="controls">';
			echo '<source src="data:'.trim($tipoarchivo).';base64,'.base64_encode($archivo->load()).'" type="'.trim($tipoarchivo).'"/>';
			echo '</video>';
			echo '</center></div>';
		} 
		else if (strtoupper($tipoextension) == "AUDIO")
	    {			
			echo '<div content="Content_Type:'.trim($tipoarchivo).'"><center>';
			echo '<audio width="401" height="85" controls="controls">';
			echo '<source src="data:'.trim($tipoarchivo).';base64,'.base64_encode($archivo->load()).'" type="'.trim($tipoarchivo).'"/>';
			echo '</audio>';
			echo '</center></div>';
		} 
		
		else if (strtoupper($tipoextension) == "TEXT/")
	    {			
			echo '<div content="Content_Type:'.trim($tipoarchivo).'"><center>';
			echo $archivo->load();
			echo '</center></div>';
		} 		
				
		?>
		

		
		</td>
		
		
    </tr>	
<?php
	}
?>
</table>
</body>
</html>

