import 'package:flutter/material.dart';

class Player {
  final String id;
  final String name;
  final Color color;
  final String? avatar;

  const Player({
    required this.id,
    required this.name,
    required this.color,
    this.avatar,
  });

  Player copyWith({
    String? id,
    String? name,
    Color? color,
    String? avatar,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      avatar: avatar ?? this.avatar,
    );
  }

  // Factory for empty/guest
  factory Player.guest() {
    return const Player(id: 'guest', name: 'Guest', color: Color(0xFFaaaaaa));
  }
}
