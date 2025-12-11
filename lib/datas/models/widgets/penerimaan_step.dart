import 'package:get/get_rx/src/rx_types/rx_types.dart';

class PenerimaanStep {
  final int id;
  final String title;
  final String routeName;
  RxBool isCompleted;
  RxBool isActive;

  PenerimaanStep({
    required this.id,
    required this.title,
    required this.routeName,
    bool isCompleted = false,
    bool isActive = false,
  }) : isCompleted = isCompleted.obs,
        isActive = isActive.obs;
}