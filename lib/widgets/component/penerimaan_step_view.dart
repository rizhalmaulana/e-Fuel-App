// penerimaan_step_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';

import '../../datas/models/widgets/penerimaan_step.dart';

class PenerimaanStepView extends StatelessWidget {
  final List<PenerimaanStep> steps;

  const PenerimaanStepView({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 16),
            child: Text(
              'Progress Transaksi',
              style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),

          Obx(() => Column(
            children: List.generate(steps.length, (index) {
              final step = steps[index];
              return _buildStepItem(step, index < steps.length - 1);
            }),
          )),
        ],
      ),
    );
  }

  Widget _buildStepItem(PenerimaanStep step, bool hasLine) {
    Color iconColor = AppColors.secondaryText.withOpacity(0.5);
    Widget icon;

    if (step.isCompleted.value) {
      icon = const Icon(Icons.check_circle, color: AppColors.primary, size: 28);
    } else if (step.isActive.value) {
      icon = const Icon(Icons.radio_button_checked, color: AppColors.primary, size: 28);
    } else {
      icon = Icon(Icons.circle_outlined, color: AppColors.secondaryText.withOpacity(0.5), size: 28);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Line & Icon
          Column(
            children: [
              icon,
              if (hasLine)
                Expanded(
                  child: Container(
                    width: 3,
                    color: step.isCompleted.value || step.isActive.value
                        ? AppColors.primary
                        : AppColors.backgroundGrey,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Step Title/Action
          Expanded(
            child: GestureDetector(
              onTap: step.isCompleted.value || step.isActive.value
                  ? () => Get.toNamed(step.routeName)
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Text(
                  step.title,
                  style: AppFonts.fUrbanistSemiBold14.copyWith(
                    color: step.isCompleted.value || step.isActive.value
                        ? AppColors.darkText
                        : AppColors.secondaryText,
                    decoration: step.isCompleted.value || step.isActive.value
                        ? TextDecoration.none
                        : TextDecoration.lineThrough,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}