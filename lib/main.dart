import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // DIO 패키지로 HTTP 통신
import 'dart:convert'; // JSON Encode, Decode를 위한 패키지
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // flutter_secure_storage 패키지

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Secure Storage',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var username = TextEditingController(); // id 입력 저장
  var password = TextEditingController(); // pw 입력 저장

  static final storage =
      FlutterSecureStorage(); // FlutterSecureStorage를 storage로 저장
  dynamic userInfo = ''; // storage에 있는 유저 정보를 저장

  //flutter_secure_storage 사용을 위한 초기화 작업
  @override
  void initState() {
    super.initState();

    // 비동기로 flutter secure storage 정보를 불러오는 작업
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });
  }

  _asyncMethod() async {
    // read 함수로 key값에 맞는 정보를 불러오고 데이터타입은 String 타입
    // 데이터가 없을때는 null을 반환
    userInfo = await storage.read(key: 'login');

    // user의 정보가 있다면 로그인 후 들어가는 첫 페이지로 넘어가게 합니다.
    if (userInfo != null) {
      Navigator.pushNamed(context, '/main');
    } else {
      print('로그인이 필요합니다');
    }
  }

  // 로그인 버튼 누르면 실행
  loginAction(accountName, password) async {
    try {
      var dio = Dio();
      var param = {'account_name': '$accountName', 'password': '$password'};

      Response response = await dio.post('로그인 API URL', data: param);

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.data['user_id'].toString());
        // 직렬화를 이용하여 데이터를 입출력하기 위해 model.dart에 Login 정의 참고
        var val = jsonEncode(Login('$accountName', '$password', '$jsonBody'));

        await storage.write(
          key: 'login',
          value: val,
        );
        print('접속 성공!');
        return true;
      } else {
        print('error');
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: ListView(
        children: [
          // 아이디 입력 영역
          TextField(
            controller: username,
            decoration: InputDecoration(
              labelText: 'Username',
            ),
          ),
          // 비밀번호 입력 영역
          TextField(
            controller: password,
            decoration: InputDecoration(
              labelText: 'Password',
            ),
          ),
          // 로그인 버튼
          ElevatedButton(
            onPressed: () async {
              if (await loginAction(username.text, password.text) == true) {
                print('로그인 성공');
                Navigator.pushNamed(context, '/service'); // 로그인 이후 서비스 화면으로 이동
              } else {
                print('로그인 실패');
              }
            },
            child: Text('로그인 하기'),
          ),
        ],
      )),
    );
  }
}

class Login {
  final String accountName;
  final String password;
  final String user_id;

  Login(this.accountName, this.password, this.user_id);

  Login.fromJson(Map<String, dynamic> json)
      : accountName = json['accountName'],
        password = json['password'],
        user_id = json['user_id'];

  Map<String, dynamic> toJson() => {
        'accountName': accountName,
        'password': password,
        'user_id': user_id,
      };
}
