import { neon } from '@neondatabase/serverless';

export default async function handler(request, response) {
  try {
    const iso3 = request.query.iso3;

    if (!iso3) {
      return response.status(400).json({ error: "Falta el parametro iso3" });
    }

    const sql = neon(process.env.DATABASE_URL);
    const laminas = await sql`
      SELECT id, nombre_sticker, posicion, equipo_actual, es_especial, foto_url
      FROM laminas_panini_2026
      WHERE iso3 = ${iso3}
      ORDER BY id
    `;

    if (laminas.length === 0) {
      return response.status(404).json({ error: "No se encontraron laminas para ese pais" });
    }

    response.status(200).json({ iso3: iso3, total: laminas.length, laminas: laminas });
  } catch (error) {
    response.status(500).json({ error: "No se pudo consultar la base de datos" });
  }
}