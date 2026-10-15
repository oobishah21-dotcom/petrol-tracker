import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'state/tracker_store.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/gps_status_banner.dart';
import 'widgets/modals/ride_completion_modal.dart';
import 'screens/dashboard_screen.dart';
import 'screens/fuel_entry_screen.dart';
import 'screens/personal_trip_screen.dart';
import 'screens/ride_tracker_screen.dart';
import 'screens/fare_calculator_screen.dart';
import 'screens/history_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DriveSenseApp());
}

class DriveSenseApp extends StatelessWidget {
  const DriveSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DriveSense - Petrol Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainLayoutScreen(),
    );
  }
}

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  final TrackerStore store = TrackerStore.instance;

  @override
  void initState() {
    super.initState();
    store.addListener(_onStoreUpdate);
  }

  @override
  void dispose() {
    store.removeListener(_onStoreUpdate);
    super.dispose();
  }

  void _onStoreUpdate() {
    if (store.showRideCompletionDialog && mounted) {
      // Auto-trigger completion dialog when ride GPS stops
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (store.showRideCompletionDialog && mounted) {
          RideCompletionModal.show(
            context,
            distanceKm: store.completedRideKm,
            onComplete: (earnings, tip) {
              store.completeRideWithEarnings(earnings: earnings, tip: tip);
            },
            onCancel: () {
              store.cancelRideCompletion();
            },
          );
        }
      });
    }
  }

  Widget _buildActiveScreen() {
    switch (store.activeScreen) {
      case 'fuel':
        return FuelEntryScreen(store: store);
      case 'personal':
        return PersonalTripScreen(store: store);
      case 'ride':
        return RideTrackerScreen(store: store);
      case 'calculator':
        return FareCalculatorScreen(store: store);
      case 'history':
        return HistoryScreen(store: store);
      case 'dashboard':
      default:
        return DashboardScreen(store: store);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        return Scaffold(
          body: Stack(
            children: [
              _buildActiveScreen(),
              // Floating GPS Alert Bar
              GpsStatusBanner(
                message: store.gpsMessage,
                isVisible: store.showGpsAlert,
                onDismiss: () => store.dismissAlert(),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavBar(
            activeScreen: store.activeScreen,
            onTabSelected: (tab) => store.setActiveScreen(tab),
          ),
        );
      },
    );
  }
}
