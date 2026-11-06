import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/services/audio_service.dart';

/// Devuelve el [AudioService] si la pantalla lo tiene registrado.
///
/// Los widgets de la interfaz se usan tambien en pruebas aisladas, donde
/// no siempre hay proveedor: en ese caso se juega **en silencio**.
AudioService? audioServiceOf(BuildContext context) {
  try {
    return context.read<AudioService>();
  } on ProviderNotFoundException {
    return null;
  }
}
