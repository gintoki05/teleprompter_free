import 'package:flutter/material.dart';
import '../data/models/script_model.dart';
import '../data/repositories/script_repository.dart';

/// State management mandiri menggunakan ChangeNotifier bawaan Flutter
class ScriptsProvider extends ChangeNotifier {
  final ScriptRepository _repository;

  ScriptsProvider({ScriptRepository? repository})
      : _repository = repository ?? ScriptRepository();

  List<ScriptModel> _scripts = [];
  bool _isLoading = true;
  String _searchQuery = '';

  List<ScriptModel> get scripts => _scripts;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<ScriptModel> get filteredScripts {
    if (_searchQuery.trim().isEmpty) return _scripts;
    final query = _searchQuery.toLowerCase().trim();
    return _scripts.where((s) {
      return s.title.toLowerCase().contains(query) ||
          s.content.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> loadScripts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _scripts = await _repository.getAllScripts();
    } catch (e) {
      debugPrint('Error loading scripts in provider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveScript(ScriptModel script) async {
    await _repository.saveScript(script);
    final index = _scripts.indexWhere((s) => s.id == script.id);
    if (index >= 0) {
      _scripts[index] = script;
    } else {
      _scripts.insert(0, script);
    }
    notifyListeners();
  }

  Future<void> deleteScript(String id) async {
    await _repository.deleteScript(id);
    _scripts.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
