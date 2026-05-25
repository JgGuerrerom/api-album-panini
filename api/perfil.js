import { neon } from '@neondatabase/serverless';
import { verificarToken } from '../lib/auth.js';

export default async function handler(request, response) {
  const usuarioToken = verificarToken(request);

  if (!usuarioToken) {
    return response.status(401).json({ error: "No autorizado. Token invalido o ausente" });
  }

  try {
    const sql = neon(process.env.DATABASE_URL);
    const usuarios = await sql`
      SELECT id, nombre, email, iso3_pais, fecha_registro
      FROM usuarios WHERE id = ${usuarioToken.id}
    `;

    if (usuarios.length === 0) {
      return response.status(404).json({ error: "Usuario no encontrado" });
    }

    response.status(200).json({ usuario: usuarios[0] });
  } catch (error) {
    response.status(500).json({ error: "No se pudo obtener el perfil" });
  }
}