// data_generator.dart

class DataGenerator {
  static List<List<String>> generateTableData() {
    // Replace this with your data generation logic
    return List.generate(10, (index) {
      return [
        'Row ${index + 1}',
        'Data ${(index + 1) * 2}',
        'Info ${(index + 1) * 3}',
      ];
    });
  }
}
