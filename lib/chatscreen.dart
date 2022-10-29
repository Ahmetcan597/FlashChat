import 'package:flashchat/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
late User loggedInUser;

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  late String messageText;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() async {
    try{
      final user = await _auth.currentUser;
      if(user != null){
        loggedInUser = user;
        print(loggedInUser.email);
      }
    }
    catch(e){
      print(e);
    }
}

  void messagesStream() async {
    await for(var snapshot in _firestore.collection("messages").snapshots()){
      for(var message in snapshot.docs){
        print(message.data());
      }
    }
  }

  String receiverName = "Eda";
  String writeText = "Eda";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (BuildContext context) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Color(0xFFA8E890),
          body: SingleChildScrollView(
            reverse: true,
            child: Column(
              children: [
                Container(height: 30,),
                Image.asset("images/flashchat.png",scale: 1.15,),
                Container(
                  margin: EdgeInsets.only(right: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                          child: Image.asset("images/logoutbutton.png",scale: 1.10,),
                        onTap: (){
                            _auth.signOut();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MyApp()),
                            );
                        },
                      ),
                    ],
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection("messages").orderBy("created_at").snapshots(),
                    builder: (context,snapshot) {
                      if(snapshot.hasData){
                        final messages = snapshot.data!.docs.reversed;
                        List<MessageBubble> messageBubbleWidgets = [];
                        for (var message in messages){
                          final messageText = message.get('text');
                          final messageSender = message.get('sender');

                          final currentUser = loggedInUser.email;

                          final messageBubbleWidget = MessageBubble(
                              sender: messageSender,
                              text: messageText,
                              isMe: currentUser == messageSender);

                          messageBubbleWidgets.add(messageBubbleWidget);
                        }
                        return Container(
                          width: double.infinity,
                          height: 460,
                          child: ListView(
                            reverse: true,
                            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                            children: messageBubbleWidgets,
                          ),
                        );
                      }
                      return Column(
                        children: [],
                      );
                    }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: Container(
                        padding: EdgeInsets.only(right: 25),
                        width: 300,
                        margin: EdgeInsets.only(bottom: 6,left: 20),
                        child: Container(
                          margin: EdgeInsets.only(left: 10),
                          child: SizedBox(
                            width: 80,
                            child: TextField(
                              autofocus: true,
                              onChanged: (text){
                                messageText = text;
                              },
                              style: TextStyle(
                                fontFamily: "Mali",
                                fontSize: 20,
                                color: Color(0xFF939393),),
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Write Text",
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
                        image: DecorationImage(image: AssetImage("images/writetext.png"),fit: BoxFit.none,scale: 1.1)
                      ),
                    ),
                    GestureDetector(
                      child: Image.asset("images/sendtext.png",scale: 1.15,),
                      onTap: () {
                        _firestore.collection("messages").add({
                          'text':messageText,
                          'sender':loggedInUser.email,
                          'created_at': FieldValue.serverTimestamp(),
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class MessageBubble extends StatelessWidget {

  MessageBubble({required this.sender, required this.text, required this.isMe});

  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(sender,style: TextStyle(fontSize: 12.0),),
          Material(
            borderRadius: BorderRadius.circular(30),
            elevation: 5.0,
              color: isMe ? Color(0xFF425F57) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 20),
                child: Text("$text",
                  style: TextStyle(color: isMe ? Colors.white : Colors.black,fontSize: 15),
                ),
              ),
          ),
        ],
      ),
    );
  }
}

