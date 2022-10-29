import 'package:flashchat/chatscreen.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool showSpinner = false;
  final _auth = FirebaseAuth.instance;
  String email = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Builder(builder: (BuildContext context) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Color(0xFFA8E890),
            body: ModalProgressHUD(
              inAsyncCall: showSpinner,
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                  children: [
                    Container(height: 50,),
                    Image.asset("images/flashchat.png",scale: 1.15,),
                    Container(height: 100,),
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontFamily: "Mali",
                          fontSize: 35.0,
                          fontWeight: FontWeight.bold,
                        ),
                        child: AnimatedTextKit(
                          pause: Duration(seconds: 5),
                          repeatForever: true,
                          animatedTexts: [
                            TyperAnimatedText('Chat at flash speed!!'),
                          ],
                        ),
                      ),
                    ),
                    Container(height: 100,),
                    Container(
                      height: 80,
                      child: Center(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 6,left: 40),
                          child: SizedBox(
                            width: 230,
                            child: TextField(
                              autofocus: true,
                              onChanged: (text){
                              email = text;
                            },
                              style: TextStyle(
                                fontFamily: "Mali",
                                fontSize: 20,
                                color: Color(0xFF939393),),
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Email",
                                  hintStyle: TextStyle(
                                    fontFamily: "Mali",
                                    fontSize: 30,
                                    color: Color(0xFF939393),)
                              ),
                            ),
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                        image: DecorationImage(image: AssetImage("images/email.png"),fit: BoxFit.none),
                      ),
                    ),
                    Container(height: 10,),
                    Container(
                      height: 80,
                      child: Center(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 6,left: 40),
                          child: SizedBox(
                            width: 230,
                            child: TextFormField(
                              autofocus: true,
                              scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                              onChanged: (text){
                                password = text;
                              },
                              style: TextStyle(
                                fontFamily: "Mali",
                                fontSize: 20,
                                color: Color(0xFF939393),),
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Password",
                                  hintStyle: TextStyle(
                                    fontFamily: "Mali",
                                    fontSize: 30,
                                    color: Color(0xFF939393),)
                              ),
                            ),
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                        image: DecorationImage(image: AssetImage("images/password.png"),fit: BoxFit.none),
                      ),
                    ),
                    Container(height: 80,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          child: Image.asset("images/loginbutton.png",scale: 1.1),
                          onTap: () async {
                            setState(() {
                              showSpinner = true;
                            });
                            try{
                              final alreadyUser = await _auth.signInWithEmailAndPassword(email: email, password: password);
                              if (alreadyUser != null){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ChatScreen()),
                                );
                                setState(() {
                                  showSpinner = false;
                                });
                              }
                            }
                            catch(e){
                              print(e);
                            }
                          },
                        ),
                        GestureDetector(
                          child: Image.asset("images/registerbutton.png",scale: 1.1),
                          onTap: () async {
                            setState(() {
                              showSpinner = true;
                            });
                            try{
                              final newUser = await _auth.createUserWithEmailAndPassword(email: email, password: password);
                              if (newUser != null){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ChatScreen()),
                                );
                                setState(() {
                                  showSpinner = false;
                                });
                              }
                            }
                            catch(e){
                              print(e);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
    );
  }
}

