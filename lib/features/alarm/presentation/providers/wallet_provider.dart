import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnipro_productivity/core/storage/hive_service.dart';
import 'package:omnipro_productivity/core/services/payment_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

final walletProvider = StateNotifierProvider<WalletNotifier, double>((ref) {
  return WalletNotifier();
});

class WalletNotifier extends StateNotifier<double> {
  WalletNotifier() : super(0.0) {
    _loadBalance();
    _paymentService = PaymentService(
      onSuccess: _onPaymentSuccess,
      onFailure: _onPaymentFailure,
    );
  }

  final _box = HiveService().getBox('wallet');
  late PaymentService _paymentService;
  double _pendingAmount = 0.0;

  void _loadBalance() {
    state = _box.get('balance', defaultValue: 100.0); // Start with 100 as requested or previous balance
  }

  void topUp(double amount) {
    _pendingAmount = amount;
    _paymentService.openCheckout(amount, '9999999999', 'user@example.com');
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) {
    state += _pendingAmount;
    _box.put('balance', state);
    _pendingAmount = 0.0;
  }

  void _onPaymentFailure(PaymentFailureResponse response) {
    _pendingAmount = 0.0;
    // Notify failure if needed via a stream or similar
  }

  void deduct(double amount) {
    state -= amount;
    _box.put('balance', state);
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }
}
