import { neon } from '@neondatabase/serverless';
import { verificarToken } from '../lib/auth.js';

export default async function handler(request, response) {
  const usuarioToken = verificarToken(request);
  if (!usuarioToken) {
    return response.status(401).json({ error: "No autorizado" });
  }

  try {
    const sql = neon(process.env.DATABASE_URL);

    const intercambios = await sql`
      SELECT
        i.id,
        i.usuario_propone_id,
        i.usuario_recibe_id,
        i.estado,
        i.tipo,
        i.punto_encuentro,
        i.fecha_creacion,
        prop.nombre AS nombre_propone,
        recibe.nombre AS nombre_recibe
      FROM intercambios i
      JOIN usuarios prop ON i.usuario_propone_id = prop.id
      JOIN usuarios recibe ON i.usuario_recibe_id = recibe.id
      WHERE i.usuario_propone_id = ${usuarioToken.id}
         OR i.usuario_recibe_id = ${usuarioToken.id}
      ORDER BY i.fecha_creacion DESC
    `;

    response.status(200).json({ total: intercambios.length, intercambios: intercambios });
  } catch (error) {
    response.status(500).json({ error: "No se pudieron obtener los intercambios" });
  }
}