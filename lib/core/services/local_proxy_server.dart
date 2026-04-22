import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;

class _TrackCredentials {
  final String apiKey;
  final String arl;
  final String backendBaseUrl;
  final String quality;

  const _TrackCredentials({
    required this.apiKey,
    required this.arl,
    required this.backendBaseUrl,
    required this.quality,
  });
}

class LocalProxyServer {
  HttpServer? _server;
  final Map<String, _TrackCredentials> _registry = {};
  final http.Client _httpClient = http.Client();

  int get port {
    assert(_server != null, 'LocalProxyServer.start() must be called first.');
    return _server!.port;
  }

  bool get isRunning => _server != null;

  Future<void> start() async {
    if (_server != null) return;

    final handler = const shelf.Pipeline()
        .addMiddleware(_logMiddleware())
        .addHandler(_handleRequest);

    _server = await shelf_io.serve(
      handler,
      InternetAddress.loopbackIPv4,
      0,
      shared: false,
    );

    debugPrint('[LocalProxy] Listening on 127.0.0.1:${_server!.port}');
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    _httpClient.close();
    _registry.clear();
    debugPrint('[LocalProxy] Server stopped.');
  }

  void registerTrack({
    required String trackId,
    required String apiKey,
    required String arl,
    required String backendBaseUrl,
    String quality = 'FLAC',
  }) {
    _registry[trackId] = _TrackCredentials(
      apiKey: apiKey,
      arl: arl,
      backendBaseUrl: backendBaseUrl,
      quality: quality,
    );
  }

  String proxyUrlFor(String trackId) {
    assert(_server != null, 'Call start() before proxyUrlFor().');
    return 'http://127.0.0.1:$port/$trackId.flac';
  }

  Future<shelf.Response> _handleRequest(shelf.Request request) async {
    final rawPath = request.url.path;
    final trackId = rawPath.replaceAll('.flac', '').replaceAll('.mp3', '');

    final creds = _registry[trackId];
    if (creds == null) {
      debugPrint('[LocalProxy] ⚠️  No credentials for trackId: $trackId');
      return shelf.Response.notFound('Track not registered: $trackId');
    }

    final base = creds.backendBaseUrl.endsWith('/')
        ? creds.backendBaseUrl
        : '${creds.backendBaseUrl}/';

    final targetUri = Uri.parse(
      '${base}stream/$trackId.flac?quality=${creds.quality}',
    );

    final forwardHeaders = <String, String>{
      'x-api-key': creds.apiKey,
      'x-stream-auth': creds.arl,
      'Accept': '*/*',
      'User-Agent': 'MyWave/1.0 (iOS; StreamProxy)',
    };

    final rangeHeader = request.headers['range'] ?? request.headers['Range'];
    if (rangeHeader != null) {
      forwardHeaders['Range'] = rangeHeader;
    }

    try {
      final upstreamRequest = http.Request('GET', targetUri)
        ..headers.addAll(forwardHeaders);

      final streamedResponse = await _httpClient.send(upstreamRequest);

      final responseHeaders = <String, String>{};
      responseHeaders['Accept-Ranges'] = 'bytes';

      final contentType = streamedResponse.headers['content-type'] ?? 'audio/flac';
      responseHeaders['Content-Type'] = contentType;

      final contentLength = streamedResponse.headers['content-length'];
      if (contentLength != null) {
        responseHeaders['Content-Length'] = contentLength;
      }
      final contentRange = streamedResponse.headers['content-range'];
      if (contentRange != null) {
        responseHeaders['Content-Range'] = contentRange;
      }

      return shelf.Response(
        streamedResponse.statusCode,
        body: streamedResponse.stream,
        headers: responseHeaders,
      );
    } on http.ClientException catch (e) {
      debugPrint('[LocalProxy] ❌ HTTP error forwarding $trackId: $e');
      return shelf.Response.internalServerError(
        body: 'Upstream request failed: $e',
      );
    } catch (e) {
      debugPrint('[LocalProxy] ❌ Unexpected error for $trackId: $e');
      return shelf.Response.internalServerError(body: 'Proxy error: $e');
    }
  }

  shelf.Middleware _logMiddleware() {
    return (shelf.Handler inner) {
      return (shelf.Request request) async {
        debugPrint(
          '[LocalProxy] ${request.method} /${request.url.path}'
          '${request.headers.containsKey("range") ? " [Range: ${request.headers["range"]}]" : ""}',
        );
        final response = await inner(request);
        debugPrint('[LocalProxy] → ${response.statusCode}');
        return response;
      };
    };
  }
}
