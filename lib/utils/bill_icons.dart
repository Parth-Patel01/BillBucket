import 'package:flutter/material.dart';

IconData iconForBillName(String name) {
  final n = name.toLowerCase();

  // Car / transport
  if (n.contains('car') || n.contains('rego') || n.contains('fuel')) {
    return Icons.directions_car_filled;
  }

  // Health / medical insurance
  if (n.contains('health') ||
      n.contains('medic') ||
      n.contains('hospital') ||
      n.contains('hcf') ||
      n.contains('bupa') ||
      n.contains('nib')) {
    return Icons.health_and_safety;
  }

  // Phone / mobile
  if (n.contains('phone') ||
      n.contains('mobile') ||
      n.contains('sim') ||
      n.contains('telstra') ||
      n.contains('optus') ||
      n.contains('vodafone')) {
    return Icons.smartphone;
  }

  // Internet / wifi / NBN
  if (n.contains('internet') ||
      n.contains('wifi') ||
      n.contains('broadband') ||
      n.contains('nbn')) {
    return Icons.wifi;
  }

  // Music / streaming audio (Spotify, Apple Music, etc.)
  if (n.contains('spotify') ||
      n.contains('music') ||
      n.contains('apple music') ||
      n.contains('soundcloud')) {
    return Icons.music_note;
  }

  // Video streaming (Netflix, Prime, Disney, YouTube, etc.)
  if (n.contains('netflix') ||
      n.contains('prime') ||
      n.contains('disney') ||
      n.contains('youtube') ||
      n.contains('stan')) {
    return Icons.tv;
  }

  // Rent / mortgage / home
  if (n.contains('rent') ||
      n.contains('mortgage') ||
      n.contains('home loan') ||
      n.contains('house')) {
    return Icons.home_filled;
  }

  // Generic insurance
  if (n.contains('insurance') || n.contains('insurence')) {
    return Icons.shield_outlined;
  }

  // Power / electricity / gas
  if (n.contains('electricity') ||
      n.contains('power') ||
      n.contains('energy') ||
      n.contains('gas') ||
      n.contains('agl') ||
      n.contains('origin')) {
    return Icons.bolt;
  }

  // Generic subscription
  if (n.contains('subscription') || n.contains('sub ')) {
    return Icons.autorenew;
  }

  // Fallback
  return Icons.receipt_long;
}