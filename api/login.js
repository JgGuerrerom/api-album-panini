import { neon } from '@neondatabase/serverless';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

export default async function handler(request, response) {
  if (request.method !== 'POST') {
    return response.status(405).json({ error: "Metodo no permitido" });
  }

  try {
    const { email, password } = request.body;

    if (!email || !password) {
      return response.status(400).json({ error: "Faltan email o password" });
    }

    const sql = neon(process.env.DATABASE_URL);

    const usuarios = await sql`
      SELECT id, nombre, email, password_hash, iso3_pais
      FROM usuarios WHERE email = ${email}
    `;

    if (usuarios.length === 0) {
      return response.status(401).json({ error: "Correo o contrasena incorrectos" });
    }

    const usuario = usuarios[0];

    const passwordCorrecta = await bcrypt.compare(password, usuario.password_hash);

    if (!passwordCorrecta) {
      return response.status(401).json({ error: "Correo o contrasena incorrectos" });
    }

    const token = jwt.sign(
      { id: usuario.id, email: usuario.email },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    response.status(200).json({
      mensaje: "Login exitoso",
      token: token,
      usuario: { id: usuario.id, nombre: usuario.nombre, email: usuario.email, iso3_pais: usuario.iso3_pais }
    });
  } catch (error) {
    response.status(500).json({ error: "No se pudo iniciar sesion" });
  }
}