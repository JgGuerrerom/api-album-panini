import { neon } from '@neondatabase/serverless';
import { verificarToken } from '../lib/auth.js';

export default async function handler(request, response) {
  const usuarioToken = verificarToken(request);
  if (!usuarioToken) {
    return response.status(401).json({ error: "No autorizado" });
  }

  try {
    const sql = neon(process.env.DATABASE_URL);
    const usuarios = await sql`
      SELECT id, nombre, email FROM usuarios
      WHERE id != ${usuarioToken.id}
      ORDER BY nombre
    `;
    response.status(200).json({ usuarios: usuarios });
  } catch (error) {
    response.status(500).json({ error: "No se pudieron obtener los usuarios" });
  }
}