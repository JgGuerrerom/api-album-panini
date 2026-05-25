import { neon } from '@neondatabase/serverless';
import bcrypt from 'bcryptjs';

export default async function handler(request, response) {
  if (request.method !== 'POST') {
    return response.status(405).json({ error: "Metodo no permitido" });
  }

  try {
    const { nombre, email, password, iso3_pais } = request.body;

    if (!nombre || !email || !password) {
      return response.status(400).json({ error: "Faltan datos obligatorios" });
    }

    const sql = neon(process.env.DATABASE_URL);

    const existente = await sql`SELECT id FROM usuarios WHERE email = ${email}`;
    if (existente.length > 0) {
      return response.status(409).json({ error: "Ese correo ya esta registrado" });
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const nuevo = await sql`
      INSERT INTO usuarios (nombre, email, password_hash, iso3_pais)
      VALUES (${nombre}, ${email}, ${passwordHash}, ${iso3_pais || null})
      RETURNING id, nombre, email, iso3_pais, fecha_registro
    `;

    response.status(201).json({ mensaje: "Usuario registrado", usuario: nuevo[0] });
  } catch (error) {
    response.status(500).json({ error: "No se pudo registrar el usuario" });
  }
}