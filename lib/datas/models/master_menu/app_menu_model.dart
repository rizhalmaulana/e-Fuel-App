import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_menu_model.g.dart';

@HiveType(typeId: 8)
@JsonSerializable(fieldRename: FieldRename.snake)
class AppMenuModel extends HiveObject {
  @HiveField(0)
  final String namaLevelMenu;

  @HiveField(1)
  final List<String> menu;

  AppMenuModel({required this.namaLevelMenu, required this.menu});

  factory AppMenuModel.fromJson(Map<String, dynamic> json) => _$AppMenuModelFromJson(json);
  Map<String, dynamic> toJson() => _$AppMenuModelToJson(this);
}