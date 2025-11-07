import 'package:flutter/foundation.dart';

enum FilterType { All, Active, Done }

class Todo {
  String title;
  bool isDone;

  Todo({
    required this.title,
    this.isDone = false,
  });
}

class TodoProvider with ChangeNotifier {
  final List<Todo> _tasks = [];
  FilterType _currentFilter = FilterType.All;

  // Menyimpan item terakhir yang dihapus untuk fitur "undo"
  Todo? _lastRemovedTask;
  int? _lastRemovedTaskIndex;

  // --- Getters ---

  List<Todo> get filteredTasks {
    switch (_currentFilter) {
      case FilterType.Active:
        return _tasks.where((task) => !task.isDone).toList();
      case FilterType.Done:
        return _tasks.where((task) => task.isDone).toList();
      case FilterType.All:
      default:
        return _tasks;
    }
  }

  int get activeTaskCount {
    return _tasks.where((task) => !task.isDone).length;
  }

  FilterType get currentFilter => _currentFilter;

  // --- Methods ---

  void addTask(String title) {
    _tasks.add(Todo(title: title));
    notifyListeners();
  }

  void toggleTaskStatus(Todo task) {
    final taskIndex = _tasks.indexOf(task);
    if (taskIndex != -1) {
      _tasks[taskIndex].isDone = !_tasks[taskIndex].isDone;
      notifyListeners();
    }
  }

  Todo deleteTask(Todo task) {
    // Simpan info task sebelum dihapus
    _lastRemovedTaskIndex = _tasks.indexOf(task);
    _lastRemovedTask = task;

    _tasks.remove(task);
    notifyListeners();

    // Kembalikan task yang dihapus agar bisa ditampilkan di Snackbar
    return task;
  }

  void undoDelete() {
    if (_lastRemovedTask != null && _lastRemovedTaskIndex != null) {
      _tasks.insert(_lastRemovedTaskIndex!, _lastRemovedTask!);
      
      _lastRemovedTask = null;
      _lastRemovedTaskIndex = null;
      
      notifyListeners();
    }
  }

  void setFilter(FilterType filter) {
    _currentFilter = filter;
    notifyListeners();
  }
}