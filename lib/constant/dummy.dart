import 'dart:ui';

import 'package:doova/model/add_task/category.dart';
import 'package:doova/model/add_task/priority.dart';
import 'package:doova/r.dart';

final List<PriorityModel> priority = [
  PriorityModel(image: IconManager.flag, number: 1),
  PriorityModel(image: IconManager.flag, number: 2),
  PriorityModel(image: IconManager.flag, number: 3),
  PriorityModel(image: IconManager.flag, number: 4),
  PriorityModel(image: IconManager.flag, number: 5),
  PriorityModel(image: IconManager.flag, number: 6),
  PriorityModel(image: IconManager.flag, number: 7),
  PriorityModel(image: IconManager.flag, number: 8),
  PriorityModel(image: IconManager.flag, number: 9),
  PriorityModel(image: IconManager.flag, number: 10),
];

final List<Color> categoryColor = [
  Color(0xffCCFF80),
  Color(0xffFF9680),
  Color(0xff80FFFF),
  Color(0xff80FFD9),
  Color(0xff809CFF),
  Color(0xffFF80EB),
  Color(0xffFC80FF),
  Color(0xff80FFA3),
  Color(0xff80D1FF),
  Color(0xffFF8080),
  Color(0xff80FFD1),
];
final List<CategoryModel> categories = [
  CategoryModel(
    image: IconManager.grocery,
    title: 'Grocery',
    color: Color(0xffCCFF80),
  ),
  CategoryModel(
    image: IconManager.work,
    title: 'Work',
    color: Color(0xffFF9680),
  ),
  CategoryModel(
    image: IconManager.sport,
    title: 'Sport',
    color: Color(0xff80FFFF),
  ),
  CategoryModel(
    image: IconManager.design,
    title: 'Design',
    color: Color(0xff80FFD9),
  ),
  CategoryModel(
    image: IconManager.university,
    title: 'University',
    color: Color(0xff809CFF),
  ),
  CategoryModel(
    image: IconManager.social,
    title: 'Social',
    color: Color(0xffFF80EB),
  ),
  CategoryModel(
    image: IconManager.music,
    title: 'Music',
    color: Color(0xffFC80FF),
  ),
  CategoryModel(
    image: IconManager.health,
    title: 'Health',
    color: Color(0xff80FFA3),
  ),
  CategoryModel(
    image: IconManager.movie,
    title: 'Movie',
    color: Color(0xff80D1FF),
  ),
  CategoryModel(
    image: IconManager.home2,
    title: 'Home',
    color: Color(0xffFF8080),
  ),
  CategoryModel(
    image: IconManager.add,
    title: 'Create New',
    color: Color(0xff80FFD1),
  ),
];
