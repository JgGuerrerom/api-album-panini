import 'intercambios.dart';
import 'package:flutter/material.dart';
import '../tema.dart';
import '../servicios/api.dart';
import 'login.dart';
import 'album.dart';

class PantallaPaises extends StatefulWidget {
  const PantallaPaises({super.key});

  @override
  State<PantallaPaises> createState() => _PantallaPaisesState();
}

class _PantallaPaisesState extends State<PantallaPaises> {
  List<dynamic> _paises = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final res = await ApiServicio.obtenerPaises();
    setState(() {
      _cargando = false;
      if (res['ok']) {
        _paises = res['paises'];
      } else {
        _error = res['error'];
      }
    });
  }

  Future<void> _cerrarSesion() async {
    await ApiServicio.borrarToken();
    if (!mounted) return;
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const PantallaLogin()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: AppBar(
        title: const Text('Mundial 2026'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Mis intercambios',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PantallaIntercambios()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Paleta.primario))
          : _error != null
              ? Center(
                  child: Text(_error!,
                      style: const TextStyle(color: Colors.redAccent)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _paises.length,
                  itemBuilder: (context, i) {
                    final pais = _paises[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Paleta.superficie,
                        borderRadius: BorderRadius.circular(radioTarjeta),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: Paleta.primario,
                          child: Text(
                            pais['grupo'],
                            style: const TextStyle(
                                color: Paleta.fondo,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        title: Text(
                          pais['pais'],
                          style: const TextStyle(
                              color: Paleta.textoPrincipal,
                              fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Grupo ${pais['grupo']}',
                          style: const TextStyle(color: Paleta.textoSecundario),
                        ),
                        trailing: const Icon(Icons.chevron_right,
                            color: Paleta.textoSecundario),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PantallaAlbum(
                                iso3: pais['iso3'],
                                nombrePais: pais['pais'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}