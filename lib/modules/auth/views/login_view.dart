import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../configs/app_fonts.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  Widget _buildUsernameField() {
    const borderSide = BorderSide(color: AppColors.primary, width: 1.5);

    return TextFormField(
      controller: controller.usernameController,
      keyboardType: TextInputType.name,
      validator: controller.validateUsername,
      decoration: InputDecoration(
        hintText: 'Username',
        hintStyle: AppFonts.fUrbanistLight12,
        prefixIcon: const Icon(Icons.person_outline, color: AppColors.secondaryText),
        filled: true,
        fillColor: AppColors.fieldBackground,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: borderSide,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.secondaryText.withOpacity(0.5), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: borderSide,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    const borderSide = BorderSide(color: AppColors.primary, width: 1.5);

    return Obx(
          () => TextFormField(
        controller: controller.passwordController,
        obscureText: controller.isPasswordHidden.value,
        validator: controller.validatePassword,
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: AppFonts.fUrbanistLight12,
          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.secondaryText),
          filled: true,
          fillColor: AppColors.fieldBackground,
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: borderSide,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.secondaryText.withOpacity(0.5), width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: borderSide,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              controller.isPasswordHidden.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.secondaryText,
            ),
            onPressed: controller.togglePasswordVisibility,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Obx(
          () => SizedBox(
        height: 50, // Sedikit diperbesar agar lebih nyaman di tap pada semua HP
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: controller.isLoading.value ? null : controller.login,
          child: controller.isLoading.value
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(color: Colors.white),
          )
              : Text(
            'Login',
            style: AppFonts.fUrbanistBold16.copyWith( // Font disesuaikan
                color: AppColors.white // Pastikan warna font kontras
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil tinggi layar untuk membuat ukuran gambar responsif
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white, // Pastikan background putih konsisten
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                // Memaksa konten minimal setinggi layar yang tersedia
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: controller.loginFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Spacer atas untuk mendorong konten ke tengah
                          const Spacer(flex: 2),

                          // Gambar dengan tinggi responsif (maksimal 22% dari layar)
                          Image.asset(
                            AppImages.bgLoginFuel,
                            height: screenHeight * 0.22,
                          ),
                          const SizedBox(height: 16),

                          Text(
                            'e-Fuel Mobile',
                            textAlign: TextAlign.center,
                            style: AppFonts.fUrbanistBold24.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                          Text(
                            'Fuel Management System',
                            textAlign: TextAlign.center,
                            style: AppFonts.fUrbanistMedium16.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),

                          const SizedBox(height: 32),

                          _buildUsernameField(),
                          const SizedBox(height: 16),

                          _buildPasswordField(),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: controller.forgotPassword,
                              child: Text(
                                'Lupa Password?',
                                style: AppFonts.fUrbanistSemiBold12.copyWith(
                                    color: AppColors.primary
                                ),
                              ),
                            ),
                          ),

                          // Spacer bawah untuk menekan tombol login ke paling bawah layar
                          const Spacer(flex: 3),

                          _buildLoginButton(),

                          // Jarak aman di bawah tombol login
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}