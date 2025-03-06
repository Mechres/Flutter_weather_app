String getWeatherAnimation(String condition) {
  condition = condition.toLowerCase();

  if (condition.contains('rain') || condition.contains('drizzle')) {
    return 'assets/animations/rain.json';
  } else if (condition.contains('snow')) {
    return 'assets/animations/snow.json';
  } else if (condition.contains('clear')) {
    return 'assets/animations/clear.json';
  } else if (condition.contains('cloud')) {
    return 'assets/animations/cloudy.json';
  } else if (condition.contains('thunder')) {
    return 'assets/animations/thunder.json';
  }
  return 'assets/animations/default.json';
}
