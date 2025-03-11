import 'package:flutter/material.dart';
import 'package:intellimate/domain/entities/note.dart';
import 'package:intellimate/presentation/providers/note_provider.dart';
import 'package:provider/provider.dart';

class NoteTestPage extends StatefulWidget {
  const NoteTestPage({super.key});

  @override
  State<NoteTestPage> createState() => _NoteTestPageState();
}

class _NoteTestPageState extends State<NoteTestPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isFavorite = false;
  String? _category;

  final List<String> _categories = ['工作', '个人', '学习', '其他'];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // 加载所有笔记
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NoteProvider>(context, listen: false).getAllNotes();
    });
  }

  // 创建笔记
  void _createNote() {
    if (_formKey.currentState!.validate()) {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      
      // 创建笔记对象
      final note = Note(
        id: '', // ID将由存储库生成
        title: _titleController.text,
        content: _contentController.text,
        category: _category,
        tags: ['测试'], // 简单添加一个测试标签
        isFavorite: _isFavorite,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 保存笔记
      noteProvider.createNote(note).then((_) {
        // 重置表单
        _titleController.clear();
        _contentController.clear();
        setState(() {
          _isFavorite = false;
          _category = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('笔记创建成功！')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建失败: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('笔记测试'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<NoteProvider>(context, listen: false).getAllNotes();
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: '标题',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入标题';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(
                        labelText: '分类',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _category = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _contentController,
                        maxLines: null,
                        expands: true,
                        decoration: const InputDecoration(
                          labelText: '内容',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入内容';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: _isFavorite,
                          onChanged: (bool? value) {
                            setState(() {
                              _isFavorite = value ?? false;
                            });
                          },
                        ),
                        const Text('收藏'),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: _createNote,
                          child: const Text('保存笔记'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            flex: 3,
            child: Consumer<NoteProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final notes = provider.notes;
                
                if (notes.isEmpty) {
                  return const Center(child: Text('没有笔记，请创建一个！'));
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(note.title),
                        subtitle: Text(
                          note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        leading: Icon(
                          note.isFavorite ? Icons.star : Icons.star_border,
                          color: note.isFavorite ? Colors.amber : null,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (note.category != null)
                              Chip(
                                label: Text(note.category!),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                provider.deleteNote(note.id).then((_) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('笔记已删除')),
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          // 查看详情或编辑
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(note.title),
                              content: SingleChildScrollView(
                                child: Text(note.content),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('关闭'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // 可以扩展为打开独立的创建笔记页面
        },
      ),
    );
  }
} 