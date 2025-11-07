import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'to-do_provider.dart'; // Pastikan nama file ini 'todo_provider.dart'

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TodoProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      home: TodoListPage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
    );
  }
}

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita 'watch' provider di level tertinggi 'build'
    final provider = context.watch<TodoProvider>();

    return Scaffold(
      // Kita pecah AppBar ke method-nya sendiri agar 'build' tetap bersih
      appBar: _buildAppBar(context, provider),
      
      // Kita pecah body ke method-nya sendiri
      body: provider.filteredTasks.isEmpty
          ? _buildEmptyState()
          : _buildTaskList(context, provider),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  // Helper method untuk membuat AppBar
  PreferredSizeWidget _buildAppBar(BuildContext context, TodoProvider provider) {
    return AppBar(
      title: Text('To-Do List (${_getFilterName(provider.currentFilter)})'),
      
      // Menampilkan jumlah tugas aktif
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(20.0),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Tugas aktif: ${provider.activeTaskCount}',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),

      // Menu filter
      actions: [
        PopupMenuButton<FilterType>(
          initialValue: provider.currentFilter,
          onSelected: (FilterType filter) {
            // Gunakan 'context.read' di dalam callback
            context.read<TodoProvider>().setFilter(filter);
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<FilterType>>[
            const PopupMenuItem<FilterType>(
              value: FilterType.All,
              child: Text('Semua'),
            ),
            const PopupMenuItem<FilterType>(
              value: FilterType.Active,
              child: Text('Aktif'),
            ),
            const PopupMenuItem<FilterType>(
              value: FilterType.Done,
              child: Text('Selesai'),
            ),
          ],
        ),
      ],
    );
  }

  // Helper method untuk menampilkan pesan saat list kosong
  Widget _buildEmptyState() {
    return Center(
      child: Text('Tidak ada tugas'),
    );
  }

  // Helper method untuk membangun list tugas
  Widget _buildTaskList(BuildContext context, TodoProvider provider) {
    return ListView.builder(
      itemCount: provider.filteredTasks.length,
      itemBuilder: (context, index) {
        final task = provider.filteredTasks[index];
        
        return CheckboxListTile(
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isDone
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          value: task.isDone,
          onChanged: (bool? newValue) {
            context.read<TodoProvider>().toggleTaskStatus(task);
          },
          
          // Tombol delete dengan logic Undo
          secondary: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              final deletedTask = context.read<TodoProvider>().deleteTask(task);

              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Tugas '${deletedTask.title}' dihapus"),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      context.read<TodoProvider>().undoDelete();
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Helper method untuk nama filter (tetap sama)
  String _getFilterName(FilterType filter) {
    switch (filter) {
      case FilterType.Active:
        return 'Aktif';
      case FilterType.Done:
        return 'Selesai';
      default:
        return 'Semua';
    }
  }

  // Dialog untuk tambah tugas (tetap sama)
  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    String? _errorText;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Tugas Baru'),
              content: TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Masukkan judul tugas...',
                  errorText: _errorText,
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Batal'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                TextButton(
                  child: Text('Simpan'),
                  onPressed: () {
                    final title = _controller.text;
                    if (title.length >= 3) {
                      context.read<TodoProvider>().addTask(title);
                      Navigator.of(dialogContext).pop();
                    } else {
                      setDialogState(() {
                        _errorText = 'Minimal 3 karakter';
                      });
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}