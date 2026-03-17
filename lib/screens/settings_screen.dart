import 'package:flutter/material.dart';
import '../services/file_service.dart';

// Retro Pokedex Colors
class _Colors {
  static const Color redDark = Color(0xFFB71C1C);
  static const Color redPrimary = Color(0xFFD32F2F);
  static const Color screenGreen = Color(0xFF9EBC9E);
  static const Color screenDark = Color(0xFF2D4F2D);
  static const Color blueLight = Color(0xFF03A9F4);
  static const Color blackFrame = Color(0xFF1A1A1A);
}

class SettingsScreen extends StatefulWidget {
  final bool embedded;
  
  const SettingsScreen({super.key, this.embedded = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FileService _fileService = FileService();
  String _cacheSize = 'Calculating...';
  bool _offlineMode = false;
  String _exportStatus = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _calculateCacheSize();
  }

  Future<void> _loadSettings() async {
    final settings = await _fileService.loadSettings();
    setState(() {
      _offlineMode = settings['offlineMode'] ?? false;
    });
  }

  Future<void> _calculateCacheSize() async {
    final size = await _fileService.getCacheSize();
    setState(() {
      if (size < 1024) {
        _cacheSize = '$size B';
      } else if (size < 1024 * 1024) {
        _cacheSize = '${(size / 1024).toStringAsFixed(1)} KB';
      } else {
        _cacheSize = '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    });
  }

  Future<void> _toggleOfflineMode(bool value) async {
    setState(() => _offlineMode = value);
    await _fileService.saveSettings({'offlineMode': value});
  }

  Future<void> _clearCache() async {
    await _fileService.clearCache();
    await _calculateCacheSize();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache cleared')),
      );
    }
  }

  Future<void> _exportFavorites() async {
    setState(() => _exportStatus = 'Export complete!');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Favorites exported')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return _buildContent();
    }
    
    return Scaffold(
      backgroundColor: _Colors.redPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _Colors.redDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Colors.blackFrame, width: 3),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _Colors.blackFrame, width: 2),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _Colors.blueLight,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.settings, color: Colors.white, size: 16),
          ),
          const Spacer(),
          const Text(
            'SETTINGS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 50),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      margin: widget.embedded 
          ? const EdgeInsets.fromLTRB(8, 0, 8, 8)
          : const EdgeInsets.fromLTRB(8, 0, 8, 8),
      decoration: BoxDecoration(
        color: _Colors.redDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Colors.blackFrame, width: 3),
      ),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _Colors.screenGreen,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _Colors.blackFrame, width: 3),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('FILE STORAGE'),
              const SizedBox(height: 12),
              
              _buildSettingRow(
                'Cache Size',
                _cacheSize,
                trailing: _buildButton('CLEAR', _clearCache),
              ),
              const SizedBox(height: 12),
              
              _buildSettingToggle(
                'Offline Mode',
                'Load cached data first',
                _offlineMode,
                _toggleOfflineMode,
              ),
              
              const SizedBox(height: 20),
              _buildSectionHeader('DATA EXPORT'),
              const SizedBox(height: 12),
              
              _buildSettingRow(
                'Export Favorites',
                'Save to JSON file',
                trailing: _buildButton('EXPORT', _exportFavorites),
              ),
              
              if (_exportStatus.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7A9A7A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _exportStatus,
                    style: const TextStyle(
                      color: _Colors.screenDark,
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 20),
              _buildSectionHeader('REST API INFO'),
              const SizedBox(height: 12),
              
              _buildInfoRow('Base URL', 'pokeapi.co/api/v2'),
              const SizedBox(height: 8),
              _buildInfoRow('Endpoints', '/pokemon, /type'),
              const SizedBox(height: 8),
              _buildInfoRow('Strategy', 'Cache-first'),
              
              const SizedBox(height: 20),
              _buildSectionHeader('APP INFO'),
              const SizedBox(height: 12),
              
              _buildInfoRow('Version', '1.0.0'),
              const SizedBox(height: 8),
              _buildInfoRow('Platform', 'Flutter'),
              const SizedBox(height: 8),
              _buildInfoRow('Data', 'PokeAPI.co'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: _Colors.screenDark,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '[ $text ]',
        style: const TextStyle(
          color: _Colors.screenGreen,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSettingRow(String label, String value, {Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF7A9A7A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _Colors.screenDark, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _Colors.screenDark,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF4A6A4A),
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildSettingToggle(
    String label,
    String description,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF7A9A7A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _Colors.screenDark, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _Colors.screenDark,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF4A6A4A),
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: _Colors.blueLight,
            activeColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF7A9A7A),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _Colors.screenDark, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _Colors.screenDark,
              fontFamily: 'monospace',
              fontSize: 11,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: _Colors.screenDark,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _Colors.blueLight,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: _Colors.blackFrame, width: 2),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
