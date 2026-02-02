import 'dart:io';
import 'package:doova/provider/monetizing/user_provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseService {
  static  final String _subscriptionId = Platform.isAndroid
      ? 'doova_premium_android'
      : 'doova_premium_ios';

  final InAppPurchase _iap = InAppPurchase.instance;

  Future<void> initialize() async {
    final available = await _iap.isAvailable();
    if (!available) {
      throw Exception("In-App Purchase not available on this device.");
    }
  }

  Future<void> buyPremium(String uid, UserProvider provider) async {
    final productDetailsResponse = await _iap.queryProductDetails({_subscriptionId});
    if (productDetailsResponse.notFoundIDs.isNotEmpty) {
      throw Exception("Subscription not found");
    }

    final productDetails = productDetailsResponse.productDetails.first;
    final purchaseParam = PurchaseParam(productDetails: productDetails);

    _iap.buyNonConsumable(purchaseParam: purchaseParam);

    // You'd normally handle purchase updates via listener. For demo, upgrade directly.
    await provider.upgradeToPremium(uid);
  }
}
