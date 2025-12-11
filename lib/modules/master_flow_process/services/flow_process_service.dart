import 'package:get/get.dart';
import '../../../datas/models/widgets/penerimaan_step.dart';
import '../../../routes/app_pages.dart';

class FlowProcessService extends GetxService {
  final RxList<PenerimaanStep> steps = [
    PenerimaanStep(id: 1, title: 'Pengecekan Dokumen', routeName: Routes.PENERIMAAN),
    PenerimaanStep(id: 2, title: 'Pengisian Solar', routeName: Routes.PENGISIAN_SOLAR),
    PenerimaanStep(id: 3, title: 'Pengukuran Setelah Pengisian', routeName: Routes.PENERIMAAN_SETELAH),
    PenerimaanStep(id: 4, title: 'Pembuatan BAST', routeName: Routes.PENERIMAAAN_VERIFIKASI_BAST),
    PenerimaanStep(id: 5, title: 'Proses Approval KASIE', routeName: Routes.HOME),
    PenerimaanStep(id: 6, title: 'Proses Approval MANAGER', routeName: Routes.HOME),
    PenerimaanStep(id: 7, title: 'Selesai', routeName: Routes.HOME),
  ].obs;

  // 2. Simpan State Step Aktif disini
  final RxInt currentStepId = 1.obs;
  final RxString currentStepTitle = 'Pengecekan Dokumen'.obs;

  @override
  void onInit() {
    super.onInit();
    ever(currentStepId, (_) => _updateStepStatus());
    _updateStepStatus(); // Run first time
  }

  void _updateStepStatus() {
    for (var step in steps) {
      step.isCompleted.value = step.id < currentStepId.value;
      step.isActive.value = step.id == currentStepId.value;
    }

    final activeStep = steps.firstWhereOrNull((step) => step.isActive.value);
    if (activeStep != null) {
      currentStepTitle.value = activeStep.title;
    }
  }

  void nextStep() {
    if (currentStepId.value < steps.length) {
      currentStepId.value++;
    }
  }

  void previousStep() {
    if (currentStepId.value > 1) {
      currentStepId.value--;
    }
  }

  void goToStep(int stepId) {
    if (stepId >= 1 && stepId <= steps.length) {
      currentStepId.value = stepId;
    }
  }

  // Reset workflow ke awal
  void resetWorkflow() {
    currentStepId.value = 1;
  }
}