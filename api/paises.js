import { neon } from '@neondatabase/serverless';

export default async function handler(request, response) {
  try {
    const sql = neon(process.env.DATABASE_URL);
    const paises = await sql`SELECT iso3, pais, grupo FROM paises_mundial_2026 ORDER BY grupo, pais`;
    response.status(200).json({ total: paises.length, paises: paises });
  } catch (error) {
    response.status(500).json({ error: "No se pudo consultar la base de datos" });
  }
}