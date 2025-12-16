import 'package:lottie/lottie.dart';
import '../configs/app_lotties.dart';

class LottiesHelper{
  LottieBuilder getLottieConfirmation() {
    final lottieLogo = Lottie.asset(
      AppLotties.confirmation,
      width: 150,
      height: 100,
      repeat: true,
    );

    return lottieLogo;
  }

  LottieBuilder getLottieVerification() {
    final lottieLogo = Lottie.asset(
      AppLotties.verification,
      width: 150,
      height: 100,
      repeat: true,
    );

    return lottieLogo;
  }

  LottieBuilder getLottieQuestion() {
    final lottieLogo = Lottie.asset(
      AppLotties.question,
      width: 150,
      height: 100,
      repeat: true,
    );

    return lottieLogo;
  }

  LottieBuilder getLottieFailed() {
    final lottieLogo = Lottie.asset(
      AppLotties.failed,
      width: 150,
      height: 100,
      repeat: true,
    );

    return lottieLogo;
  }

  LottieBuilder getLottieSuccess() {
    final lottieLogo = Lottie.asset(
      AppLotties.success,
      width: 150,
      height: 100,
      repeat: true,
    );

    return lottieLogo;
  }

  LottieBuilder getLottieOnDevelopment() {
    final lottieLogo = Lottie.asset(
      AppLotties.onDevelopment,
      width: 150,
      height: 100,
      repeat: true,
    );

    return lottieLogo;
  }

  LottieBuilder getLottieFuel() {
    final lottieLogo = Lottie.asset(
      AppLotties.loading,
      width: 150,
      height: 100,
      repeat: true,
    );

    return lottieLogo;
  }

  LottieBuilder getLottieFuelPengeluaran() {
    final lottieLogo = Lottie.asset(
      AppLotties.loadingPengeluaran,
      width: 150,
      height: 100,
      repeat: true,
    );

    return lottieLogo;
  }
}
