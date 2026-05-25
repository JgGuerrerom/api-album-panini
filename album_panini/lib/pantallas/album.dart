import 'package:flutter/material.dart';
import '../tema.dart';
import '../servicios/api.dart';

class PantallaAlbum extends StatefulWidget {
  final String iso3;
  final String nombrePais;
  const PantallaAlbum({super.key, required this.iso3, required this.nombrePais});

  @override
  State<PantallaAlbum> createState() => _PantallaAlbumState();
}

class _PantallaAlbumState extends State<PantallaAlbum> {
  List<dynamic> _laminas = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final res = await ApiServicio.obtenerColeccion(widget.iso3);
    setState(() {
      _cargando = false;
      if (res['ok']) {
        _laminas = res['laminas'];
        _error = null;
      } else {
        _error = res['error'];
      }
    });
  }

  Future<void> _registrar(String laminaId) async {
    final res = await ApiServicio.registrarLamina(laminaId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['ok'] ? res['mensaje'] : res['error'])),
    );
    if (res['ok']) _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final total = _laminas.length;
    final tengo = _laminas.where((l) => (l['cantidad'] ?? 0) > 0).length;

    return Scaffold(
      appBar: AppBar(title: Text(widget.nombrePais)),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Paleta.primario))
          : _error != null
              ? Center(child: Text(_error!,
                  style: const TextStyle(color: Colors.redAccent)))
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Paleta.superficie,
                        borderRadius: BorderRadius.circular(radioTarjeta),
                      ),
                      child: Text(
                        'Tienes $tengo de $total laminas',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Paleta.textoPrincipal,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _laminas.length,
                        itemBuilder: (context, i) =>
                            _tarjetaLamina(_laminas[i]),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
    );
  }

  Widget _tarjetaLamina(dynamic lamina) {
    final int cantidad = lamina['cantidad'] ?? 0;
    final bool laTengo = cantidad > 0;
    final bool esEspecial = lamina['es_especial'] == true;

    return GestureDetector(
      onTap: () => _registrar(lamina['id']),
      child: Opacity(
        opacity: laTengo ? 1.0 : 0.45,
        child: Container(
          decoration: BoxDecoration(
            color: Paleta.superficie,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: esEspecial && laTengo ? Paleta.dorado : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10)),
                  child: ColorFiltered(
                    colorFilter: laTengo
                        ? const ColorFilter.mode(
                            Colors.transparent, BlendMode.multiply)
                        : const ColorFilter.matrix(<double>[
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0, 0, 0, 1, 0,
                          ]),
                    child: Image.network(
                      lamina['foto_url'] ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: Paleta.fondo,
                        child: const Icon(Icons.person,
                            color: Paleta.textoSecundario, size: 40),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  children: [
                    Text(
                      lamina['nombre_sticker'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Paleta.textoPrincipal,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      cantidad > 1 ? 'Repetidas: ${cantidad - 1}' : (laTengo ? 'En album' : 'Falta'),
                      style: TextStyle(
                          color: cantidad > 1
                              ? Paleta.dorado
                              : Paleta.textoSecundario,
                          fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}