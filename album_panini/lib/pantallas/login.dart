import 'package:flutter/material.dart';
import '../tema.dart';
import '../servicios/api.dart';
import 'paises.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _nombre = TextEditingController();
  bool _esRegistro = false;
  bool _cargando = false;
  String? _error;

  Future<void> _enviar() async {
    setState(() { _cargando = true; _error = null; });

    if (_esRegistro) {
      final res = await ApiServicio.registro(
          _nombre.text.trim(), _email.text.trim(), _password.text);
      if (res['ok']) {
        setState(() { _esRegistro = false; _cargando = false; });
        _mostrarMensaje('Cuenta creada. Ahora inicia sesion.');
      } else {
        setState(() { _error = res['error']; _cargando = false; });
      }
    } else {
      final res = await ApiServicio.login(_email.text.trim(), _password.text);
      if (res['ok']) {
        if (!mounted) return;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const PantallaPaises()));
      } else {
        setState(() { _error = res['error']; _cargando = false; });
      }
    }
  }

  void _mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.sports_soccer, size: 72, color: Paleta.primario),
                const SizedBox(height: 16),
                const Text('Album Panini 2026',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600,
                        color: Paleta.textoPrincipal)),
                const SizedBox(height: 6),
                Text(_esRegistro ? 'Crea tu cuenta' : 'Inicia sesion para coleccionar',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Paleta.textoSecundario)),
                const SizedBox(height: 32),
                if (_esRegistro) ...[
                  _campo(_nombre, 'Nombre', Icons.person),
                  const SizedBox(height: 14),
                ],
                _campo(_email, 'Correo', Icons.email),
                const SizedBox(height: 14),
                _campo(_password, 'Contrasena', Icons.lock, oculto: true),
                const SizedBox(height: 14),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center),
                  ),
                ElevatedButton(
                  onPressed: _cargando ? null : _enviar,
                  child: _cargando
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2,
                              color: Paleta.fondo))
                      : Text(_esRegistro ? 'Registrarme' : 'Entrar'),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => setState(() {
                    _esRegistro = !_esRegistro;
                    _error = null;
                  }),
                  child: Text(
                    _esRegistro
                        ? 'Ya tengo cuenta'
                        : 'No tengo cuenta, registrarme',
                    style: const TextStyle(color: Paleta.dorado),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo(TextEditingController ctrl, String hint, IconData icono,
      {bool oculto = false}) {
    return TextField(
      controller: ctrl,
      obscureText: oculto,
      style: const TextStyle(color: Paleta.textoPrincipal),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Paleta.textoSecundario),
        prefixIcon: Icon(icono, color: Paleta.textoSecundario),
        filled: true,
        fillColor: Paleta.superficie,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}