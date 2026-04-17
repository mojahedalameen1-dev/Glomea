import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:async';
import 'package:kidneytrack_mobile/core/services/food_nutrition_service.dart';
import 'package:kidneytrack_mobile/core/models/food_item.dart';
import 'package:kidneytrack_mobile/core/theme/app_colors.dart';
import 'package:kidneytrack_mobile/features/potassium_scanner/widgets/kidney_result_modal.dart';
import 'package:kidneytrack_mobile/l10n/app_localizations.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(formats: const [BarcodeFormat.all]);
  final FoodNutritionService _foodService = FoodNutritionService();

  bool _scanned = false;
  bool _isLoading = false;

  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanLineAnimation = Tween<double>(begin: 0, end: 1)
      .animate(CurvedAnimation(
        parent: _scanLineController,
        curve: Curves.easeInOut));
  }


  @override
  void dispose() {
    _scanLineController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) => _onBarcodeDetected(capture, l10n),
          ),
          _buildScanOverlay(),
          _buildAnimatedFrame(),
          _buildTopBar(l10n),
          _buildBottomHint(l10n),
          if (_isLoading) _buildLoadingOverlay(l10n),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Colors.black.withValues(alpha: 0.55),
        BlendMode.srcOut,
      ),
      child: Stack(
        children: [
          Container(decoration: const BoxDecoration(
            color: Colors.black,
            backgroundBlendMode: BlendMode.dstOut)),
          Center(
            child: Container(
              width: 280, height: 160,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16))),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedFrame() {
    return Center(
      child: SizedBox(
        width: 280, height: 160,
        child: Stack(
          children: [
            ..._buildCorners(),
            AnimatedBuilder(
              animation: _scanLineAnimation,
              builder: (_, __) => Positioned(
                top: _scanLineAnimation.value * 140 + 10,
                left: 10, right: 10,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.transparent,
                      AppColors.primary.withValues(alpha: 0.8),
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                      Colors.transparent,
                    ]),
                    boxShadow: [BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      blurRadius: 6, spreadRadius: 2)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCorners() {
    const s = 24.0; const t = 3.0;
    const c = AppColors.primary;
    const r = Radius.circular(4);
    return [
      Positioned(top:0,left:0, child:Container(width:s,height:t,
        decoration:const BoxDecoration(color:c,
          borderRadius:BorderRadius.only(topLeft:r)))),
      Positioned(top:0,left:0, child:Container(width:t,height:s,
        decoration:const BoxDecoration(color:c,
          borderRadius:BorderRadius.only(topLeft:r)))),
      Positioned(top:0,right:0, child:Container(width:s,height:t,
        decoration:const BoxDecoration(color:c,
          borderRadius:BorderRadius.only(topRight:r)))),
      Positioned(top:0,right:0, child:Container(width:t,height:s,
        decoration:const BoxDecoration(color:c,
          borderRadius:BorderRadius.only(topRight:r)))),
      Positioned(bottom:0,left:0, child:Container(width:s,height:t,
        decoration:const BoxDecoration(color:c,
          borderRadius:BorderRadius.only(bottomLeft:r)))),
      Positioned(bottom:0,left:0, child:Container(width:t,height:s,
        decoration:const BoxDecoration(color:c,
          borderRadius:BorderRadius.only(bottomLeft:r)))),
      Positioned(bottom:0,right:0, child:Container(width:s,height:t,
        decoration:const BoxDecoration(color:c,
          borderRadius:BorderRadius.only(bottomRight:r)))),
      Positioned(bottom:0,right:0, child:Container(width:t,height:s,
        decoration:const BoxDecoration(color:c,
          borderRadius:BorderRadius.only(bottomRight:r)))),
    ];
  }

  Widget _buildTopBar(AppLocalizations l10n) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () async {
                final nav = Navigator.of(context);
                await _controller.dispose();
                nav.pop();
              },
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),

            Text(l10n.scanBarcode,
              style: const TextStyle(color: Colors.white,
                fontSize: 18, fontWeight: FontWeight.bold)),
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (_, state, __) => IconButton(
                onPressed: () => _controller.toggleTorch(),
                icon: Icon(
                  state.torchState == TorchState.on
                    ? Icons.flash_on : Icons.flash_off,
                  color: state.torchState == TorchState.on
                    ? Colors.yellow : Colors.white))),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomHint(AppLocalizations l10n) {
    return Positioned(
      bottom: 60, left: 0, right: 0,
      child: Column(
        children: [
          Text(l10n.pointCameraAtBarcode,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => _showManualEntryDialog(l10n),
            icon: const Icon(Icons.keyboard,
              color: Colors.white54, size: 18),
            label: Text(l10n.manualBarcodeEntry,
              style: const TextStyle(color: Colors.white54, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay(AppLocalizations l10n) => Container(
    color: Colors.black54,
    child: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const CircularProgressIndicator(color: AppColors.primary),
        const SizedBox(height: 16),
        Text(l10n.analyzingProduct,
          style: const TextStyle(color: Colors.white, fontSize: 16)),
      ]),
    ),
  );

  Future<void> _onBarcodeDetected(BarcodeCapture capture, AppLocalizations l10n) async {
    if (_scanned || _isLoading) return;
    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null) return;
    _scanned = true;
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();
    await _controller.stop();
    try {
      final product = await _foodService.getByBarcode(barcode);
      if (!mounted) return;
      if (product != null) {
        HapticFeedback.lightImpact();
        _showKidneyResultSheet(product);
      } else {
        _showProductNotFound(barcode, l10n);
      }
    } catch (e) {
      _showErrorSnackbar(l10n);
    } finally {
      if (mounted) setState(() => _isLoading = false);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) { _scanned = false; await _controller.start(); }
    }
  }

  void _showProductNotFound(String barcode, AppLocalizations l10n) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.productNotFound(barcode))));
  }

  void _showErrorSnackbar(AppLocalizations l10n) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorSearching)));
  }

  void _showManualEntryDialog(AppLocalizations l10n) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(l10n.enterBarcodeNumber),
      content: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: l10n.barcodeExample,
          prefixIcon: const Icon(Icons.qr_code))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel)),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            if (ctrl.text.isNotEmpty) {
              _onBarcodeDetected(BarcodeCapture(
                barcodes: [Barcode(rawValue: ctrl.text)]), l10n);
            }
          },
          child: Text(l10n.search)),
      ],
    ));
  }

  void _showKidneyResultSheet(FoodItem product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => KidneyResultModal(food: product),
    );
  }

}
