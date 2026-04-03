import 'package:flutter/material.dart';
import 'package:financeapp/core/app_color.dart';

// ── Sample model ────────────────────────────────────────────────────────────
class _Transaction {
  final String title;
  final String category;
  final double amount;
  final bool isIncome;
  final DateTime date;
  final IconData icon;

  const _Transaction({
    required this.title,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.date,
    required this.icon,
  });
}

final _sampleTransactions = [
  _Transaction(
    title: 'Salary',
    category: 'Income',
    amount: 85000,
    isIncome: true,
    date: DateTime(2026, 4, 1),
    icon: Icons.account_balance_wallet_rounded,
  ),
  _Transaction(
    title: 'Rent',
    category: 'Housing',
    amount: 22000,
    isIncome: false,
    date: DateTime(2026, 4, 1),
    icon: Icons.home_rounded,
  ),
  _Transaction(
    title: 'Groceries',
    category: 'Food',
    amount: 3450,
    isIncome: false,
    date: DateTime(2026, 3, 31),
    icon: Icons.shopping_cart_rounded,
  ),
  _Transaction(
    title: 'Freelance Project',
    category: 'Income',
    amount: 12000,
    isIncome: true,
    date: DateTime(2026, 3, 30),
    icon: Icons.laptop_mac_rounded,
  ),
  _Transaction(
    title: 'Electric Bill',
    category: 'Utilities',
    amount: 1800,
    isIncome: false,
    date: DateTime(2026, 3, 29),
    icon: Icons.bolt_rounded,
  ),
  _Transaction(
    title: 'Restaurant',
    category: 'Food',
    amount: 980,
    isIncome: false,
    date: DateTime(2026, 3, 28),
    icon: Icons.restaurant_rounded,
  ),
];



// ── HomeView ─────────────────────────────────────────────────────────────────
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  double get _totalIncome => _sampleTransactions
      .where((t) => t.isIncome)
      .fold(0, (s, t) => s + t.amount);

  double get _totalExpense => _sampleTransactions
      .where((t) => !t.isIncome)
      .fold(0, (s, t) => s + t.amount);

  double get _balance => _totalIncome - _totalExpense;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(child: _buildBalanceCard()),
            SliverToBoxAdapter(child: _buildSummaryRow()),
            SliverToBoxAdapter(
              child: _buildSectionTitle('Recent Transactions'),
            ),
            _buildTransactionList(),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColor.bg,
      expandedHeight: 72,
      floating: true,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColor.primary, Color(0xFF9B6BFF)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_graph_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'My Ledger',
              style: TextStyle(
                color: AppColor.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        expandedTitleScale: 1.0,
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColor.textSecondary,
          ),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColor.card,
            child: const Icon(
              Icons.person_rounded,
              color: AppColor.accentLight,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  // ── Balance card ──────────────────────────────────────────────────────────
  Widget _buildBalanceCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4B3FC0), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColor.primary.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Balance',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${_formatAmount(_balance)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildMiniStat(
                  Icons.arrow_downward_rounded,
                  'Income',
                  '₹${_formatAmount(_totalIncome)}',
                  AppColor.green,
                ),
                const SizedBox(width: 20),
                _buildMiniStat(
                  Icons.arrow_upward_rounded,
                  'Expenses',
                  '₹${_formatAmount(_totalExpense)}',
                  const Color(0xFFFF8FA3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Summary chips ─────────────────────────────────────────────────────────
  Widget _buildSummaryRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _SummaryChip(
              label: 'Income',
              value: '₹${_formatAmount(_totalIncome)}',
              icon: Icons.trending_up_rounded,
              color: AppColor.green,
              bgColor: AppColor.green.withValues(alpha: 0.12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryChip(
              label: 'Expenses',
              value: '₹${_formatAmount(_totalExpense)}',
              icon: Icons.trending_down_rounded,
              color: AppColor.red,
              bgColor: AppColor.red.withValues(alpha: 0.12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryChip(
              label: 'Savings',
              value: '${((_balance / _totalIncome) * 100).toStringAsFixed(0)}%',
              icon: Icons.savings_rounded,
              color: AppColor.accentLight,
              bgColor: AppColor.primary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section title ─────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColor.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Text(
              'See all',
              style: TextStyle(
                color: AppColor.accentLight,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Transaction list ──────────────────────────────────────────────────────
  Widget _buildTransactionList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final t = _sampleTransactions[index];
        return _TransactionTile(transaction: t);
      }, childCount: _sampleTransactions.length),
    );
  }

  // ── FAB ───────────────────────────────────────────────────────────────────
  Widget _buildFAB() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 56,
      child: Row(
        children: [
          Expanded(
            child: _FabButton(
              label: 'Add Income',
              icon: Icons.add_circle_rounded,
              color: AppColor.green,
              onTap: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _FabButton(
              label: 'Add Expense',
              icon: Icons.remove_circle_rounded,
              color: AppColor.red,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

// ── Reusable Widgets ──────────────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.card, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: AppColor.textSecondary,
              fontSize: 11,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final _Transaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final color = transaction.isIncome ? AppColor.green : AppColor.red;
    final sign = transaction.isIncome ? '+' : '-';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.card, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(transaction.icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(
                      color: AppColor.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${transaction.category} · ${_formatDate(transaction.date)}',
                    style: const TextStyle(color: AppColor.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              '$sign₹${_fmtAmt(transaction.amount)}',
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}';
  }

  String _fmtAmt(double amount) {
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }
}

class _FabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FabButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
