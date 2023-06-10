document.addEventListener('DOMContentLoaded', function() {
  document.getElementById('last-modified').innerHTML = document.lastModified;
});

function mostrarPersona(imagen, texto) {
  document.getElementById('ventanaImagen').src = imagen;
  document.getElementById('ventanaTexto').textContent = texto;
  $('#ventanaPersona').modal('show');
}