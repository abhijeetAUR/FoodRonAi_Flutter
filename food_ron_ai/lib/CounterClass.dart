import 'package:shared_preferences/shared_preferences.dart';

class ReturnCounterValue {
  int counterStart;
  int counterValueFrom = 1000;

  Future<int> incrementCounterWithOne() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    counterStart = (prefs.getInt('counterfromone') ?? 0) + 1;
    print('$counterStart times.');
    await prefs.setInt('counterfromone', counterStart);
    final counter = prefs.getInt('counterfromone');
    return counter;
  }

  Future<int> incrementCounterFromThousand() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    counterStart = (prefs.getInt('counterfromthousand') ?? 1000) + 1;
    print('$counterStart times.');
    await prefs.setInt('counterfromthousand', counterStart);
    final counter = prefs.getInt('counterfromthousand');
    return counter;
  }
}
