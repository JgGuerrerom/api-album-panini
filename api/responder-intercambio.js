import { neon } from '@neondatabase/serverless';
import { verificarToken } from '../lib/auth.js';

export default async function handler(request, response) {
  if (request.method !== 'POST') {
    return response.status(405).json({ error: "Metodo no permitido" });
  }

  const usuarioToken = verificarToken(request);
  if (!usuarioToken) {
    return response.status(401).json({ error: "No autorizado" });
  }

  try {
    const { intercambio_id, respuesta } = request.body;

    if (!intercambio_id || !respuesta) {
      return response.status(400).json({ error: "Faltan datos" });
    }

    if (respuesta !== 'aceptado' && respuesta !== 'rechazado') {
      return response.status(400).json({ error: "La respuesta debe ser aceptado o rechazado" });
    }

    const sql = neon(process.env.DATABASE_URL);

    const existe = await sql`SELECT * FROM intercambios WHERE id = ${intercambio_id}`;
    if (existe.length === 0) {
      return response.status(404).json({ error: "Ese intercambio no existe" });
    }

    const intercambio = existe[0];

    if (intercambio.usuario_recibe_id !== usuarioToken.id) {
      return response.status(403).json({ error: "Solo quien recibe la propuesta puede responderla" });
    }

    if (intercambio.estado !== 'propuesto') {
      return response.status(409).json({ error: "Este intercambio ya fue respondido" });
    }

    const actualizado = await sql`
      UPDATE intercambios
      SET estado = ${respuesta}, fecha_actualizacion = NOW()
      WHERE id = ${intercambio_id}
      RETURNING id, estado
    `;

    response.status(200).json({
      mensaje: "Intercambio " + respuesta,
      intercambio: actualizado[0]
    });
  } catch (error) {
    response.status(500).json({ error: "No se pudo responder el intercambio" });
  }
}