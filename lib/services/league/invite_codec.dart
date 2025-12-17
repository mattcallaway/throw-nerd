import 'dart:convert';
import 'package:archive/archive.dart'; // GZip? maybe later. base64Url is fine.

class InvitePayload {
  final int v;
  final String provider;
  final String leagueId;
  final String leagueName;
  final Map<String, String> remoteRoot;
  final String createdAt;

  InvitePayload({
    this.v = 1,
    required this.provider,
    required this.leagueId,
    required this.leagueName,
    required this.remoteRoot,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'v': v,
    'provider': provider,
    'leagueId': leagueId,
    'leagueName': leagueName,
    'remoteRoot': remoteRoot,
    'createdAt': createdAt,
  };

  factory InvitePayload.fromJson(Map<String, dynamic> json) {
    return InvitePayload(
      v: json['v'] as int? ?? 1,
      provider: json['provider'] as String,
      leagueId: json['leagueId'] as String,
      leagueName: json['leagueName'] as String,
      remoteRoot: Map<String, String>.from(json['remoteRoot'] as Map),
      createdAt: json['createdAt'] as String,
    );
  }
}

class InviteCodec {
  static const String linkPrefix = 'https://dartleagues.app/join#';
  static const String codePrefix = 'DL1-';

  /// Encode payload to a compact base64url string
  static String encode(InvitePayload payload) {
    final jsonStr = jsonEncode(payload.toJson());
    final bytes = utf8.encode(jsonStr);
    return base64Url.encode(bytes).replaceAll('=', ''); // Strip padding
  }

  static InvitePayload decode(String input) {
    String cleanInput = input.trim();
    
    // 1. Handle Link
    if (cleanInput.startsWith(linkPrefix)) {
      cleanInput = cleanInput.substring(linkPrefix.length);
    } else if (cleanInput.startsWith('dartleagues://join?')) {
       // scheme handle
       // This might be complex if parameters are involved, but for now strict suffix
       cleanInput = cleanInput.replaceFirst('dartleagues://join?', '');
    }

    // 2. Handle Code Prefix
    if (cleanInput.startsWith(codePrefix)) {
      cleanInput = cleanInput.substring(codePrefix.length);
      cleanInput = cleanInput.replaceAll('-', ''); // Remove grouping dashes
    }

    try {
      // Add padding back if needed
      int pad = cleanInput.length % 4;
      if (pad > 0) cleanInput += '=' * (4 - pad);
      
      final bytes = base64Url.decode(cleanInput);
      final jsonStr = utf8.decode(bytes);
      return InvitePayload.fromJson(jsonDecode(jsonStr));
    } catch (e) {
      throw FormatException('Invalid invite code or link');
    }
  }

  static String createLink(InvitePayload payload) {
    return '$linkPrefix${encode(payload)}';
  }

  static String createCode(InvitePayload payload) {
    // raw base64url
    final raw = encode(payload);
    // Split into chunks for readability? 
    // Format: DL1-XXXX-XXXX-XXXX
    // Just simple chunking every 4 chars
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
       if (i > 0 && i % 4 == 0) buffer.write('-');
       buffer.write(raw[i]);
    }
    return '$codePrefix$buffer';
  }
}
