// lib/widgets/connection_status_bar.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';

class ConnectionStatusBar extends StatelessWidget {
  const ConnectionStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceProvider>(
      builder: (context, provider, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _getStatusColor(provider.isConnected),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icono de Bluetooth
              Icon(
                _getStatusIcon(provider.isConnected),
                color: const Color.fromARGB(255, 0, 0, 0),
                size: 24,
              ),
              const SizedBox(width: 12),
              
              // Mensaje de estado
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      provider.isConnected ? 'Connected' : 'Disconnected',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (provider.statusMessage.isNotEmpty)
                      Text(
                        provider.statusMessage,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.9),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              
              // Indicador de carga
              if (provider.isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 0, 0, 0)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(bool isConnected) {
    return isConnected ? const Color.fromARGB(255, 3, 117, 255) : const Color.fromARGB(255, 255, 6, 1);
  }

  IconData _getStatusIcon(bool isConnected) {
    return isConnected 
        ? Icons.bluetooth_connected 
        : Icons.bluetooth_disabled;
  }
}
