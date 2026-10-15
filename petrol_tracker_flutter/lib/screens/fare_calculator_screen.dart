import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../state/tracker_store.dart';

class FareCalculatorScreen extends StatefulWidget {
  final TrackerStore store;

  const FareCalculatorScreen({super.key, required this.store});

  @override
  State<FareCalculatorScreen> createState() => _FareCalculatorScreenState();
}

class _FareCalculatorScreenState extends State<FareCalculatorScreen> {
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _offerController = TextEditingController();
  final TextEditingController _myPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _kmController.text = widget.store.calcKm;
    _offerController.text = widget.store.calcOffer;
    _myPriceController.text = widget.store.calcMyPrice;
  }

  void _calculate() {
    final km = double.tryParse(_kmController.text.trim());
    final offer = double.tryParse(_offerController.text.trim());
    final myPrice = double.tryParse(_myPriceController.text.trim());

    if (km == null || km <= 0) {
      widget.store.showToastMessage('❌ Please enter a valid distance in km', isError: true);
      return;
    }
    if (offer == null || offer < 0) {
      widget.store.showToastMessage('❌ Please enter the customer offer price', isError: true);
      return;
    }

    widget.store.calcKm = _kmController.text.trim();
    widget.store.calcOffer = _offerController.text.trim();
    widget.store.calcMyPrice = _myPriceController.text.trim();

    widget.store.runFareCalculation(
      km: km,
      offerPrice: offer,
      myPrice: myPrice,
    );
  }

  void _clear() {
    _kmController.clear();
    _offerController.clear();
    _myPriceController.clear();
    widget.store.clearFareCalculator();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.store.fareResult;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Fare Profit Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (result != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.outline),
              tooltip: 'Clear Inputs',
              onPressed: _clear,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Input Form Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('RIDE DISTANCE (KM)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                TextField(
                  controller: _kmController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: 'e.g. 14.5',
                    suffixText: 'km',
                    prefixIcon: Icon(Icons.straighten_rounded, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('PASSENGER OFFER (RS.)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                TextField(
                  controller: _offerController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: 'e.g. 380',
                    suffixText: 'Rs',
                    prefixIcon: Icon(Icons.payments_rounded, color: AppColors.secondary),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('MY COUNTER OFFER (RS. OPTIONAL)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                TextField(
                  controller: _myPriceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: 'e.g. 450',
                    suffixText: 'Rs',
                    prefixIcon: Icon(Icons.price_check_rounded, color: AppColors.tertiary),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _calculate,
                  child: const Center(
                    child: Text('CALCULATE PROFIT MARGIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Result Card
          if (result != null) ...[
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF19202E), Color(0xFF151B2A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: result.offerProfitPerKm >= 20 ? AppColors.primaryContainer : AppColors.errorContainer,
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PASSENGER OFFER RESULT',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: AppColors.onSurfaceVariant),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: result.offerProfitPerKm >= 20
                              ? AppColors.primary.withOpacity(0.15)
                              : AppColors.coralRed.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          result.offerProfitPerKm >= 25
                              ? '⭐ Great Fare'
                              : result.offerProfitPerKm >= 15
                                  ? '👍 Acceptable'
                                  : '⚠️ Low Margin',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: result.offerProfitPerKm >= 20 ? AppColors.primary : AppColors.coralRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rs. ${result.offerProfit.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: result.offerProfit > 0 ? AppColors.primary : AppColors.coralRed,
                            ),
                          ),
                          const Text('Estimated Net Profit', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rs. ${result.offerProfitPerKm.toStringAsFixed(1)}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.secondary),
                          ),
                          const Text('Net Profit / KM', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0x1AFFFFFF)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Fuel Cost (${result.fuelUsed.toStringAsFixed(2)} L)', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                      Text('Rs. ${result.fuelCost.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.coralRed, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Operating Cost per KM', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                      Text('Rs. ${result.costPerKm.toStringAsFixed(1)} / km', style: const TextStyle(color: AppColors.onSurface, fontSize: 13)),
                    ],
                  ),

                  // Counter Offer Comparison if entered
                  if (result.myPrice > 0) ...[
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.tertiary.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('IF COUNTER OFFER ACCEPTED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: AppColors.tertiary)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Rs. ${result.myProfit.toStringAsFixed(0)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.tertiary),
                                  ),
                                  const Text('Profit with Counter', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '+Rs. ${result.profitDifference.toStringAsFixed(0)} extra',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                                  ),
                                  Text('Rs. ${result.myProfitPerKm.toStringAsFixed(1)}/km', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
