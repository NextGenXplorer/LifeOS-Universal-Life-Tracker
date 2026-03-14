import 'dart:convert';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../core/services/database_service.dart';
import '../../core/constants/database_constants.dart';

class ModelManager {
  static Interpreter? _habitPredictorModel;
  static Interpreter? _productivityModel;
  static Interpreter? _moodModel;
  static Interpreter? _anomalyModel;

  static bool _isInitialized = false;
  static final List<String> _loadedModels = [];

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Try to load TFLite models from assets
      await _loadModel('habit_predictor', 'assets/tflite/habit_predictor.tflite');
      await _loadModel('productivity', 'assets/tflite/productivity_model.tflite');
      await _loadModel('mood', 'assets/tflite/mood_forecast.tflite');
      await _loadModel('anomaly', 'assets/tflite/anomaly_detector.tflite');
      
      _isInitialized = true;
    } catch (e) {
      // Models not available - use algorithm-based fallbacks
      print('TFLite models not available, using algorithm-based predictions');
      _isInitialized = true;
    }
  }

  static Future<void> _loadModel(String name, String assetPath) async {
    try {
      final interpreter = await Interpreter.fromAsset(assetPath);
      
      switch (name) {
        case 'habitPredictor':
          _habitPredictorModel = interpreter;
          break;
        case 'productivity':
          _productivityModel = interpreter;
          break;
        case 'mood':
          _moodModel = interpreter;
          break;
        case 'anomaly':
          _anomalyModel = interpreter;
          break;
      }
      
      _loadedModels.add(name);
    } catch (e) {
      print('Failed to load model $name: $e');
    }
  }

  static bool isModelLoaded(String modelName) {
    return _loadedModels.contains(modelName);
  }

  static List<String> getLoadedModels() {
    return List.from(_loadedModels);
  }

  static Future<void> runInference({
    required String modelName,
    required List<double> input,
    required Function(List<double>) callback,
  }) async {
    if (input.isEmpty) {
      callback([]);
      return;
    }

    Interpreter? model;
    switch (modelName) {
      case 'habitPredictor':
        model = _habitPredictorModel;
      case 'productivity':
        model = _productivityModel;
      case 'mood':
        model = _moodModel;
      case 'anomaly':
        model = _anomalyModel;
    }

    if (model == null) {
      callback([]);
      return;
    }

    try {
      final inputTensor = input.reshape([1, input.length]);
      final output = List<double>.filled(10, 0).reshape([1, 10]);
      
      model.run(inputTensor, output);
      callback(output[0]);
    } catch (e) {
      print('Inference error: $e');
      callback([]);
    }
  }

  static Future<void> close() async {
    _habitPredictorModel?.close();
    _productivityModel?.close();
    _moodModel?.close();
    _anomalyModel?.close();
    
    _habitPredictorModel = null;
    _productivityModel = null;
    _moodModel = null;
    _anomalyModel = null;
    
    _loadedModels.clear();
    _isInitialized = false;
  }
}
