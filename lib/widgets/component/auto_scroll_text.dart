import 'package:flutter/cupertino.dart';

class AutoScrollText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const AutoScrollText({super.key, required this.text, required this.style});

  @override
  State<AutoScrollText> createState() => _AutoScrollTextState();
}

class _AutoScrollTextState extends State<AutoScrollText> {
  late ScrollController _scrollController;
  bool _isScrolling = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() async {
    // Jeda 1 detik sebelum teks mulai berjalan
    await Future.delayed(const Duration(seconds: 1));

    while (_isScrolling && mounted) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0) {

        // Animasi geser ke ujung kanan (sesuaikan duration untuk kecepatan)
        await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 2500),
          curve: Curves.linear,
        );

        if (!mounted) break;
        // Jeda sejenak saat teks sampai ujung
        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) break;
        // Reset kembali ke posisi awal (kiri) seketika
        _scrollController.jumpTo(0);

        // Jeda sebelum mengulang jalan lagi
        await Future.delayed(const Duration(seconds: 1));
      } else {
        // Jika teks muat (tidak overflow), cek lagi tiap 2 detik
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  @override
  void dispose() {
    _isScrolling = false;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Matikan scroll manual agar tidak bentrok dengan tap dropdown
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Text(
        widget.text,
        style: widget.style,
      ),
    );
  }
}