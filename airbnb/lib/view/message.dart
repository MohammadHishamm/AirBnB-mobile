// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MessagesScreen extends StatefulWidget {
  final String userId; // Add user ID

   MessagesScreen({super.key, required this.userId});


  @override
  State<MessagesScreen> createState() => _MyMessagesScreen();
}

class _MyMessagesScreen extends State<MessagesScreen> {
  final TextEditingController _userInput = TextEditingController();
  bool _canSendMessage = false;

  static const apiKey = "AIzaSyAA0mXY7QvNjjmku7OuAiMBTeRxpy0wS0s";

  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages(); // Load messages from shared_preferences
    _userInput.addListener(() {
      setState(() {
        _canSendMessage = _userInput.text.trim().isNotEmpty;
      });
    });
  }

  Future<void> _loadMessages() async {
  final prefs = await SharedPreferences.getInstance();
  final messagesJson = prefs.getString('messages_${widget.userId}'); // Use userId
  if (messagesJson != null) {
    setState(() {
      _messages = (json.decode(messagesJson) as List)
          .map((e) => Message(
                isUser: e['isUser'],
                message: e['message'],
                date: DateTime.parse(e['date']),
              ))
          .toList();
    });
  }
}

  Future<void> _saveMessages() async {
  final prefs = await SharedPreferences.getInstance();
  final messagesJson = json.encode(_messages.map((m) {
    return {
      'isUser': m.isUser,
      'message': m.message,
      'date': m.date.toIso8601String(),
    };
  }).toList());
  await prefs.setString('messages_${widget.userId}', messagesJson); // Use userId
}

  Future<void> sendMessage() async {
    final message = _userInput.text;

    setState(() {
      _messages
          .add(Message(isUser: true, message: message, date: DateTime.now()));
    });
    await _saveMessages();

    final content = [Content.text(message)];
    final response = await model.generateContent(content);

    setState(() {
      _messages.add(Message(
          isUser: false, message: response.text ?? "", date: DateTime.now()));
      _userInput.text = "";
      _canSendMessage = false; // Disable the button after sending
    });
    await _saveMessages(); // Save the updated messages
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent, // Stylish background color
        elevation: 4, // Subtle shadow for the AppBar
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline, // Chatbot icon
              color: Colors.white,
              size: 28,
            ),
            SizedBox(width: 10), // Add spacing between icon and text
            Text(
              "Chatbot Assistant", // Descriptive title
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true, // Center align title and icon
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15), // Rounded bottom corners
          ),
        ),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
                child: ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return Messages(
                          isUser: message.isUser,
                          message: message.message,
                          date: DateFormat('HH:mm').format(message.date));
                    })),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 15,
                    child: TextFormField(
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge, // Dynamically adjust text style
                      controller: _userInput,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        labelText: 'Enter Your Message',
                        labelStyle: TextStyle(
                          color:
                              Theme.of(context).hintColor, // Adapt label color
                        ),
                        hintText: 'Type something...',
                        hintStyle: TextStyle(
                          color: Theme.of(context)
                              .hintColor
                              .withOpacity(0.6), // Hint color adaptation
                        ),
                        filled: true,
                        fillColor: Theme.of(context)
                            .cardColor, // Adjust background color in dark mode
                      ),
                    ),
                  ),
                  Spacer(),
                  if (_canSendMessage)
                    IconButton(
                      padding: EdgeInsets.all(12),
                      iconSize: 30,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.black),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                        shape: WidgetStateProperty.all(CircleBorder()),
                      ),
                      onPressed: () {
                        sendMessage();
                      },
                      icon: Icon(Icons.send),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Message {
  final bool isUser;
  final String message;
  final DateTime date;

  Message({required this.isUser, required this.message, required this.date});
}

class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final String date;

  const Messages({
    super.key,
    required this.isUser,
    required this.message,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(vertical: 15).copyWith(
        left: isUser ? 100 : 10,
        right: isUser ? 10 : 100,
      ),
      decoration: BoxDecoration(
        color: isUser ? Colors.blueAccent : Colors.grey.shade400,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: isUser ? Radius.circular(10) : Radius.zero,
          topRight: Radius.circular(10),
          bottomRight: isUser ? Radius.zero : Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
                fontSize: 16, color: isUser ? Colors.white : Colors.black),
          ),
          Text(
            date,
            style: TextStyle(
                fontSize: 10, color: isUser ? Colors.white : Colors.black),
          ),
        ],
      ),
    );
  }
}
