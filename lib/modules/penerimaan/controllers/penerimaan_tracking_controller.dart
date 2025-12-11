import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../datas/models/transactions/penerimaan/transaction_model.dart';
import '../../../datas/models/widgets/penerimaan_step.dart';
import '../../../routes/app_pages.dart';
import '../../auth/services/login_service.dart';
import '../../transactions/penerimaan/services/outstanding_service.dart';

class PenerimaanTrackingController extends GetxController {
  final LoginService _loginService = Get.find<LoginService>();

  final isLoading = true.obs;
  final Rx<TransactionModel?> transaction = Rx<TransactionModel?>(null);

  final currentStepId = 0.obs;
  final steps = <PenerimaanStep>[].obs;

  final formattedDate = "-".obs;
  final noBast = "-".obs;

  @override
  void onInit() {
    super.onInit();
    _initializeSteps();
    _loadArgumentsAndFetch();
  }

  void _initializeSteps() {
    steps.assignAll([
      PenerimaanStep(id: 1, title: 'Pengecekan Dokumen', routeName: Routes.PENERIMAAN),
      PenerimaanStep(id: 2, title: 'Pengisian Solar', routeName: Routes.PENGISIAN_SOLAR),
      PenerimaanStep(id: 3, title: 'Pengukuran Setelah', routeName: Routes.PENERIMAAN_SETELAH),
      PenerimaanStep(id: 4, title: 'Pembuatan BAST', routeName: Routes.PENERIMAAAN_VERIFIKASI_BAST),
      PenerimaanStep(id: 5, title: 'Proses Approval KASIE', routeName: Routes.HOME),
      PenerimaanStep(id: 6, title: 'Proses Approval MANAGER', routeName: Routes.HOME),
      PenerimaanStep(id: 7, title: 'Selesai', routeName: Routes.HOME),
    ]);
  }

  void _loadArgumentsAndFetch() {
    final args = Get.arguments;
    String? targetNoBast;

    if (args != null) {
      if (args is Map && args['noBast'] != null) {
        targetNoBast = args['noBast'];
      } else if (args is String) {
        targetNoBast = args;
      }
    }

    if (targetNoBast != null) {
      noBast.value = targetNoBast;
      _fetchTransactionData(targetNoBast);
    } else {
      isLoading.value = false;
      Get.snackbar("Error", "No BAST tidak ditemukan");
    }
  }

  Future<void> _fetchTransactionData(String noDoc) async {
    isLoading.value = true;
    final auth = _loginService.getCurrentAuth();

    if (auth != null) {
      final outstandingService = OutstandingService(auth.user.username);
      // Returns TransactionModel
      final data = await outstandingService.getTransactionByNoBast(noDoc);

      if (data != null) {
        transaction.value = data;

        _formatDate(data.dateCreated);
        _determineStepFromStatus(data);
      }
    }
    isLoading.value = false;
  }

  void _determineStepFromStatus(TransactionModel? trx) {
    String? status = trx?.status;

    if (status == null) {
      currentStepId.value = 2;
      _updateStepUI();
      return;
    }

    switch (status.toLowerCase()) {
      case 'proses':
      case 'pengisian_solar':
        currentStepId.value = 2;
        break;

      case 'setelah_pengisian':
        currentStepId.value = 3;
        break;

      case 'verifikasi_bast':
        currentStepId.value = 4;
        break;

      case 'approval':
        String level = trx?.currentLevelApproval ?? "";
        int step = trx?.currentStepApproval ?? 1;

        if (level.toUpperCase().contains("fuel_level_2") || step >= 2) {
          currentStepId.value = 6;
        } else {
          currentStepId.value = 5;
        }
        break;

      case 'selesai':
      case 'approved':
        currentStepId.value = 7;
        break;

      default:
        currentStepId.value = 2;
    }

    _updateStepUI();
  }

  void _updateStepUI() {
    for (var step in steps) {
      step.isCompleted.value = step.id < currentStepId.value;
      step.isActive.value = step.id == currentStepId.value;
    }
  }

  void _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      formattedDate.value = "-";
      return;
    }
    try {
      DateTime date = DateTime.parse(dateString);
      String dayName = DateFormat('EEEE', 'id_ID').format(date); // Butuh initializeDateFormatting di main jika error locale
      String fullDate = DateFormat('dd/MM/yyyy').format(date);

      // Manual translation fallback jika locale indonesia belum setup
      if (dayName == 'Monday') dayName = 'Senin';
      else if (dayName == 'Tuesday') dayName = 'Selasa';
      else if (dayName == 'Wednesday') dayName = 'Rabu';
      else if (dayName == 'Thursday') dayName = 'Kamis';
      else if (dayName == 'Friday') dayName = 'Jumat';
      else if (dayName == 'Saturday') dayName = 'Sabtu';
      else if (dayName == 'Sunday') dayName = 'Minggu';

      formattedDate.value = "$dayName, $fullDate";
    } catch (e) {
      formattedDate.value = dateString;
    }
  }
}