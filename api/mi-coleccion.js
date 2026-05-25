import { neon } from '@neondatabase/serverless';
import { verificarToken } from '../lib/auth.js';

export default async function handler(request, response) {
  const usuarioToken = verificarToken(request);

  if (!usuarioToken) {
    return response.status(401).json({ error: "No autorizado" });
  }

  try {
    const iso3 = request.query.iso3;

    if (!iso3) {
      return response.status(400).json({ error: "Falta el parametro iso3" });
    }

    const sql = neon(process.env.DATABASE_URL);

    const laminas = await sql`
      SELECT
        lam.id,
        lam.nombre_sticker,
        lam.posicion,
        lam.foto_url,
        lam.es_especial,
        COALESCE(col.cantidad, 0) AS cantidad
      FROM laminas_panini_2026 lam
      LEFT JOIN coleccion_usuario col
        ON lam.id = col.lamina_id AND col.usuario_id = ${usuarioToken.id}
      WHERE lam.iso3 = ${iso3}
      ORDER BY lam.id
    `;

    response.status(200).json({ iso3: iso3, total: laminas.length, laminas: laminas });
  } catch (error) {
    response.status(500).json({ error: "No se pudo obtener la coleccion" });
  }
}