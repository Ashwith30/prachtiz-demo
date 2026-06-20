import "package:prachtiz_flutter/core/theme/app_colors.dart";
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/models/kanban_task.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/styles.dart';

// Unified Brand Colors (Matches CallHealth & PraCHtiz dark theme guidelines)
const Color _kCardBg = Color(0xFF11152D);      // Flat Dark Navy card background
final Color _kCardBorder = Colors.white.withOpacity(0.08);
Color _kBrandBlue = AppColors.primary;   // Primary theme color
const Color _kBrandGreen = Color(0xFF24C06F);  // Success theme color
const Color _kTextGray = Color(0xFF94A3B8);    // Muted text grey
const Color _kDangerRed = Color(0xFFEF4444);   // Warning badge color
const Color _kWarningAmber = Color(0xFFF59E0B); // Alert color
const Color _kPurple = Color(0xFF8B5CF6);       // Purple accent color

class TaskBoardScreen extends StatefulWidget {
  @override
  State<TaskBoardScreen> createState() => _TaskBoardScreenState();
}

class _TaskBoardScreenState extends State<TaskBoardScreen> with SingleTickerProviderStateMixin {
  // Seeded clinical & administrative tasks
  final List<KanbanTask> _tasks = [
    KanbanTask(
      id: "TSK-01",
      title: "Sterilize cardiology tools",
      description: "Ensure surgical room 2 is fully prepped for afternoon procedure.",
      assignee: "Nurse Emily",
      status: TaskStatus.todo,
      priority: TaskPriority.high,
    ),
    KanbanTask(
      id: "TSK-02",
      title: "Sign medical certificates",
      description: "Batch of 5 patient certificates waiting signature authorization.",
      assignee: "Dr. Sarah",
      status: TaskStatus.inProgress,
      priority: TaskPriority.medium,
    ),
    KanbanTask(
      id: "TSK-03",
      title: "Upload biochemical lab panels",
      description: "PT-0482 blood panel reports arrived, compile for EMR entry.",
      assignee: "Nurse Emily",
      status: TaskStatus.review,
      priority: TaskPriority.high,
    ),
    KanbanTask(
      id: "TSK-04",
      title: "Restock vaccine inventory",
      description: "200 doses of Pfizer COVID boosters added to temperature fridge.",
      assignee: "Nurse John",
      status: TaskStatus.done,
      priority: TaskPriority.low,
    ),
    KanbanTask(
      id: "TSK-05",
      title: "Follow up on critically high HbA1c",
      description: "Review lab work for James Carter and trigger alert callback.",
      assignee: "Dr. Sarah",
      status: TaskStatus.todo,
      priority: TaskPriority.high,
    ),
    KanbanTask(
      id: "TSK-06",
      title: "Sanitize Consultation Room 3",
      description: "Perform infection control protocol before general check-ups.",
      assignee: "Tech. David",
      status: TaskStatus.inProgress,
      priority: TaskPriority.medium,
    ),
    KanbanTask(
      id: "TSK-07",
      title: "Calibrate ECG machine",
      description: "Run diagnostic checks on the 12-lead ICU monitor.",
      assignee: "Tech. David",
      status: TaskStatus.review,
      priority: TaskPriority.high,
    ),
    KanbanTask(
      id: "TSK-08",
      title: "Roster review for weekend shift",
      description: "Confirm on-duty schedules for card/ICU/ER ward staff.",
      assignee: "Dr. Robert",
      status: TaskStatus.done,
      priority: TaskPriority.low,
    ),
  ];

  String _searchQuery = "";
  String _priorityFilter = "All"; // "All", "High", "Medium", "Low"

  // Search text field controller & focus node
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Controller for mobile PageView & TabController
  late TabController _tabController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _updateTaskStatus(KanbanTask task, TaskStatus newStatus) {
    setState(() {
      int idx = _tasks.indexWhere((t) => t.id == task.id);
      if (idx != -1) {
        _tasks[idx] = task.copyWith(status: newStatus);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _getColumnColor(newStatus),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 800),
        content: Text(
          "Task '${task.title}' moved to ${_getStatusString(newStatus)}",
          style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 1024;

    // Filter tasks globally by search query and priority filter
    final filteredTasks = _tasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.assignee.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.id.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (_priorityFilter == "All") return true;
      if (_priorityFilter == "High") return task.priority == TaskPriority.high;
      if (_priorityFilter == "Medium") return task.priority == TaskPriority.medium;
      if (_priorityFilter == "Low") return task.priority == TaskPriority.low;

      return true;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: Title, Subtitle, and Add Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Administrative Task Board",
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Kanban workflows to coordinate clinician schedules and room preps.",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddTaskDialog,
                icon: const Icon(Icons.add_task_outlined, size: 18, color: Colors.white),
                label: Text(
                  "Add Task",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kBrandBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Filters Row: Search and Priority selection
          Builder(builder: (context) {
            final double screenWidth = MediaQuery.of(context).size.width;
            final bool isWide = screenWidth > 700;
            final searchField = SizedBox(
              width: isWide ? 300 : double.infinity,
              child: TextField(
                key: const ValueKey('task_search_field'),
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.gray800),
                decoration: InputDecoration(
                  hintText: "Search tasks, assignee, ID...",
                  hintStyle: GoogleFonts.inter(color: AppColors.gray400, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.gray400),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16, color: AppColors.gray400),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = "";
                            });
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.gray200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _kBrandBlue),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            );

            final priorityChips = SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: ["All", "High", "Medium", "Low"].map((pFilter) {
                  final isSelected = _priorityFilter == pFilter;
                  Color chipColor = _kBrandBlue;
                  if (pFilter == "High") chipColor = _kDangerRed;
                  if (pFilter == "Medium") chipColor = _kWarningAmber;
                  if (pFilter == "Low") chipColor = _kBrandGreen;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(pFilter),
                      labelStyle: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : AppColors.gray800,
                      ),
                      selected: isSelected,
                      selectedColor: chipColor,
                      backgroundColor: Colors.white,
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _priorityFilter = pFilter;
                          });
                        }
                      },
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: isSelected ? chipColor : AppColors.gray300),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );

            if (isWide) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  priorityChips,
                  searchField,
                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  searchField,
                  const SizedBox(height: 12),
                  priorityChips,
                ],
              );
            }
          }),
          const SizedBox(height: 16),

          // Kanban columns container
          Expanded(
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _buildKanbanColumn("To Do", TaskStatus.todo, filteredTasks)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildKanbanColumn("In Progress", TaskStatus.inProgress, filteredTasks)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildKanbanColumn("Under Review", TaskStatus.review, filteredTasks)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildKanbanColumn("Completed", TaskStatus.done, filteredTasks)),
                    ],
                  )
                : Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        indicatorColor: _kBrandBlue,
                        labelColor: _kBrandBlue,
                        unselectedLabelColor: AppColors.gray500,
                        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                        onTap: (index) {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                          );
                        },
                        tabs: [
                          Tab(text: "To Do (${filteredTasks.where((t) => t.status == TaskStatus.todo).length})"),
                          Tab(text: "In Progress (${filteredTasks.where((t) => t.status == TaskStatus.inProgress).length})"),
                          Tab(text: "Review (${filteredTasks.where((t) => t.status == TaskStatus.review).length})"),
                          Tab(text: "Done (${filteredTasks.where((t) => t.status == TaskStatus.done).length})"),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            _tabController.animateTo(index);
                          },
                          children: [
                            _buildKanbanColumn("To Do", TaskStatus.todo, filteredTasks),
                            _buildKanbanColumn("In Progress", TaskStatus.inProgress, filteredTasks),
                            _buildKanbanColumn("Under Review", TaskStatus.review, filteredTasks),
                            _buildKanbanColumn("Completed", TaskStatus.done, filteredTasks),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(String columnName, TaskStatus status, List<KanbanTask> allFilteredTasks) {
    List<KanbanTask> columnTasks = allFilteredTasks.where((t) => t.status == status).toList();
    Color columnColor = _getColumnColor(status);

    return DragTarget<KanbanTask>(
      onWillAccept: (data) => data != null && data.status != status,
      onAccept: (task) {
        _updateTaskStatus(task, status);
      },
      builder: (context, candidateData, rejectedData) {
        final bool isOver = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isOver ? columnColor.withOpacity(0.04) : Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOver ? columnColor : Colors.white.withOpacity(0.08),
              width: isOver ? 1.5 : 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: columnColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        columnName,
                        style: GoogleFonts.inter(
                          color: AppColors.gray800,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: columnColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${columnTasks.length}",
                      style: GoogleFonts.robotoMono(
                        color: columnColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 12),

              // Tasks List
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: columnTasks.length,
                  itemBuilder: (context, index) {
                    final task = columnTasks[index];
                    return Draggable<KanbanTask>(
                      data: task,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Opacity(
                          opacity: 0.85,
                          child: Container(
                            width: 240,
                            child: _buildTaskCard(task, isDraggingFeedback: true),
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: Container(
                          height: 110,
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.01),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.06)),
                          ),
                          child: Center(
                            child: Icon(Icons.swap_horiz, color: Colors.white.withOpacity(0.1), size: 24),
                          ),
                        ),
                      ),
                      child: _buildTaskCard(task),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskCard(KanbanTask task, {bool isDraggingFeedback = false}) {
    return _InteractiveTaskCard(
      task: task,
      isFeedback: isDraggingFeedback,
      onTap: () => _showTaskDetailsDialog(task),
      onShift: (forward) {
        setState(() {
          int idx = _tasks.indexOf(task);
          TaskStatus newStatus;
          if (forward) {
            if (task.status == TaskStatus.todo) newStatus = TaskStatus.inProgress;
            else if (task.status == TaskStatus.inProgress) newStatus = TaskStatus.review;
            else newStatus = TaskStatus.done;
          } else {
            if (task.status == TaskStatus.done) newStatus = TaskStatus.review;
            else if (task.status == TaskStatus.review) newStatus = TaskStatus.inProgress;
            else newStatus = TaskStatus.todo;
          }
          _tasks[idx] = task.copyWith(status: newStatus);
        });
      },
    );
  }

  void _showAddTaskDialog() {
    final formKey = GlobalKey<FormState>();
    String title = "";
    String description = "";
    String assignee = "Dr. Sarah";
    TaskPriority priority = TaskPriority.medium;
    TaskStatus status = TaskStatus.todo;

    final List<String> assignees = [
      "Dr. Sarah", "Dr. Robert", "Dr. Angela", "Nurse Emily", "Nurse John", "Tech. David"
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: _kCardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: _kCardBorder),
              ),
              title: Text(
                "Create New Roster Task",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              content: Container(
                width: 440,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      TextFormField(
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                        decoration: _buildInputDecoration("Task Title (e.g. Sterilize instruments)"),
                        validator: (val) => val == null || val.trim().isEmpty ? "Please enter task title" : null,
                        onSaved: (val) => title = val!.trim(),
                      ),
                      const SizedBox(height: 12),

                      // Description
                      TextFormField(
                        maxLines: 3,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                        decoration: _buildInputDecoration("Instructions / Description"),
                        validator: (val) => val == null || val.trim().isEmpty ? "Please enter instructions" : null,
                        onSaved: (val) => description = val!.trim(),
                      ),
                      const SizedBox(height: 12),

                      // Assignee Dropdown
                      DropdownButtonFormField<String>(
                        dropdownColor: _kCardBg,
                        value: assignee,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                        decoration: _buildInputDecoration("Assignee"),
                        items: assignees.map((name) {
                          return DropdownMenuItem(
                            value: name,
                            child: Text(name, style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => assignee = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Priority Row
                      DropdownButtonFormField<TaskPriority>(
                        dropdownColor: _kCardBg,
                        value: priority,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                        decoration: _buildInputDecoration("Task Priority"),
                        items: TaskPriority.values.map((pr) {
                          return DropdownMenuItem(
                            value: pr,
                            child: Text(
                              pr.name.toUpperCase(),
                              style: GoogleFonts.inter(color: _getPriorityColor(pr), fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => priority = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Column status
                      DropdownButtonFormField<TaskStatus>(
                        dropdownColor: _kCardBg,
                        value: status,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                        decoration: _buildInputDecoration("Initial status"),
                        items: TaskStatus.values.map((st) {
                          return DropdownMenuItem(
                            value: st,
                            child: Text(
                              _getStatusString(st),
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => status = val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.inter(color: _kTextGray, fontSize: 13),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      setState(() {
                        _tasks.add(KanbanTask(
                          id: "TSK-${_tasks.length + 1}".padLeft(6, '0'),
                          title: title,
                          description: description,
                          assignee: assignee,
                          status: status,
                          priority: priority,
                        ));
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: _kBrandGreen,
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            "New task created successfully.",
                            style: GoogleFonts.inter(color: Colors.white),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _kBrandBlue),
                  child: Text(
                    "Create Task",
                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTaskDetailsDialog(KanbanTask task) {
    final formKey = GlobalKey<FormState>();
    String title = task.title;
    String description = task.description;
    String assignee = task.assignee;
    TaskPriority priority = task.priority;
    TaskStatus status = task.status;

    final List<String> assignees = [
      "Dr. Sarah", "Dr. Robert", "Dr. Angela", "Nurse Emily", "Nurse John", "Tech. David"
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: _kCardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: _kCardBorder),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Task Details",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    task.id,
                    style: GoogleFonts.robotoMono(
                      color: _kTextGray,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              content: Container(
                width: 440,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      TextFormField(
                        initialValue: title,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                        decoration: _buildInputDecoration("Task Title"),
                        validator: (val) => val == null || val.trim().isEmpty ? "Please enter task title" : null,
                        onSaved: (val) => title = val!.trim(),
                      ),
                      const SizedBox(height: 12),

                      // Description
                      TextFormField(
                        initialValue: description,
                        maxLines: 3,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                        decoration: _buildInputDecoration("Instructions / Description"),
                        validator: (val) => val == null || val.trim().isEmpty ? "Please enter instructions" : null,
                        onSaved: (val) => description = val!.trim(),
                      ),
                      const SizedBox(height: 12),

                      // Assignee Dropdown
                      DropdownButtonFormField<String>(
                        dropdownColor: _kCardBg,
                        value: assignee,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                        decoration: _buildInputDecoration("Assignee"),
                        items: assignees.map((name) {
                          return DropdownMenuItem(
                            value: name,
                            child: Text(name, style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => assignee = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Priority Dropdown
                      DropdownButtonFormField<TaskPriority>(
                        dropdownColor: _kCardBg,
                        value: priority,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                        decoration: _buildInputDecoration("Priority"),
                        items: TaskPriority.values.map((pr) {
                          return DropdownMenuItem(
                            value: pr,
                            child: Text(
                              pr.name.toUpperCase(),
                              style: GoogleFonts.inter(color: _getPriorityColor(pr), fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => priority = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Status Dropdown
                      DropdownButtonFormField<TaskStatus>(
                        dropdownColor: _kCardBg,
                        value: status,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                        decoration: _buildInputDecoration("Status"),
                        items: TaskStatus.values.map((st) {
                          return DropdownMenuItem(
                            value: st,
                            child: Text(
                              _getStatusString(st),
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => status = val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                // Delete button on the left
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _tasks.removeWhere((t) => t.id == task.id);
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: _kDangerRed,
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          "Task '${task.title}' has been deleted.",
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline, color: _kDangerRed, size: 16),
                  label: Text("Delete", style: GoogleFonts.inter(color: _kDangerRed, fontSize: 13)),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.inter(color: _kTextGray, fontSize: 13),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      setState(() {
                        int idx = _tasks.indexWhere((t) => t.id == task.id);
                        if (idx != -1) {
                          _tasks[idx] = KanbanTask(
                            id: task.id,
                            title: title,
                            description: description,
                            assignee: assignee,
                            status: status,
                            priority: priority,
                          );
                        }
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: _kBrandGreen,
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            "Task details updated successfully.",
                            style: GoogleFonts.inter(color: Colors.white),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _kBrandBlue),
                  child: Text(
                    "Save Changes",
                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: _kTextGray, fontSize: 12),
      filled: true,
      fillColor: const Color(0xFF1A1F3E),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _kCardBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _kBrandBlue, width: 1.2),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: _kDangerRed),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: _kDangerRed, width: 1.2),
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  Color _getColumnColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return _kBrandBlue;
      case TaskStatus.inProgress:
        return _kWarningAmber;
      case TaskStatus.review:
        return _kPurple;
      case TaskStatus.done:
        return _kBrandGreen;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return _kBrandGreen;
      case TaskPriority.medium:
        return _kWarningAmber;
      case TaskPriority.high:
        return _kDangerRed;
    }
  }

  String _getStatusString(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return "To Do";
      case TaskStatus.inProgress:
        return "In Progress";
      case TaskStatus.review:
        return "Under Review";
      case TaskStatus.done:
        return "Completed";
    }
  }
}

class _InteractiveTaskCard extends StatefulWidget {
  final KanbanTask task;
  final bool isFeedback;
  final VoidCallback onTap;
  final Function(bool) onShift;

  const _InteractiveTaskCard({
    required this.task,
    required this.onTap,
    required this.onShift,
    this.isFeedback = false,
  });

  @override
  State<_InteractiveTaskCard> createState() => _InteractiveTaskCardState();
}

class _InteractiveTaskCardState extends State<_InteractiveTaskCard> {
  bool _isHovered = false;

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return _kBrandGreen;
      case TaskPriority.medium:
        return _kWarningAmber;
      case TaskPriority.high:
        return _kDangerRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final priorityColor = _getPriorityColor(task.priority);

    return MouseRegion(
      onEnter: (_) {
        if (!widget.isFeedback) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (!widget.isFeedback) setState(() => _isHovered = false);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: _kCardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? _kBrandBlue.withOpacity(0.4) : _kCardBorder,
              width: 1.2,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: _kBrandBlue.withOpacity(0.08),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    )
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Priority & Task ID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: priorityColor.withOpacity(0.2)),
                    ),
                    child: Text(
                      task.priority.name.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: priorityColor,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Text(
                    task.id,
                    style: GoogleFonts.robotoMono(
                      fontSize: 10,
                      color: _kTextGray,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Title & Description
              Text(
                task.title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                task.description,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: _kTextGray,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 10),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 10),

              // Bottom Row: Assignee initials avatar & Shift triggers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: _kBrandBlue.withOpacity(0.12),
                        child: Text(
                          task.assignee.startsWith("Dr.")
                              ? task.assignee.substring(3).trim()[0]
                              : (task.assignee.startsWith("Nurse") ? task.assignee.substring(5).trim()[0] : task.assignee.trim()[0]),
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: _kBrandBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        task.assignee,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _kTextGray,
                        ),
                      ),
                    ],
                  ),

                  // Fallback shift arrows (visible on hover or non-desktop)
                  if (!widget.isFeedback)
                    Row(
                      children: [
                        if (task.status != TaskStatus.todo)
                          GestureDetector(
                            onTap: () => widget.onShift(false),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 12,
                              color: _kTextGray,
                            ),
                          ),
                        if (task.status != TaskStatus.todo && task.status != TaskStatus.done)
                          const SizedBox(width: 8),
                        if (task.status != TaskStatus.done)
                          GestureDetector(
                            onTap: () => widget.onShift(true),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: _kTextGray,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

