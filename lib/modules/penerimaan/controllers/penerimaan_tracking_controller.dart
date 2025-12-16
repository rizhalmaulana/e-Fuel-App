import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../datas/models/transactions/penerimaan/transaction_model.dart';
import '../../../datas/models/widgets/penerimaan_step.dart';
import '../../../routes/app_pages.dart';
import '../../auth/services/login_service.dart';
import '../../transactions/outstanding_service.dart';

class PenerimaanTrackingController extends GetxController {
  final LoginService _loginService = Get.find<LoginService>();
  final isLoading = true.obs;
  final Rx<TransactionModel?> transaction = Rx<TransactionModel?>(null);

  final currentStepId = 0.obs;
  final steps = <PenerimaanStep>[].obs;
  final formattedDate = "-".obs;
  final noBast = "-".obs;

  // Variabel helper untuk UI button
  bool get isWaitingApproval => currentStepId.value == 5 || currentStepId.value == 6;
  bool get isFinished => currentStepId.value == 7;

  @override
  void onInit() {
    super.onInit();
    _initializeSteps();
    _loadArgumentsAndFetch();
  }

  void _initializeSteps() {
    steps.assignAll([
      PenerimaanStep(id: 1, title: 'Pengisian Dokumen', routeName: Routes.PENERIMAAN),
      PenerimaanStep(id: 2, title: 'Pengisian Solar', routeName: Routes.PENGISIAN_SOLAR),
      PenerimaanStep(id: 3, title: 'Pengukuran Solar Setelah Pengisian', routeName: Routes.PENERIMAAN_SETELAH),
      PenerimaanStep(id: 4, title: 'Pembuatan BAST', routeName: Routes.PENERIMAAAN_VERIFIKASI_BAST),
      PenerimaanStep(id: 5, title: 'Proses Approval KRANI', routeName: Routes.HOME),   // Status: approval_krani
      PenerimaanStep(id: 6, title: 'Proses Approval KASIE', routeName: Routes.HOME),   // Status: approval_kasie
      PenerimaanStep(id: 7, title: 'Proses Approval MANAGER', routeName: Routes.HOME), // Status: approval_manager
      PenerimaanStep(id: 8, title: 'Selesai', routeName: Routes.HOME),                 // Status: selesai
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
    String? status = trx?.status?.toLowerCase();

    if (status == null) {
      currentStepId.value = 1;
      _updateStepUI();
      return;
    }

    switch (status) {
      case 'draft':
        currentStepId.value = 1;
        break;
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

      case 'approval_kasie':
        currentStepId.value = 5;
        break;
      case 'approval_manager':
        currentStepId.value = 6;
        break;

      case 'selesai':
      case 'approved':
        currentStepId.value = 7;
        break;

      default:
        if (status == 'approval') {
          currentStepId.value = 5;
        } else {
          currentStepId.value = 1;
        }
    }

    _updateStepUI();
  }

  void _updateStepUI() {
    for (var step in steps) {
      if (currentStepId.value == 7) {
        step.isCompleted.value = true;
        step.isActive.value = false;
        if(step.id == 7) step.isActive.value = true;
      } else {
        step.isCompleted.value = step.id < currentStepId.value;
        step.isActive.value = step.id == currentStepId.value;
      }
    }
  }

  void backToHome() {
    Get.offAllNamed(Routes.HOME);
  }

  void viewBastPdf() {
    Get.snackbar("Informasi", "Fitur Lihat BAST PDF");
  }

  void _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      formattedDate.value = "-";
      return;
    }
    try {
      DateTime date = DateTime.parse(dateString);
      String fullDate = DateFormat('dd/MM/yyyy').format(date);

      formattedDate.value = fullDate;
    } catch (e) {
      formattedDate.value = dateString;
    }
  }
}