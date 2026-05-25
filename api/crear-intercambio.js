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
    const { usuario_recibe_id, tipo, punto_encuentro, laminas } = request.body;

    if (!usuario_recibe_id || !tipo || !laminas || laminas.length === 0) {
      return response.status(400).json({ error: "Faltan datos del intercambio" });
    }

    if (usuario_recibe_id === usuarioToken.id) {
      return response.status(400).json({ error: "No puedes intercambiar contigo mismo" });
    }

    const sql = neon(process.env.DATABASE_URL);

    const otroUsuario = await sql`SELECT id FROM usuarios WHERE id = ${usuario_recibe_id}`;
    if (otroUsuario.length === 0) {
      return response.status(404).json({ error: "El otro usuario no existe" });
    }

    const cabecera = await sql`
      INSERT INTO intercambios (usuario_propone_id, usuario_recibe_id, tipo, punto_encuentro)
      VALUES (${usuarioToken.id}, ${usuario_recibe_id}, ${tipo}, ${punto_encuentro || null})
      RETURNING id
    `;
    const intercambioId = cabecera[0].id;

    for (const item of laminas) {
      await sql`
        INSERT INTO intercambio_detalle (intercambio_id, lamina_id, direccion)
        VALUES (${intercambioId}, ${item.lamina_id}, ${item.direccion})
      `;
    }

    response.status(201).json({
      mensaje: "Propuesta de intercambio creada",
      intercambio_id: intercambioId
    });
  } catch (error) {
    response.status(500).json({ error: "No se pudo crear el intercambio" });
  }
}