import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../datas/models/transactions/pengeluaran/transaction_pengeluaran_model.dart';
import '../../../datas/models/widgets/penerimaan_step.dart'; // Kita reuse model step ini untuk UI
import '../../../routes/app_pages.dart';
import '../../auth/services/login_service.dart';
import '../../transactions/outstanding_service.dart';

class PengeluaranTrackingController extends GetxController {
  final LoginService _loginService = Get.find<LoginService>();

  final isLoading = true.obs;
  final Rx<TransactionPengeluaranModel?> transaction = Rx<TransactionPengeluaranModel?>(null);

  final currentStepId = 0.obs;
  final steps = <PenerimaanStep>[].obs; // Menggunakan model UI yang sama
  final formattedDate = "-".obs;
  final noBast = "-".obs;

  bool get isWaitingApproval => currentStepId.value == 3 || currentStepId.value == 4;
  bool get isFinished => currentStepId.value == 5;

  @override
  void onInit() {
    super.onInit();
    _initializeSteps();
    _loadArgumentsAndFetch();
  }

  void _initializeSteps() {
    steps.assignAll([
      PenerimaanStep(id: 1, title: 'Pengisian Solar', routeName: Routes.PENGISIAN_SOLAR_PENGELUARAN),
      PenerimaanStep(id: 2, title: 'Verifikasi Dokumen', routeName: Routes.PENGELUARAN_VERIFIKASI_DOC),
      PenerimaanStep(id: 3, title: 'Approval KRANI', routeName: Routes.HOME),
      PenerimaanStep(id: 4, title: 'Approval KASIE', routeName: Routes.HOME),
      PenerimaanStep(id: 5, title: 'Approval MANAGER', routeName: Routes.HOME),
      PenerimaanStep(id: 6, title: 'Selesai', routeName: Routes.HOME),
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
      Get.snackbar("Error", "No Dokumen tidak ditemukan");
    }
  }

  Future<void> _fetchTransactionData(String noDoc) async {
    isLoading.value = true;
    final auth = _loginService.getCurrentAuth();

    if (auth != null) {
      final outstandingService = OutstandingService(auth.user.username);
      // FETCH MENGGUNAKAN MODEL PENGELUARAN
      final data = await outstandingService.getTransactionPengeluaranByNoBast(noDoc);

      if (data != null) {
        transaction.value = data;
        _formatDate(data.dateCreated);
        _determineStepFromStatus(data);
      }
    }
    isLoading.value = false;
  }

  void _determineStepFromStatus(TransactionPengeluaranModel? trx) {
    String? status = trx?.status.toLowerCase();

    if (status == null) {
      currentStepId.value = 1;
      _updateStepUI();
      return;
    }

    switch (status) {
      case 'draft':
      case 'pengisian_solar':
      case 'pengisian_solar_pengeluaran':
        currentStepId.value = 1;
        break;

      case 'verifikasi_pengeluaran':
      case 'verifikasi_doc':
        currentStepId.value = 2;
        break;

      case 'approval_kasie':
        currentStepId.value = 3;
        break;

      case 'approval_manager':
        currentStepId.value = 4;
        break;

      case 'selesai':
      case 'approved':
        currentStepId.value = 5;
        break;

      default:
        currentStepId.value = 1;
    }

    _updateStepUI();
  }

  void _updateStepUI() {
    for (var step in steps) {
      if (currentStepId.value == 5) {
        // Jika sudah selesai, semua aktif tapi yang terakhir completed
        step.isCompleted.value = true;
        step.isActive.value = false;
        if(step.id == 5) step.isActive.value = true;
      } else {
        step.isCompleted.value = step.id < currentStepId.value;
        step.isActive.value = step.id == currentStepId.value;
      }
    }
  }

  void backToHome() {
    Get.offAllNamed(Routes.HOME);
  }

  void _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      formattedDate.value = "-";
      return;
    }
    try {
      DateTime date = DateTime.parse(dateString);
      String fullDate = DateFormat('EEEE, dd/MM/yyyy', 'id_ID').format(date);
      formattedDate.value = fullDate;
    } catch (e) {
      formattedDate.value = dateString;
    }
  }
}