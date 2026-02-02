import 'package:flutter/material.dart';

class CategoryModel {
  final String? id;
  final String? image;      // for default category
  final IconData? icon;     // for user-added category
  final String title;
  final Color? color;

  CategoryModel({
    this.id,
    this.image,
    this.icon,
    required this.title,
    this.color,
  });

  CategoryModel copyWith({
    String? id,
    String? image,
    IconData? icon,
    String? title,
    Color? color,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      image: image ?? this.image,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'icon': icon?.codePoint,
      'iconFontFamily': icon?.fontFamily,
      'iconFontPackage': icon?.fontPackage,
      'title': title,
      'color': color?.value,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return CategoryModel(
      id: id,
      image: map['image'],
      icon: map['icon'] != null
          ? IconData(
              map['icon'],
              fontFamily: map['iconFontFamily'],
              fontPackage: map['iconFontPackage'],
            )
          : null,
      title: map['title'],
      color: map['color'] != null ? Color(map['color']) : null,
    );
  }
}
