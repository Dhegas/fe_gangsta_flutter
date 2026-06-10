import 'dart:convert';
import 'dart:async';
import 'package:fe_gangsta_flutter/core/network/api_config.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  WebSocketChannel? _channel;
  bool _isConnecting = false;
  Timer? _reconnectTimer;

  // Callback to forward new order event to State Management / UI
  Function(Map<String, dynamic>)? onNewOrderReceived;

  // Connects WebSocket to the Server
  void connect({required String token, required String tenantId}) {
    if (_channel != null || _isConnecting) return;
    _isConnecting = true;

    // Derived WebSocket URL dynamically based on ApiConfig.baseUrl
    final baseUrl = ApiConfig.baseUrl;
    final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final wsScheme = cleanBaseUrl.startsWith('https://') ? 'wss://' : 'ws://';
    final host = cleanBaseUrl.replaceFirst(RegExp(r'^https?://'), '');
    final String wsUrl = "$wsScheme$host/ws?token=$token&tenant_id=$tenantId";

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _channel!.ready.then((_) {
        _isConnecting = false;
        print("🔌 WebSocket KDS Terhubung ke Cabang: $tenantId");
      }).catchError((error) {
        _isConnecting = false;
        print("❌ WebSocket ready error: $error");
        _reconnect(token: token, tenantId: tenantId);
      });

      // Listen to the stream from the server
      _channel!.stream.listen(
        (rawMessage) {
          _handleIncomingMessage(rawMessage);
        },
        onError: (error) {
          print("❌ WebSocket Stream Error: $error");
          _reconnect(token: token, tenantId: tenantId);
        },
        onDone: () {
          print("🔌 WebSocket Terputus. Mencoba menghubungkan kembali dalam 5 detik...");
          _reconnect(token: token, tenantId: tenantId);
        },
      );
    } catch (e) {
      _isConnecting = false;
      print("❌ Gagal membuat koneksi WebSocket: $e");
      _reconnect(token: token, tenantId: tenantId);
    }
  }

  // Parse incoming JSON data
  void _handleIncomingMessage(dynamic rawMessage) {
    try {
      final Map<String, dynamic> data = jsonDecode(rawMessage);

      // Filter by event type
      if (data['type'] == 'new_order') {
        if (onNewOrderReceived != null) {
          onNewOrderReceived!(data);
        }
      }
    } catch (e) {
      print("Gagal parse data WebSocket: $e");
    }
  }

  // Auto-Reconnect logic if connection gets lost
  void _reconnect({required String token, required String tenantId}) {
    _channel = null;
    if (_reconnectTimer?.isActive ?? false) return; // Prevent duplicate reconnect timers
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      connect(token: token, tenantId: tenantId);
    });
  }

  // Cleanly disconnect when leaving page or logging out
  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _isConnecting = false;
    if (_channel != null) {
      _channel!.sink.close(status.goingAway);
      _channel = null;
      print("🔌 WebSocket KDS diputus secara manual.");
    }
  }
}
