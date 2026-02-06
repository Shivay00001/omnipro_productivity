import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:omnipro_productivity/features/todo/presentation/pages/todo_list_page.dart';
import 'package:omnipro_productivity/features/notes/presentation/pages/notes_list_page.dart';
import 'package:omnipro_productivity/features/expenses/presentation/pages/expense_page.dart';
import 'package:omnipro_productivity/features/habits/presentation/pages/habit_page.dart';
import 'package:omnipro_productivity/features/passwords/presentation/pages/password_list_page.dart';
import 'package:omnipro_productivity/features/journal/presentation/pages/journal_page.dart';
import 'package:omnipro_productivity/features/shopping/presentation/pages/shopping_list_page.dart';
import 'package:omnipro_productivity/features/health/presentation/pages/health_page.dart';
import 'package:omnipro_productivity/features/time_tracker/presentation/pages/time_tracker_page.dart';
import 'package:omnipro_productivity/features/flashcards/presentation/pages/flashcard_page.dart';
import 'package:omnipro_productivity/features/recipes/presentation/pages/recipe_page.dart';
import 'package:omnipro_productivity/features/budget/presentation/pages/budget_page.dart';
import 'package:omnipro_productivity/features/workouts/presentation/pages/workout_page.dart';
import 'package:omnipro_productivity/features/books/presentation/pages/book_page.dart';
import 'package:omnipro_productivity/features/goals/presentation/pages/goal_page.dart';
import 'package:omnipro_productivity/features/alarm/presentation/pages/alarm_page.dart';
import 'package:omnipro_productivity/features/search/presentation/pages/search_page.dart';
import 'package:omnipro_productivity/features/settings/presentation/pages/data_management_page.dart';
import 'package:omnipro_productivity/core/services/report_service.dart';
import 'package:omnipro_productivity/core/providers/auth_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  void _exportWeeklyReport(WidgetRef ref, BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text('Generating PDF Report...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    try {
      final todos = ref.read(todoProvider).where((t) => t.isCompleted).map((t) => t.title).toList();
      final habits = ref.read(habitProvider).map((h) => h.name).toList();
      final expenses = ref.read(expenseProvider).fold(0.0, (sum, e) => sum + e.amount);

      await PDFReportService.generateWeeklyReport(
        todos: todos,
        habits: habits,
        totalExpenses: expenses,
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error generating report: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final modules = [
      ModuleItem('Todo', Icons.check_circle_rounded, const TodoListPage(), Colors.blue, 'Tasks'),
      ModuleItem('Notes', Icons.notes_rounded, const NotesListPage(), Colors.orange, 'Notes'),
      ModuleItem('Expenses', Icons.attach_money_rounded, const ExpensePage(), Colors.green, 'Finance'),
      ModuleItem('Habits', Icons.repeat_rounded, const HabitPage(), Colors.purple, ' Habits'),
      ModuleItem('Passwords', Icons.lock_rounded, const PasswordListPage(), Colors.red, 'Secure'),
      ModuleItem('Journal', Icons.book_rounded, const JournalPage(), Colors.amber, 'Journal'),
      ModuleItem('Shopping', Icons.shopping_cart_rounded, const ShoppingListPage(), Colors.pink, 'List'),
      ModuleItem('Health', Icons.favorite_rounded, const HealthPage(), Colors.teal, 'Health'),
      ModuleItem('Time', Icons.timer_rounded, const TimeTrackerPage(), Colors.indigo, 'Focus'),
      ModuleItem('Flashcards', Icons.style_rounded, const FlashcardPage(), Colors.cyan, 'Study'),
      ModuleItem('Recipes', Icons.restaurant_rounded, const RecipePage(), Colors.deepOrange, 'Cook'),
      ModuleItem('Budgets', Icons.account_balance_rounded, const BudgetPage(), Colors.lime, 'Plan'),
      ModuleItem('Workouts', Icons.fitness_center_rounded, const WorkoutPage(), Colors.brown, 'Fit'),
      ModuleItem('Books', Icons.library_books_rounded, const BookReaderPage(), Colors.blueGrey, 'Read'),
      ModuleItem('Goals', Icons.flag_rounded, const GoalPage(), Colors.lightGreen, 'Achieve'),
      ModuleItem('Alarm', Icons.alarm_rounded, const ExtremeAlarmPage(), Colors.deepPurple, 'Wake'),
    ];

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context, authState, isDarkMode),
            _buildWelcomeHeader(context, authState),
            _buildQuickStats(context, ref),
            _buildModuleGrid(context, modules),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AuthState authState, bool isDarkMode) {
    return SliverAppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OmniPro',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            'Productivity',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.picture_as_pdf_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          tooltip: 'Export Report',
          onPressed: () => _exportWeeklyReport(ref, context),
        ),
        IconButton(
          icon: Icon(
            Icons.search_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          tooltip: 'Search',
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GlobalSearchPage())),
        ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onSelected: (value) {
            if (value == 'settings') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DataManagementPage()));
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'settings', child: Row(children: const [Icon(Icons.settings), SizedBox(width: 8), Text('Settings')])),
          ],
        ),
      ],
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      pinned: true,
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, AuthState authState) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                (authState.username ?? 'U')[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  authState.username ?? 'User',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoProvider);
    final habits = ref.watch(habitProvider);
    final expenses = ref.watch(expenseProvider);
    
    final completedTodos = todos.where((t) => t.isCompleted).length;
    final completedHabits = DateTime.now().day;
    final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _buildStatCard(context, 'Tasks', completedTodos.toString(), todos.length.toString(), Icons.check_circle_rounded, Colors.blue),
            const SizedBox(width: 12),
            _buildStatCard(context, 'Habits', completedHabits.toString(), '${habits.length} total', Icons.repeat_rounded, Colors.purple),
            const SizedBox(width: 12),
            _buildStatCard(context, 'Spent', '\$${totalExpenses.toStringAsFixed(0)}', '${expenses.length} entries', Icons.attach_money_rounded, Colors.green),
          ],
        ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, String subtitle, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 20),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleGrid(BuildContext context, List<ModuleItem> modules) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final module = modules[index];
            return _buildModuleCard(context, module, index);
          },
          childCount: modules.length,
        ),
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, ModuleItem module, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Card(
        elevation: 0,
        color: module.color.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: module.color.withValues(alpha: 0.15)),
        ),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => module.page,
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: module.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    module.icon,
                    color: module.color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  module.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  module.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shield_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  '100% Offline & Private',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ModuleItem {
  final String name;
  final IconData icon;
  final Widget page;
  final Color color;
  final String subtitle;

  ModuleItem(this.name, this.icon, this.page, this.color, this.subtitle);
}
