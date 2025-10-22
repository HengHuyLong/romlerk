// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:romlerk/core/theme/app_colors.dart';
import 'package:romlerk/core/theme/app_typography.dart';
import 'package:romlerk/data/services/payment_service.dart';
import 'package:romlerk/core/providers/navigation_provider.dart';
import 'package:romlerk/core/providers/slot_provider.dart'; // ✅ added
import 'package:url_launcher/url_launcher_string.dart';

class PaymentConfirmScreen extends ConsumerStatefulWidget {
  final String planName;
  final String planPrice;

  const PaymentConfirmScreen({
    super.key,
    required this.planName,
    required this.planPrice,
  });

  @override
  ConsumerState<PaymentConfirmScreen> createState() =>
      _PaymentConfirmScreenState();
}

class _PaymentConfirmScreenState extends ConsumerState<PaymentConfirmScreen> {
  bool _isLoading = false;
  Timer? _pollTimer;

  Future<void> _createPayment() async {
    setState(() => _isLoading = true);

    try {
      final double amount =
          double.tryParse(widget.planPrice.replaceAll(RegExp(r'[^\d.]'), '')) ??
              0.0;
      final tranId = DateTime.now().millisecondsSinceEpoch.toString();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError('User not logged in.');
        return;
      }

      final responseData = await PaymentService.createPayment(
        tranId: tranId,
        amount: amount,
        uid: user.uid,
        planName: widget.planName,
      );

      if (responseData == null) {
        _showError('Payment setup failed — no response from backend.');
        return;
      }

      final qrImg = responseData['qrImage'];
      final abaLink = responseData['abapay_deeplink'] ??
          responseData['data']?['abapay_deeplink'];

      if (qrImg == null || qrImg.toString().isEmpty) {
        _showError('QR image missing in response.');
        return;
      }

      _showQrBottomSheet(qrImg, abaLink, tranId, responseData);
    } catch (e) {
      _showError('Error connecting to backend: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  // 🔁 Poll backend for payment status
  void _startPolling(String tranId) {
    _pollTimer?.cancel();
    int attempts = 0;

    _pollTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          timer.cancel();
          return;
        }

        attempts++;
        if (attempts > 20) {
          timer.cancel();
          if (mounted) {
            Navigator.of(context).pop();
            _showError("⏳ Payment timeout. Please try again.");
          }
          return;
        }

        final url =
            'https://romlerk-backend.onrender.com/payment/callback/status/$tranId?uid=${user.uid}';
        final res = await http.get(Uri.parse(url));

        if (res.statusCode == 200) {
          final body = jsonDecode(res.body);
          final data = body['data'] ?? {};
          final status = data['status'];
          final statusStr = status.toString();

          if (statusStr == "0") {
            timer.cancel();
            if (mounted) {
              Navigator.of(context).pop();
              _showSuccessDialog(
                  "Your payment for ${widget.planName} was successful!");
            }
          } else if (statusStr == "2" ||
              statusStr == "fail" ||
              statusStr == "failed") {
            timer.cancel();
            if (mounted) {
              Navigator.of(context).pop();
              _showError("❌ Payment Failed.");
            }
          }
        }
      } catch (_) {}
    });
  }

  // ✅ Success dialog (with slot update logic)
  void _showSuccessDialog(String message) async {
    int addCount = 0;

    // ✅ Detect which plan was purchased
    if (widget.planName.contains('5')) {
      addCount = 5;
    } else if (widget.planName.contains('10')) {
      addCount = 10;
    } else if (widget.planName.contains('20')) {
      addCount = 20;
    }

    // ✅ Update Firestore slots via backend
    if (addCount > 0) {
      await ref.read(slotProvider.notifier).addSlots(addCount);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.green, size: 70),
            const SizedBox(height: 16),
            Text(
              "Payment Successful",
              textAlign: TextAlign.center,
              style: AppTypography.bodyBold.copyWith(
                color: AppColors.black,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: AppColors.black,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(navIndexProvider.notifier).state = 1;
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  "Done",
                  style: AppTypography.bodyBold.copyWith(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🖼️ QR sheet with only ABA deeplink
  void _showQrBottomSheet(
    String? qrImageBase64,
    String? abaLink,
    String tranId,
    Map<String, dynamic> data,
  ) {
    if (qrImageBase64 == null || qrImageBase64.isEmpty) {
      _showError('QR image not received from backend.');
      return;
    }

    try {
      final raw = qrImageBase64;
      final base64Part = raw.contains(',') ? raw.split(',').last : raw;
      final normalized = base64.normalize(base64Part);
      final imageBytes = base64Decode(normalized);

      _startPolling(tranId);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Text(
                  'Scan to Pay',
                  style: AppTypography.bodyBold.copyWith(
                    fontSize: 18,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(imageBytes, width: 400, height: 400),
                ),
                const SizedBox(height: 16),
                Text(
                  'Use ABA Mobile to scan this QR code\nor open ABA directly below.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: AppColors.darkGray,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.open_in_new_rounded,
                        color: Colors.white),
                    label: const Text(
                      'Open in ABA App',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        final deeplink =
                            abaLink ?? data['abapay_deeplink'] ?? '';
                        if (deeplink.isNotEmpty) {
                          await launchUrlString(
                            deeplink,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          _showError('ABA deeplink not found.');
                        }
                      } catch (_) {
                        _showError('Unable to open ABA app.');
                      }
                    },
                  ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Done',
                    style: TextStyle(color: AppColors.green),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      _showError('Error decoding QR image: $e');
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Checkout',
          style: AppTypography.bodyBold
              .copyWith(color: AppColors.black, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Summary',
                style: AppTypography.bodyBold
                    .copyWith(color: AppColors.black, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _invoiceRow('Plan', widget.planName),
                  const Divider(height: 20, color: Color(0xFFE0E0E0)),
                  _invoiceRow('Price', widget.planPrice),
                  _invoiceRow('Tax (0%)', '\$0.00'),
                  const Divider(height: 20, color: Color(0xFFE0E0E0)),
                  _invoiceRow('Total', widget.planPrice, isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text('Payment Method',
                style: AppTypography.bodyBold
                    .copyWith(color: AppColors.black, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset('assets/images/aba.jpg',
                        height: 32, width: 32),
                  ),
                  const SizedBox(width: 14),
                  Text('ABA Pay',
                      style: AppTypography.body
                          .copyWith(fontSize: 16, color: AppColors.black)),
                  const Spacer(),
                  const Icon(Icons.check_circle, color: AppColors.green),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text('Pay Now',
                        style: AppTypography.bodyBold
                            .copyWith(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _invoiceRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTypography.body
                  .copyWith(fontSize: 14, color: AppColors.black)),
          Text(
            value,
            style: isBold
                ? AppTypography.bodyBold
                    .copyWith(fontSize: 14, color: AppColors.black)
                : AppTypography.body
                    .copyWith(fontSize: 14, color: AppColors.black),
          ),
        ],
      ),
    );
  }
}
