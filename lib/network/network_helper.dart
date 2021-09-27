import 'package:http/http.dart' as http;

//network class
class NetworkHelper {
  NetworkHelper({this.url});
  String? url;
  //fetch data from network
  Future network(Map data) async {
    try {
      http.Response response = await http.post(Uri.parse(url!), body: data);
      var jsondata = response.body;
      return jsondata;
    } catch (e) {
      rethrow;
    }
  }
}
