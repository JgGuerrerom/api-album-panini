export default function handler(request, response) {
  response.status(200).json({
    mensaje: "La API del album Panini funciona correctamente",
    fecha: new Date().toISOString()
  });
}