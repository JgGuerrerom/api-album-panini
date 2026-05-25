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
    const { lamina_id } = request.body;

    if (!lamina_id) {
      return response.status(400).json({ error: "Falta el lamina_id" });
    }

    const sql = neon(process.env.DATABASE_URL);

    const laminaExiste = await sql`
      SELECT id FROM laminas_panini_2026 WHERE id = ${lamina_id}
    `;
    if (laminaExiste.length === 0) {
      return response.status(404).json({ error: "Esa lamina no existe en el catalogo" });
    }

    const yaLaTiene = await sql`
      SELECT id, cantidad FROM coleccion_usuario
      WHERE usuario_id = ${usuarioToken.id} AND lamina_id = ${lamina_id}
    `;

    if (yaLaTiene.length > 0) {
      const filaActualizada = await sql`
        UPDATE coleccion_usuario
        SET cantidad = cantidad + 1
        WHERE id = ${yaLaTiene[0].id}
        RETURNING lamina_id, cantidad
      `;
      return response.status(200).json({
        mensaje: "Ya tenias esta lamina, ahora es repetida",
        lamina: filaActualizada[0]
      });
    } else {
      const filaNueva = await sql`
        INSERT INTO coleccion_usuario (usuario_id, lamina_id, cantidad)
        VALUES (${usuarioToken.id}, ${lamina_id}, 1)
        RETURNING lamina_id, cantidad
      `;
      return response.status(201).json({
        mensaje: "Lamina registrada en tu coleccion",
        lamina: filaNueva[0]
      });
    }
  } catch (error) {
    response.status(500).json({ error: "No se pudo registrar la lamina" });
  }
}