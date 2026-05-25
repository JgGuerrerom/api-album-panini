import jwt from 'jsonwebtoken';

export function verificarToken(request) {
  const cabecera = request.headers.authorization;

  if (!cabecera || !cabecera.startsWith('Bearer ')) {
    return null;
  }

  const token = cabecera.split(' ')[1];

  try {
    const datos = jwt.verify(token, process.env.JWT_SECRET);
    return datos;
  } catch (error) {
    return null;
  }
}