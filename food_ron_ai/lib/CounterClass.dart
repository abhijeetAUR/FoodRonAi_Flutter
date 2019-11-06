import 'package:shared_preferences/shared_preferences.dart';

class ReturnCounterValue{

  int counterStart;
  int counterValueFrom = 1000;

  incrementCounterWithOne() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  counterStart = (prefs.getInt('counter') ?? 0) + 1;
  print('$counterStart times.');
  await prefs.setInt('counterfromone', counterStart);
  return 1;
}

incrementCounterFromThousand() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  counterValueFrom += (prefs.getInt('counter') ?? 0) + 1;
  print('$counterStart times.');
  await prefs.setInt('counterfromthousand', counterValueFrom);
  return 1;
}
}