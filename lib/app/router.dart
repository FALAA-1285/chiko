import 'package:go_router/go_router.dart';

import '../core/widgets/app_shell.dart';
import '../features/calendar/ui/calendar_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/finance/ui/add_transaction_page.dart';
import '../features/finance/ui/finance_page.dart';
import '../features/onboarding/sambutan_page.dart';
import '../features/settings/settings_page.dart';
import '../features/tasks/ui/task_list_page.dart';

GoRouter createRouter({required String initialLocation}) => GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(path: '/sambutan', builder: (context, state) => const SambutanPage()),
        // Layar penuh di atas navigasi bawah.
        GoRoute(path: '/tambah-transaksi', builder: (context, state) => const AddTransactionPage()),
        GoRoute(
          path: '/transaksi/:id',
          builder: (context, state) => AddTransactionPage(editId: int.tryParse(state.pathParameters['id'] ?? '')),
        ),
        // 5 tab dengan navigasi bawah. Tiap tab menyimpan posisinya sendiri.
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(path: '/beranda', builder: (context, state) => const DashboardPage()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/tugas', builder: (context, state) => const TaskListPage()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/kalender', builder: (context, state) => const CalendarPage()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/keuangan', builder: (context, state) => const FinancePage()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/pengaturan', builder: (context, state) => const SettingsPage()),
            ]),
          ],
        ),
      ],
    );
