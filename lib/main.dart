import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fxfpcxfvrwrmmieslpxp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ4ZnBjeGZ2cndybW1pZXNscHhwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ4OTY0NjgsImV4cCI6MjA5MDQ3MjQ2OH0.UXUIkqgZbbPletEh77C0jyH6RBoX5eXBjoixNFycxhM',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Items CRUD',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> _fetchItems() async {
    final res = await _client.rpc('read_items');
    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<void> _createItem(String name, int value) async {
    await _client.rpc('create_item', params: {
      'item_name': name,
      'item_value': value,
    });
    setState(() {});
  }

  Future<void> _updateItem(String id, String name, int value) async {
    await _client.rpc('update_item', params: {
      'item_id': id,
      'item_name': name,
      'item_value': value,
    });
    setState(() {});
  }

  Future<void> _deleteItem(String id) async {
    await _client.rpc('delete_item', params: {
      'item_id': id,
    });
    setState(() {});
  }

  Future<void> _showItemDialog({Map<String, dynamic>? item}) async {
    final nameController = TextEditingController(text: item?['name'] ?? '');
    final valueController =
        TextEditingController(text: item?['value']?.toString() ?? '');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item == null ? 'Tambah Item' : 'Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(labelText: 'Value'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final value = int.tryParse(valueController.text) ?? 0;

                if (name.isEmpty) return;

                if (item == null) {
                  _createItem(name, value);
                } else {
                  _updateItem(item['id'] as String, name, value);
                }
                Navigator.of(context).pop();
              },
              child: Text(item == null ? 'Tambah' : 'Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemDialog(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada data'));
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item['name'] ?? '-'),
                subtitle: Text('Value: ${item['value']}'),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showItemDialog(item: item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteItem(item['id'] as String),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}