import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// =============================================================================
// THEME COLORS
// =============================================================================

const kPrimary = Color(0xFF8B2CF5);
const kPrimary900 = Color(0xFF3B0F8C);
const kPrimary700 = Color(0xFF6A1FC2);
const kPrimary400 = Color(0xFFAB65F7);
const kPrimary200 = Color(0xFFD9B8FC);
const kPrimary100 = Color(0xFFEFDEFE);
const kPrimary50 = Color(0xFFF8F2FF);

// =============================================================================
// MODEL
// =============================================================================

class Transaction {
  final String date;
  final String time;
  final String title;
  final String branch;
  final String txId;
  final double amount;
  final IconData icon;
  final String status; // 'Paid' | 'Pending' | 'Processing'

  const Transaction({
    required this.date,
    required this.time,
    required this.title,
    required this.branch,
    required this.txId,
    required this.amount,
    required this.icon,
    this.status = 'Paid',
  });
}

// =============================================================================
// MOCK DATA  — keyed by "yyyy-MM-dd"
// =============================================================================

final Map<String, List<Transaction>> mockData = {
  // ── May 1 ──
  '2025-05-01': [
    Transaction(
      date: 'May 1, 2025',
      time: '8:00 AM',
      title: 'Barangay Clearance',
      branch: 'Brgy. San Isidro',
      txId: '20250501001',
      amount: 120,
      icon: Icons.description_outlined,
    ),
    Transaction(
      date: 'May 1, 2025',
      time: '10:30 AM',
      title: 'Community Tax Certificate',
      branch: 'Brgy. San Isidro',
      txId: '20250501002',
      amount: 50,
      icon: Icons.receipt_long_outlined,
      status: 'Pending',
    ),
  ],

  // ── May 5 ──
  '2025-05-05': [
    Transaction(
      date: 'May 5, 2025',
      time: '9:00 AM',
      title: 'Business Permit',
      branch: 'Brgy. San Isidro',
      txId: '20250505001',
      amount: 500,
      icon: Icons.store_outlined,
      status: 'Processing',
    ),
  ],

  // ── May 10 ──
  '2025-05-10': [
    Transaction(
      date: 'May 10, 2025',
      time: '1:15 PM',
      title: 'Police Clearance',
      branch: 'Brgy. San Isidro',
      txId: '20250510001',
      amount: 150,
      icon: Icons.shield_outlined,
    ),
    Transaction(
      date: 'May 10, 2025',
      time: '2:00 PM',
      title: 'Barangay ID',
      branch: 'Brgy. San Isidro',
      txId: '20250510002',
      amount: 80,
      icon: Icons.badge_outlined,
    ),
    Transaction(
      date: 'May 10, 2025',
      time: '3:30 PM',
      title: 'Certificate of Residency',
      branch: 'Brgy. San Isidro',
      txId: '20250510003',
      amount: 60,
      icon: Icons.home_outlined,
      status: 'Pending',
    ),
  ],

  // ── May 15 ──
  '2025-05-15': [
    Transaction(
      date: 'May 15, 2025',
      time: '8:45 AM',
      title: 'Certificate of Indigency',
      branch: 'Brgy. San Isidro',
      txId: '20250515001',
      amount: 60,
      icon: Icons.person_outline,
    ),
  ],

  // ── May 20 ──
  '2025-05-20': [
    Transaction(
      date: 'May 20, 2025',
      time: '10:00 AM',
      title: 'Barangay Clearance',
      branch: 'Brgy. San Isidro',
      txId: '20250520001',
      amount: 120,
      icon: Icons.description_outlined,
    ),
    Transaction(
      date: 'May 20, 2025',
      time: '11:30 AM',
      title: 'Good Moral Certificate',
      branch: 'Brgy. San Isidro',
      txId: '20250520002',
      amount: 75,
      icon: Icons.workspace_premium_outlined,
      status: 'Processing',
    ),
  ],

  // ── May 25 ──
  '2025-05-25': [
    Transaction(
      date: 'May 25, 2025',
      time: '9:20 AM',
      title: 'Solo Parent ID',
      branch: 'Brgy. San Isidro',
      txId: '20250525001',
      amount: 0,
      icon: Icons.family_restroom_outlined,
    ),
    Transaction(
      date: 'May 25, 2025',
      time: '2:45 PM',
      title: 'Business Permit Renewal',
      branch: 'Brgy. San Isidro',
      txId: '20250525002',
      amount: 800,
      icon: Icons.store_outlined,
      status: 'Pending',
    ),
  ],

  // ── May 28 ──
  '2025-05-28': [
    Transaction(
      date: 'May 28, 2025',
      time: '7:55 AM',
      title: 'Police Clearance',
      branch: 'Brgy. San Isidro',
      txId: '20250528001',
      amount: 150,
      icon: Icons.shield_outlined,
    ),
  ],
};

// Returns transactions for a given date, or empty list if none.
List<Transaction> getTransactionsForDate(DateTime date) {
  final key = DateFormat('yyyy-MM-dd').format(date);
  return mockData[key] ?? [];
}

// Returns true if a date has transactions (used to highlight calendar dots).
bool hasTransactions(DateTime date) {
  final key = DateFormat('yyyy-MM-dd').format(date);
  return mockData.containsKey(key);
}

// =============================================================================
// MAIN
// =============================================================================

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'SF Pro Display'),
      home: const TrackingServicesRequestPage(),
    );
  }
}

// =============================================================================
// PAGE
// =============================================================================

class TrackingServicesRequestPage extends StatefulWidget {
  const TrackingServicesRequestPage({super.key});

  @override
  State<TrackingServicesRequestPage> createState() =>
      _TrackingServicesRequestPageState();
}

class _TrackingServicesRequestPageState
    extends State<TrackingServicesRequestPage> {
  late DateTime _focusedMonth;
  late DateTime _selectedDay;

  // Transactions shown in the list — updates when user taps a date.
  List<Transaction> _visibleTransactions = [];

  @override
  void initState() {
    super.initState();
    // Default: open on May 2025
    _focusedMonth = DateTime(2025, 5);
    _selectedDay = DateTime(2025, 5, 10); // pre-select a date with data
    _visibleTransactions = getTransactionsForDate(_selectedDay);
  }

  // Called when user taps a calendar day.
  void _onDayTapped(DateTime date) {
    setState(() {
      _selectedDay = date;
      _visibleTransactions = getTransactionsForDate(date);
    });
  }

  void _changeMonth(int offset) {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + offset,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimary50,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // ── TOP: Purple calendar (fixed, does NOT scroll) ──
          _buildCalendarSection(),

          // ── BOTTOM: Recent activity (scrollable) ──
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: kPrimary50,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: _ActivitySection(
                  selectedDay: _selectedDay,
                  transactions: _visibleTransactions,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Track Request',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      centerTitle: true,
      backgroundColor: kPrimary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 18,
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  // ---------------------------------------------------------------------------

  Widget _buildCalendarSection() {
    return Container(
      decoration: const BoxDecoration(color: kPrimary),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMonthSelector(),
          const SizedBox(height: 10),
          _buildWeekdayHeader(),
          const SizedBox(height: 4),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('MMMM yyyy').format(_focusedMonth),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        Row(
          children: [
            _NavButton(
              icon: Icons.chevron_left_rounded,
              onTap: () => _changeMonth(-1),
            ),
            const SizedBox(width: 6),
            _NavButton(
              icon: Icons.chevron_right_rounded,
              onTap: () => _changeMonth(1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      children: days
          .map(
            (d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final weeks = _generateCalendarWeeks();
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: weeks.map((week) {
        return TableRow(
          children: week.map((day) => _buildDayCell(day)).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildDayCell(int? day) {
    if (day == null) return const SizedBox(height: 34);

    final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
    final isSelected = _isSameDay(date, _selectedDay);
    final hasData = hasTransactions(date);

    return GestureDetector(
      onTap: () => _onDayTapped(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 34,
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.white : Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w400,
                color: isSelected ? kPrimary : Colors.white.withOpacity(0.9),
              ),
            ),
            // Small dot if the date has transactions
            if (hasData && !isSelected)
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 1),
                decoration: const BoxDecoration(
                  color: kPrimary200,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Splits days of the month into weeks (rows of 7, nullable padding).
  List<List<int?>> _generateCalendarWeeks() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;
    final offset = firstDay.weekday % 7; // 0 = Sunday

    final weeks = <List<int?>>[];
    var week = List<int?>.filled(7, null);
    int day = 1;

    for (int i = offset; i < 7; i++) {
      week[i] = day++;
    }
    weeks.add(week);

    while (day <= lastDay) {
      week = List<int?>.filled(7, null);
      for (int i = 0; i < 7 && day <= lastDay; i++) {
        week[i] = day++;
      }
      weeks.add(week);
    }

    return weeks;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// =============================================================================
// ACTIVITY SECTION
// =============================================================================

class _ActivitySection extends StatelessWidget {
  final DateTime selectedDay;
  final List<Transaction> transactions;

  const _ActivitySection({
    required this.selectedDay,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildHeader(), const SizedBox(height: 16), _buildBody()],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kPrimary900,
              ),
            ),
            Text(
              DateFormat('MMMM d, yyyy').format(selectedDay),
              style: const TextStyle(fontSize: 12, color: kPrimary400),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody() {
    // Empty state
    if (transactions.isEmpty) {
      return _EmptyState(date: selectedDay);
    }

    // Timeline list
    return Column(
      children: List.generate(transactions.length, (i) {
        return _TimelineItem(
          tx: transactions[i],
          isLast: i == transactions.length - 1,
        );
      }),
    );
  }
}

// =============================================================================
// EMPTY STATE
// =============================================================================

class _EmptyState extends StatelessWidget {
  final DateTime date;
  const _EmptyState({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: kPrimary100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox_outlined, color: kPrimary, size: 26),
          ),
          const SizedBox(height: 12),
          const Text(
            'No activity on this date',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: kPrimary700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try selecting a highlighted date.',
            style: TextStyle(fontSize: 12, color: kPrimary400),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TIMELINE ITEM
// =============================================================================

class _TimelineItem extends StatelessWidget {
  final Transaction tx;
  final bool isLast;

  const _TimelineItem({required this.tx, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Left: timeline rail ──
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: kPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Container(width: 1.5, color: kPrimary200),
                  ),
                ),
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: kPrimary400,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(width: 1.5, color: kPrimary200),
                    ),
                  )
                else
                  const SizedBox(height: 16),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ── Right: date label + card ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date + time pill
                Row(
                  children: [
                    Text(
                      tx.date,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: kPrimary900,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _TimePill(time: tx.time),
                  ],
                ),
                const SizedBox(height: 6),
                _TransactionCard(tx: tx),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TRANSACTION CARD
// =============================================================================

class _TransactionCard extends StatelessWidget {
  final Transaction tx;
  const _TransactionCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kPrimary100),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon box
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: kPrimary100,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(tx.icon, color: kPrimary, size: 20),
          ),

          const SizedBox(width: 10),

          // Title / branch / ID
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kPrimary900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tx.branch,
                  style: const TextStyle(fontSize: 11, color: kPrimary400),
                ),
                Text(
                  'ID: ${tx.txId}',
                  style: const TextStyle(fontSize: 10, color: kPrimary200),
                ),
              ],
            ),
          ),

          // Amount + status badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                tx.amount == 0 ? 'Free' : '+₱${tx.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: kPrimary,
                ),
              ),
              const SizedBox(height: 4),
              _StatusBadge(status: tx.status),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SMALL REUSABLE WIDGETS
// =============================================================================

class _TimePill extends StatelessWidget {
  final String time;
  const _TimePill({required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: kPrimary100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        time,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: kPrimary,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  // Each status has its own shade within the purple family.
  Color get _bg {
    switch (status) {
      case 'Pending':
        return kPrimary200;
      case 'Processing':
        return kPrimary100;
      default:
        return kPrimary100; // Paid
    }
  }

  Color get _text {
    switch (status) {
      case 'Pending':
        return kPrimary700;
      case 'Processing':
        return kPrimary;
      default:
        return kPrimary; // Paid
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kPrimary200),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _text,
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
