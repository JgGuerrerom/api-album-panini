import 'package:flutter/material.dart';
import '../tema.dart';
import '../servicios/api.dart';

class PantallaIntercambios extends StatefulWidget {
  const PantallaIntercambios({super.key});

  @override
  State<PantallaIntercambios> createState() => _PantallaIntercambiosState();
}

class _PantallaIntercambiosState extends State<PantallaIntercambios> {
  List<dynamic> _intercambios = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final res = await ApiServicio.misIntercambios();
    setState(() {
      _cargando = false;
      if (res['ok']) {
        _intercambios = res['intercambios'];
        _error = null;
      } else {
        _error = res['error'];
      }
    });
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'aceptado':
        return Paleta.primario;
      case 'rechazado':
        return Colors.redAccent;
      case 'completado':
        return Paleta.dorado;
      default:
        return Paleta.textoSecundario;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis intercambios')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Paleta.primario))
          : _error != null
              ? Center(child: Text(_error!,
                  style: const TextStyle(color: Colors.redAccent)))
              : _intercambios.isEmpty
                  ? const Center(
                      child: Text('Aun no tienes intercambios',
                          style: TextStyle(color: Paleta.textoSecundario)))
                  : RefreshIndicator(
                      color: Paleta.primario,
                      onRefresh: _cargar,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _intercambios.length,
                        itemBuilder: (context, i) {
                          final t = _intercambios[i];
                          final estado = t['estado'] ?? 'propuesto';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Paleta.superficie,
                              borderRadius:
                                  BorderRadius.circular(radioTarjeta),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Intercambio #${t['id']}',
                                      style: const TextStyle(
                                          color: Paleta.textoPrincipal,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _colorEstado(estado)
                                            .withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        estado,
                                        style: TextStyle(
                                            color: _colorEstado(estado),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Propone: ${t['nombre_propone']}',
                                  style: const TextStyle(
                                      color: Paleta.textoSecundario,
                                      fontSize: 13),
                                ),
                                Text(
                                  'Recibe: ${t['nombre_recibe']}',
                                  style: const TextStyle(
                                      color: Paleta.textoSecundario,
                                      fontSize: 13),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Tipo: ${t['tipo']}',
                                  style: const TextStyle(
                                      color: Paleta.dorado, fontSize: 13),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}