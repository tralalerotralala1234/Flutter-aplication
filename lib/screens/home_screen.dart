// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';
import '../widgets/connection_status_bar.dart';
import '../widgets/device_list.dart';
import '../widgets/sensor_display.dart';
import 'bluetooth_devices_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Home Control'),
        actions: [
          // Botón para ir a la pantalla de conexión Bluetooth
          IconButton(
            icon: const Icon(Icons.bluetooth),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BluetoothDevicesScreen(),
                ),
              );
            },
            tooltip: 'Connect Device',
          ),
          // Botón de menú adicional
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'disconnect') {
                _handleDisconnect();
              } else if (value == 'Update') {
                _handleRefresh();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Update',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Update Sensors'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'disconnect',
                child: Row(
                  children: [
                    Icon(Icons.bluetooth_disabled),
                    SizedBox(width: 8),
                    Text('Disconnect'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de estado de conexión
          const ConnectionStatusBar(),
          
          // Contenido principal
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.devices),
            label: 'Devices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sensors),
            label: 'Sensors',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? _buildFloatingActionButtons()
          : null,
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const DeviceList();
      case 1:
        return const SensorDisplay();
      default:
        return const DeviceList();
    }
  }

  Widget _buildFloatingActionButtons() {
    return Consumer<DeviceProvider>(
      builder: (context, provider, child) {
        if (!provider.isConnected) return const SizedBox.shrink();
        
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón para encender todos
            FloatingActionButton(
              heroTag: 'all on',
              onPressed: provider.isLoading
                  ? null
                  : () => provider.turnOnAllLEDs(),
              tooltip: 'Turn All on',
              child: const Icon(Icons.lightbulb),
            ),
            const SizedBox(height: 10),
            // Botón para apagar todos
            FloatingActionButton(
              heroTag: 'all off',
              onPressed: provider.isLoading
                  ? null
                  : () => provider.turnOffAllLEDs(),
              tooltip: 'Turn All off',
              child: const Icon(Icons.lightbulb_outline),
            ),
          ],
        );
      },
    );
  }

  void _handleDisconnect() async {
    final provider = context.read<DeviceProvider>();
    
    if (!provider.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No device connected')),
      );
      return;
    }

    try {
      await provider.disconnect();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Disconnected successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _handleRefresh() async {
    final provider = context.read<DeviceProvider>();
    
    if (!provider.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no device connected')),
      );
      return;
    }

    try {
      await provider.requestSensorData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Updating sensor data...')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
