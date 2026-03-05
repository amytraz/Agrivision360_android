import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'task_model.dart';
import 'calendar_service.dart';
import 'add_task_screen.dart';

class FarmCalendarScreen extends StatefulWidget {
  const FarmCalendarScreen({super.key});

  @override
  State<FarmCalendarScreen> createState() => _FarmCalendarScreenState();
}

class _FarmCalendarScreenState extends State<FarmCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();
  final CalendarService _dbService = CalendarService();
  
  List<Task> _selectedDayTasks = [];
  List<Task> _upcomingTasks = [];
  List<Task> _historyTasks = [];
  Map<String, List<String>> _dateCategories = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    
    final allTasks = await _dbService.getAllTasks();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    List<Task> selected = [];
    List<Task> upcoming = [];
    List<Task> history = [];
    Map<String, List<String>> dateCats = {};

    for (var task in allTasks) {
      final taskDate = DateTime(task.date.year, task.date.month, task.date.day);
      final dStr = DateFormat('yyyy-MM-dd').format(taskDate);
      
      // Category map for calendar indicators
      dateCats.putIfAbsent(dStr, () => []);
      if (!dateCats[dStr]!.contains(task.category)) {
        dateCats[dStr]!.add(task.category);
      }

      if (task.isCompleted) {
        history.add(task);
      } else {
        if (taskDate.isAtSameMomentAs(DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day))) {
          selected.add(task);
        }
        if (taskDate.isAfter(today)) {
          upcoming.add(task);
        }
      }
    }

    // Sort upcoming by date
    upcoming.sort((a, b) => a.date.compareTo(b.date));
    // Sort history by date descending
    history.sort((a, b) => b.date.compareTo(a.date));

    if (mounted) {
      setState(() {
        _selectedDayTasks = selected;
        _upcomingTasks = upcoming;
        _historyTasks = history;
        _dateCategories = dateCats;
        _isLoading = false;
      });
    }
  }

  void _changeMonth(int offset) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + offset, 1);
    });
  }

  void _showAddTaskPopup() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Add Task",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const Center(child: AddTaskScreen()),
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: FadeTransition(opacity: anim1, child: child),
          ),
        );
      },
    ).then((value) {
      if (value == true) _loadAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A1F0B) : const Color(0xFFF5F7F3),
      appBar: AppBar(
        title: const Text("Operations Hub", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.today_outlined),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
                _focusedMonth = DateTime.now();
              });
              _loadAllData();
            },
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.green))
        : CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildCalendarCard(isDark)),
              SliverToBoxAdapter(child: const SizedBox(height: 24)),
              
              // Section: Tasks for Selected Date
              _buildSectionHeader("Operations: ${DateFormat('d MMM').format(_selectedDate)}", _selectedDayTasks.length),
              _buildTaskList(_selectedDayTasks, isDark, "No operations for this day."),
              
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
              
              // Section: Upcoming
              _buildSectionHeader("Upcoming Operations", _upcomingTasks.length),
              _buildTaskList(_upcomingTasks, isDark, "No upcoming operations.", showDate: true),
              
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
              
              // Section: History
              _buildSectionHeader("Task History", _historyTasks.length),
              _buildTaskList(_historyTasks, isDark, "No completed tasks yet.", showDate: true),
              
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskPopup,
        backgroundColor: const Color(0xFF1B5E20),
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text("NEW TASK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Container(width: 4, height: 18, decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
            const Spacer(),
            if (count > 0)
              Text("$count", style: TextStyle(color: Colors.green.withOpacity(0.6), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2E1C) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('MMMM yyyy').format(_focusedMonth), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  _buildNavCircle(Icons.chevron_left, () => _changeMonth(-1)),
                  const SizedBox(width: 8),
                  _buildNavCircle(Icons.chevron_right, () => _changeMonth(1)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) => Text(d, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.green.withOpacity(0.4)))).toList(),
          ),
          const SizedBox(height: 16),
          _buildCalendarGrid(isDark),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(bool isDark) {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    int startWeekday = firstDay.weekday - 1;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 8, crossAxisSpacing: 8),
      itemCount: 42,
      itemBuilder: (context, index) {
        int dayNum = index - startWeekday + 1;
        if (dayNum < 1 || dayNum > lastDay.day) return const SizedBox();
        
        final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNum);
        final dStr = DateFormat('yyyy-MM-dd').format(date);
        final isSelected = DateFormat('yyyy-MM-dd').format(_selectedDate) == dStr;
        final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == dStr;
        final cats = _dateCategories[dStr] ?? [];

        return GestureDetector(
          onTap: () {
            setState(() => _selectedDate = date);
            _loadAllData();
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.green.withOpacity(0.1) : Colors.transparent,
              shape: BoxShape.circle,
              border: isToday ? Border.all(color: Colors.green, width: 1.5) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(dayNum.toString(), style: TextStyle(fontSize: 14, fontWeight: isSelected || isToday ? FontWeight.w900 : FontWeight.w500)),
                if (cats.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: cats.take(3).map((c) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 0.5),
                      width: 4, height: 4, decoration: BoxDecoration(color: _getCatColor(c), shape: BoxShape.circle),
                    )).toList(),
                  )
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskList(List<Task> tasks, bool isDark, String emptyMsg, {bool showDate = false}) {
    if (tasks.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(child: Text(emptyMsg, style: TextStyle(color: Colors.grey.withOpacity(0.6), fontStyle: FontStyle.italic))),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildTaskItem(tasks[index], isDark, showDate: showDate),
        childCount: tasks.length,
      ),
    );
  }

  Widget _buildTaskItem(Task task, bool isDark, {bool showDate = false}) {
    final color = _getCatColor(task.category);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2E1C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(width: 4, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, decoration: task.isCompleted ? TextDecoration.lineThrough : null)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(task.category, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
                    if (showDate) ...[
                      const SizedBox(width: 8),
                      Text("• ${DateFormat('d MMM').format(task.date)}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ]
                  ],
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: Checkbox(
              value: task.isCompleted,
              activeColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: (v) async {
                await _dbService.updateTask(task.copyWith(isCompleted: v!));
                _loadAllData();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavCircle(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green.withOpacity(0.05)),
        child: Icon(icon, size: 20, color: Colors.green),
      ),
    );
  }

  Color _getCatColor(String cat) {
    switch (cat) {
      case 'Sowing': return Colors.green;
      case 'Fertilizer': return Colors.orange;
      case 'Irrigation': return Colors.blue;
      case 'Harvesting': return Colors.red;
      default: return Colors.blueGrey;
    }
  }
}
