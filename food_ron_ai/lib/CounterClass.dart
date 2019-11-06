import 'package:shared_preferences/shared_preferences.dart';

class ReturnCounterValue{

  int counterStart;
  int counterValueFrom = 1000;

  incrementCounterWithOne() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  counterStart = (prefs.getInt('counterfromone') ?? 0) + 1;
  print('$counterStart times.');
  await prefs.setInt('counterfromone', counterStart);
  return prefs.getInt('counterfromone');
}

incrementCounterFromThousand() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  counterValueFrom += 1;
  print('$counterStart times.');
  await prefs.setInt('counterfromthousand', counterValueFrom);
  return prefs.getInt('counterfromthousand');
}
}